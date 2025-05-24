import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/views/auth/login_screen.dart';
import 'package:daily_calo/views/screens/profile/changeInfo_screen.dart';
import 'package:intl/intl.dart';
import '../../../controllers/profile_controllers.dart';
import '../../../models/user.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentWater = 0;
  late int targetWater;
  UserModel? _profile;
  final ProfileController _controller = ProfileController();
  bool isLoading = true;
  int stepWater = 150;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _controller.loadUserProfile();
    setState(() {
      _profile = _controller.user;
      targetWater = _controller.calculateWaterIntake();
      isLoading = false;
      print('ProfileScreen: weightUpdatedAt = ${_profile?.weightUpdatedAt}'); // Debug print
    });
  }

  void _increaseWater() {
    setState(() {
      currentWater += stepWater;
      if (currentWater > targetWater) {
        currentWater = targetWater;
      }
    });
  }

  void _decreaseWater() {
    setState(() {
      currentWater -= stepWater;
      if (currentWater < 0) {
        currentWater = 0;
      }
    });
  }

  String _formatWeightUpdateDate(DateTime? date) {
    if (date == null) return "Chưa cập nhật";
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  double _calculateProgress() {
    return (currentWater / targetWater).clamp(0.0, 1.0);
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 24, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController heightController = TextEditingController(
      text: _profile?.height?.toString() ?? '',
    );
    final TextEditingController weightController = TextEditingController(
      text: _profile?.weight?.toString() ?? '',
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi cập nhật: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập thông tin hợp lệ'),
                      backgroundColor: Colors.red,
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

  void _showEditWaterStepDialog(BuildContext context) {
    final TextEditingController stepController = TextEditingController(
      text: stepWater.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh lượng nước mỗi lần cộng/trừ'),
          content: TextField(
            controller: stepController,
            decoration: const InputDecoration(
              labelText: 'Đơn vị ml',
              hintText: 'VD: 150, 200...',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final int? newStep = int.tryParse(stepController.text);
                if (newStep != null && newStep > 0) {
                  setState(() {
                    stepWater = newStep;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập giá trị hợp lệ (> 0)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Thông tin và cài đặt",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              if (_profile != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeInforScreen(user: _profile!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User chưa sẵn sàng.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildPremiumBanner(),
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
      color: Colors.green,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _profile?.name.isNotEmpty == true ? _profile!.name[0] : "U",
              style: const TextStyle(fontSize: 30, color: Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _profile?.name ?? "Người dùng",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_off_sharp, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Gói Premium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Trải nghiệm không quảng cáo và sử dụng đầy đủ các tính năng nâng cao.",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
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
        color: Colors.white,
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
                        color: Colors.red,
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
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _profile?.weightUpdatedAt != null
                              ? '${_formatWeightUpdateDate(_profile!.weightUpdatedAt)}'
                              : 'Chưa có ngày cập nhật cân nặng',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ngày cập nhật cân nặng",
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: Colors.black26,
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
                      style: TextStyle(color: Colors.grey),
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
                      style: TextStyle(color: Colors.grey),
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
        color: Colors.white,
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
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showEditWaterStepDialog(context),
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
                          "$targetWater",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "ml",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Lượng nước bạn cần uống",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.black26,
                      thickness: 1,
                      height: 20,
                      endIndent: MediaQuery.of(context).size.width * 0.1,
                      indent: MediaQuery.of(context).size.width * 0,
                    ),
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 20, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          "Lần cuối cùng",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.notifications_off,
                          size: 20,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Bật tính năng thông báo",
                          style: TextStyle(color: Colors.orange),
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
                              _buildCircleButton(Icons.add, _increaseWater),
                              const SizedBox(height: 16),
                              _buildCircleButton(Icons.remove, _decreaseWater),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 120,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                FractionallySizedBox(
                                  heightFactor: _calculateProgress() == 0
                                      ? 0.05
                                      : _calculateProgress(),
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
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "${(_calculateProgress() * 100).round()}%",
                                      style: const TextStyle(
                                        color: Colors.white,
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
                                "$currentWater ml",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Đã uống",
                                style: TextStyle(color: Colors.grey),
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