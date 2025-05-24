import 'package:daily_calo/views/screens/exercises/exercise_screen.dart';
import 'package:daily_calo/views/screens/meals/meal_screen.dart';
import 'package:daily_calo/views/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Theme extension for font styles
extension AppTheme on ThemeData {
  TextStyle get headerText => const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );

  TextStyle get subHeaderText => const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Roboto',
      );

  TextStyle get bodyText => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );

  TextStyle get smallText => const TextStyle(
        fontSize: 14,
        fontFamily: 'Roboto',
      );

  TextStyle get nutrientText => const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'Roboto',
      );

  TextStyle get calorieText => const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: 'Roboto',
      );
}

// Service Layer: Handles data operations
class HealthService {
  int calculateWaterIntake(int currentIntake, int goal, int increment) {
    final newIntake = currentIntake + increment;
    return newIntake > goal ? goal : newIntake;
  }

  Map<String, dynamic> getInitialData() {
    return {
      'today': DateTime.now(),
      'waterGoal': 1950,
      'waterIntake': 0,
      'caloriesNeeded': 1266,
      'weightGoal': 50,
      'currentWeight': 56.0,
      'previousWeight': 62.0,
      'previousWeightDate': DateTime(2023, 7, 25),
    };
  }

  String getDynamicHeader(DateTime selectedDate) {
    final now = DateTime.now();
    // Normalize both dates to midnight (00:00:00) for accurate day comparison
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    
    final difference = selectedDateOnly.difference(nowDateOnly).inDays;
    
    if (difference == 0) return 'Hôm nay';
    if (difference == -1) return 'Hôm qua';
    if (difference == -2) return 'Hôm kia';
    if (difference == 1) return 'Ngày mai';
    if (difference >= -7 && difference < -2) return '${-difference} ngày trước';
    if (difference >= -30 && difference < -7) return '1 tháng trước';
    if (difference > 1) return 'Thời gian tới';
    return DateFormat('d \'th\' M').format(selectedDate);
  }
}

// Controller Layer: Manages state and logic
class HomeScreenController {
  final HealthService _service;
  late DateTime _today;
  late int _waterGoal;
  late int _waterIntake;
  late int _caloriesNeeded;
  late int _weightGoal;
  late double _currentWeight;
  late double _previousWeight;
  late DateTime _previousWeightDate;
  late String _formattedDate;
  late String _dynamicHeader;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<double>? onWeightChanged;

  HomeScreenController({this.onDateChanged, this.onWeightChanged}) : _service = HealthService() {
    final data = _service.getInitialData();
    _today = data['today'];
    _waterGoal = data['waterGoal'];
    _waterIntake = data['waterIntake'];
    _caloriesNeeded = data['caloriesNeeded'];
    _weightGoal = data['weightGoal'];
    _currentWeight = data['currentWeight'];
    _previousWeight = data['previousWeight'];
    _previousWeightDate = data['previousWeightDate'];
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);
  }

  // Getters
  DateTime get today => _today;
  int get waterGoal => _waterGoal;
  int get waterIntake => _waterIntake;
  int get caloriesNeeded => _caloriesNeeded;
  int get weightGoal => _weightGoal;
  double get currentWeight => _currentWeight;
  double get previousWeight => _previousWeight;
  DateTime get previousWeightDate => _previousWeightDate;
  String get formattedDate => _formattedDate;
  String get dynamicHeader => _dynamicHeader;

  void updateWaterIntake() {
    _waterIntake = _service.calculateWaterIntake(
      _waterIntake,
      _waterGoal,
      _waterGoal ~/ 8,
    );
  }

  void updateWeight(double newWeight) {
    _previousWeight = _currentWeight;
    _previousWeightDate = DateTime.now();
    _currentWeight = newWeight;
    onWeightChanged?.call(newWeight);
  }

  void setDate(DateTime date) {
    _today = date;
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);
    onDateChanged?.call(_today);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  late HomeScreenController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller = HomeScreenController(
      onDateChanged: (date) => setState(() {}),
      onWeightChanged: (weight) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeScreenContent(
            controller: _controller,
            onWaterIntakeChanged: () {
              setState(() {
                _controller.updateWaterIntake();
              });
            },
          ),
          const MealScreen(),
          const ExerciseScreen(),
          const ProfileScreen(),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.dining_outlined), label: "Bữa ăn"),
          BottomNavigationBarItem(icon: Icon(Icons.healing_outlined), label: "Tập luyện"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Thông tin"),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final HomeScreenController controller;
  final VoidCallback? onWaterIntakeChanged;

  const HomeScreenContent({
    super.key,
    required this.controller,
    this.onWaterIntakeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildCalorieCircle(context),
              _buildWaterIntake(context),
              _buildWeightGoal(context),
              _buildActivityStats(context),
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
          Text(
            controller.dynamicHeader,
            style: Theme.of(context).headerText,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  controller.setDate(controller.today.subtract(const Duration(days: 1)));
                },
              ),
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: controller.today,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    controller.setDate(selectedDate);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      controller.formattedDate,
                      style: Theme.of(context).subHeaderText,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  controller.setDate(controller.today.add(const Duration(days: 1)));
                },
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
        Text(
          value,
          style: Theme.of(context).subHeaderText.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).nutrientText,
        ),
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
            Text(
              '${controller.caloriesNeeded}',
              style: Theme.of(context).calorieText,
            ),
            Text(
              'cần nạp',
              style: Theme.of(context).nutrientText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntake(BuildContext context) {
    final filledGlasses = controller.waterIntake ~/ (controller.waterGoal ~/ 8);
    final totalGlasses = 8;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bạn đã uống bao nhiêu nước',
                style: Theme.of(context).bodyText,
              ),
              Text(
                '${controller.waterIntake}/${controller.waterGoal} ml',
                style: Theme.of(context).bodyText.copyWith(color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                totalGlasses,
                (index) => _buildWaterGlass(context, index, filledGlasses, totalGlasses),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildWaterGlass(BuildContext context, int index, int filledGlasses, int totalGlasses) {
  final bool isFilled = index < filledGlasses;
  final bool showAddIcon = index == filledGlasses && filledGlasses < totalGlasses;

  return GestureDetector(
    onTap: showAddIcon ? onWaterIntakeChanged : null,
    child: Container(
      width: 30,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        // Only show border if the glass is not filled
        border: isFilled ? null : Border.all(color: Colors.blue.withOpacity(0.3)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
      ),
      child: Stack(
        children: [
          if (isFilled)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                  bottomLeft: Radius.circular(1),
                  bottomRight: Radius.circular(1),
                ),
                child: CustomPaint(
                  painter: WaterGlassPainter(),
                ),
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
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
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
              Text(
                'Mục tiêu',
                style: Theme.of(context).bodyText,
              ),
              Text(
                '${controller.weightGoal} kg',
                style: Theme.of(context).bodyText.copyWith(color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cân nặng',
                style: Theme.of(context).smallText.copyWith(fontSize: 16),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey),
                  onPressed: () => _showWeightDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cân nặng trước: ${controller.previousWeight.toInt()} kg',
                      style: Theme.of(context).smallText,
                    ),
                    Text(
                      'Hiện tại: ${controller.currentWeight.toInt()} kg',
                      style: Theme.of(context).smallText,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d \'th\' M').format(controller.previousWeightDate),
                      style: Theme.of(context).smallText,
                    ),
                    Text(
                      DateFormat('d \'th\' M').format(controller.today),
                      style: Theme.of(context).smallText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    TextEditingController weightController = TextEditingController(
      text: controller.currentWeight.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật cân nặng'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Cân nặng (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                controller.updateWeight(weight);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập cân nặng hợp lệ')),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActivityStat(context, 'Di chuyển', '0 kcal'),
            _buildActivityStat(context, 'Bước', '000'),
            _buildActivityStat(context, 'Thời gian', '0 phút'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).smallText.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).smallText,
        ),
      ],
    );
  }
}

class WaterGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Draw a more realistic glass shape (trapezoid with narrower bottom)
    final topWidth = size.width;
    final bottomWidth = size.width * 0.7; // Make bottom narrower
    final bottomPadding = (topWidth - bottomWidth) / 2;
    
    // Create trapezoid path
    path.moveTo(0, 0); // Top left
    path.lineTo(topWidth, 0); // Top right
    path.lineTo(topWidth - bottomPadding, size.height); // Bottom right
    path.lineTo(bottomPadding, size.height); // Bottom left
    path.close();
    
    // Fill the path
    canvas.drawPath(path, paint);
    
    // Add a small highlight effect (optional)
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.2, 0);
    highlightPath.lineTo(size.width * 0.4, 0);
    highlightPath.lineTo(size.width * 0.3, size.height * 0.7);
    highlightPath.lineTo(size.width * 0.15, size.height * 0.7);
    highlightPath.close();
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}