import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int currentWater = 0; // lượng nước hiện tại (ml)
  final int targetWater = 1950; // mục tiêu (ml)

  void _increaseWater() {
    setState(() {
      currentWater += 150; // mỗi lần cộng 150ml
      if (currentWater > targetWater) {
        currentWater = targetWater;
      }
    });
  }

  void _decreaseWater() {
    setState(() {
      currentWater -= 150;
      if (currentWater < 0) {
        currentWater = 0;
      }
    });
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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

  // tên người dùng
  Widget _buildProfileHeader() {
    return Container(
      color: Colors.green,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              "T",
              style: TextStyle(fontSize: 30, color: Colors.green),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Thùy Quỳnh Chu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // thanh gói premium
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

  // chỉ số khối cơ thể
  Widget _buildBMISection(BuildContext context) {
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
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),

          // chỉ số BMI và thời gian
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "BMI",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "23.4",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // chỉ số cân nặng và chiều cao
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          "26 tháng 8 - 06:28",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Cập nhật cân nặng",
                      style: TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Thêm Divider mờ
          Divider(
            color: Colors.black26, // Màu đen mờ
            thickness: 1, // Độ dày của gạch ngang
            height: 20, // Khoảng cách giữa các widget trên và dưới Divider
            endIndent: MediaQuery.of(context).size.width * 0.1,
            indent: MediaQuery.of(context).size.width * 0.1,
          ),
          // Chiều cao và cân nặng
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("154.5 cm", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Chiều cao", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("56 kg", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Cân nặng tốt", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // chỉ số uống nước
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
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // thông tin bên trái
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

              // cột chứa nút và thanh nước
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
                          // Thanh hiển thị nước
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
                                  heightFactor: _calculateProgress() == 0 ? 0.05 : _calculateProgress(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 123, 168, 246),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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