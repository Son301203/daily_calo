import 'package:daily_calo/controllers/home_controller.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:daily_calo/models/meal.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:daily_calo/controllers/profile_controllers.dart';
import 'package:daily_calo/utils/app_theme.dart';
import 'package:daily_calo/utils/water_glass_painter.dart';
import 'package:daily_calo/views/screens/exercises/exercise_screen.dart';
import 'package:daily_calo/views/screens/meals/meal_screen.dart';
import 'package:daily_calo/views/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  late HomeController _controller;
  late ProfileController _profileController;
  late Future<void> _loadProfileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller = HomeController(
      onDateChanged: (_) => setState(() {}),
      onWeightChanged: (_) => setState(() {}),
      onWaterIntakeChanged: (_) => setState(() {}),
    );
    _profileController = ProfileController();
    _loadProfileFuture = _loadProfileData();

    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục')),
        );
      });
    }
  }

  Future<void> _loadProfileData() async {
    try {
      await _profileController.loadUserProfile();
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              HomeScreenContent(
                controller: _controller,
                profileController: _profileController,
              ),
              const MealScreen(),
              const ExerciseScreen(),
              const ProfileScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _tabController.animateTo(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dining_outlined),
            label: "Bữa ăn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing_outlined),
            label: "Tập luyện",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Thông tin",
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final HomeController controller;
  final ProfileController profileController;

  const HomeScreenContent({
    super.key,
    required this.controller,
    required this.profileController,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildCalorieCircle(context),
              _buildWaterIntake(context),
              _buildWeightGoal(context),
              _buildMealList(context, userId!),
              _buildExerciseList(context, userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF4cd964),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(controller.dynamicHeader, style: Theme.of(context).headerText),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => controller.setDate(controller.today.subtract(const Duration(days: 1))),
              ),
              GestureDetector(
                onTap: () async {
                  final selectedDate = await controller.showDatePickerDialog(context);
                  if (selectedDate != null) {
                    controller.setDate(selectedDate);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(controller.formattedDate, style: Theme.of(context).subHeaderText),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => controller.setDate(controller.today.add(const Duration(days: 1))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCircle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: const Color(0xFF4cd964),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn(context, '0', 'đã nạp'),
          _buildCircleProgress(context),
          _buildStatColumn(context, '0', 'tiêu hao'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).subHeaderText.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).nutrientText),
      ],
    );
  }

  Widget _buildCircleProgress(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${controller.caloriesNeeded}', style: Theme.of(context).calorieText),
            Text('cần nạp', style: Theme.of(context).nutrientText),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntake(BuildContext context) {
    final double targetWater = profileController.targetWater;
    final double currentWater = profileController.currentWater;
    if (targetWater <= 0 || currentWater.isNaN) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Dữ liệu nước không hợp lệ'),
      );
    }
    final double waterPerGlass = targetWater / 8;
    final int filledGlasses = (currentWater / waterPerGlass).clamp(0, 8).floor();
    final totalGlasses = 8;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bạn đã uống bao nhiêu nước', style: Theme.of(context).bodyText),
              Text('${currentWater.round()}/${targetWater.round()} ml', style: Theme.of(context).bodyText.copyWith(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Mỗi cốc: ${waterPerGlass.round()} ml', style: Theme.of(context).bodyText.copyWith(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                totalGlasses,
                (index) => _buildWaterGlass(context, index, filledGlasses, totalGlasses, userId, waterPerGlass),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterGlass(BuildContext context, int index, int filledGlasses, int totalGlasses, String? userId, double waterPerGlass) {
    final bool isFilled = index < filledGlasses;
    final bool showAddIcon = index == filledGlasses && filledGlasses < totalGlasses;

    return GestureDetector(
      onTap: showAddIcon && userId != null
          ? () async {
              try {
                await profileController.increaseWater();
                (context as Element).markNeedsBuild();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi thêm nước: $e')));
              }
            }
          : null,
      onDoubleTap: isFilled && userId != null
          ? () async {
              try {
                await profileController.decreaseWater();
                (context as Element).markNeedsBuild();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi giảm nước: $e')));
              }
            }
          : null,
      child: Container(
        width: 30,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                  bottomLeft: Radius.circular(1),
                  bottomRight: Radius.circular(1),
                ),
                child: CustomPaint(painter: WaterGlassPainter(filled: isFilled)),
              ),
            ),
            if (showAddIcon)
              Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGoal(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mục tiêu', style: Theme.of(context).bodyText),
              Text('${controller.weightGoal} kg', style: Theme.of(context).bodyText.copyWith(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cân nặng', style: Theme.of(context).smallText.copyWith(fontSize: 16)),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () async {
                    final newWeight = await controller.showWeightDialog(context);
                    if (newWeight != null) {
                      controller.updateWeight(newWeight);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cân nặng trước: ${controller.previousWeight.toInt()} kg', style: Theme.of(context).smallText),
                    Text('Hiện tại: ${controller.currentWeight.toInt()} kg', style: Theme.of(context).smallText),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('d \'th\' M').format(controller.previousWeightDate), style: Theme.of(context).smallText),
                    Text(DateFormat('d \'th\' M').format(controller.today), style: Theme.of(context).smallText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(BuildContext context, String userId) {
    return StreamBuilder<List<Exercise>>(
      stream: controller.getExercisesForCurrentDate(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Có lỗi xảy ra'));
        }
        final exercises = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bài tập hôm nay', style: Theme.of(context).bodyText),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ListTile(
                    title: Text(exercise.activity),
                    subtitle: Text('${exercise.time} phút - ${exercise.kcal} kcal'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove, color: Colors.blue),
                      onPressed: () async {
                        await controller.removeExercise(userId, index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa bài tập'), backgroundColor: AppColors.success),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealList(BuildContext context, String userId) {
    return StreamBuilder<List<Meal>>(
      stream: controller.getMealForCurrentDate(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Có lỗi xảy ra'));
        }
        final meals = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bữa ăn hôm nay', style: Theme.of(context).bodyText),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return ListTile(
                    title: Text(meal.title),
                    subtitle: Text('${meal.calo} calo - ${meal.servingSize} g - ${meal.periodTime}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove, color: Colors.blue),
                      onPressed: () async {
                        await controller.removeMeal(userId, index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa món ăn'), backgroundColor: AppColors.success),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}