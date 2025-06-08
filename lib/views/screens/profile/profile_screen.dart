import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/views/screens/profile/changeInfo_screen.dart';
import 'package:daily_calo/controllers/profile_controllers.dart';
import 'package:daily_calo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:daily_calo/utils/app_color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  UserModel? _profile;
  bool isLoading = true;
  late double currentWater;
  late double stepWater;
  late double targetWater;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(); // lấy singleton
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _controller.loadUserProfile();
    setState(() {
      _profile = _controller.user;
      targetWater = _controller.targetWater;
      currentWater = _controller.currentWater;
      stepWater = _controller.stepWater;
      isLoading = false;
    });
  }

  Widget _buildCircleButton(IconData icon, Future<void> Function() onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.whiteText,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightText,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: AppColors.lightText),
        onPressed: () async {
          try {
            await onPressed();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController heightController = TextEditingController(
      text: _profile?.height.toString() ?? '',
    );
    final TextEditingController weightController = TextEditingController(
      text: _profile?.weight.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật chỉ số cơ thể'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: 'Chiều cao (cm)',
                    hintText: 'Nhập chiều cao của bạn',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Cân nặng (kg)',
                    hintText: 'Nhập cân nặng của bạn',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.whiteText,
              ),
              onPressed: () async {
                final double? height = double.tryParse(heightController.text);
                final double? weight = double.tryParse(weightController.text);

                if (height != null && weight != null && _profile != null) {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });

                  try {
                    await _controller.updateUserProfile(
                      name: _profile!.name,
                      height: height,
                      weight: weight,
                    );
                    await _loadProfile();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật thông tin thành công'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi cập nhật: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập thông tin hợp lệ'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Thông tin và cài đặt",
          style: TextStyle(color: AppColors.whiteText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.whiteText),
            onPressed: () async {
              if (_profile != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeInforScreen(user: _profile!),
                  ),
                );
                // Sau khi pop về, load lại dữ liệu
                await _loadProfile();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User chưa sẵn sàng.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 16),
                    _buildBMISection(context),
                    const SizedBox(height: 16),
                    _buildWaterIntakeSection(context),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.whiteText,
            child: Text(
              _profile?.name.isNotEmpty == true ? _profile!.name[0] : "U",
              style: const TextStyle(fontSize: 30, color: AppColors.success),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _profile?.name ?? "Người dùng",
            style: const TextStyle(
              color: AppColors.whiteText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.whiteText),
            onPressed: () {
              _controller.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đăng xuất thành công')),
              );
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBMISection(BuildContext context) {
    final bmi = _controller.calculateBMI();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Chỉ số khối cơ thể (BMI)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showEditDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "BMI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bmi > 0 ? bmi.toStringAsFixed(1) : "---",
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _profile?.weightUpdatedAt != null
                              ? '${_profile!.weightUpdatedAt!.day}/${_profile!.weightUpdatedAt!.month}/${_profile!.weightUpdatedAt!.year}'
                              : 'Chưa có ngày cập nhật cân nặng',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ngày cập nhật cân nặng",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.lightText,
            thickness: 1,
            height: 20,
            endIndent: MediaQuery.of(context).size.width * 0.1,
            indent: MediaQuery.of(context).size.width * 0.1,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.height != null
                          ? "${_profile!.height.toStringAsFixed(1)} cm"
                          : "--- cm",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Chiều cao",
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.weight != null
                          ? "${_profile!.weight.toStringAsFixed(1)} kg"
                          : "--- kg",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Cân nặng tốt",
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteText,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Bạn nên uống bao nhiêu nước",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${_controller.targetWater.round()}",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "ml",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Lượng nước bạn cần uống",
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: AppColors.lightText,
                      thickness: 1,
                      height: 20,
                      endIndent: MediaQuery.of(context).size.width * 0.1,
                      indent: MediaQuery.of(context).size.width * 0,
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: AppColors.lightTextSecondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Lần cuối cùng",
                          style: TextStyle(color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              _buildCircleButton(Icons.add, () async {
                                await _controller.increaseWaterIntake(
                                  _profile?.uid ?? '',
                                );
                                setState(() {});
                              }),
                              const SizedBox(height: 16),
                              _buildCircleButton(Icons.remove, () async {
                                await _controller.decreaseWaterIntake(
                                  _profile?.uid ?? '',
                                );
                                setState(() {});
                              }),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 120,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: AppColors.whiteText,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                FractionallySizedBox(
                                  heightFactor:
                                      _controller.calculateProgress() == 0
                                          ? 0.05
                                          : _controller.calculateProgress(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        123,
                                        168,
                                        246,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightText,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${(_controller.calculateProgress() * 100).round()}%",
                                      style: const TextStyle(
                                        color: AppColors.whiteText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                "${_controller.currentWater.round()} ml",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Đã uống",
                                style: TextStyle(
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
