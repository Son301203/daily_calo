import 'package:daily_calo/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../services/user_service.dart';

class ChangeInforScreen extends StatefulWidget {
  final UserModel user;

  const ChangeInforScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChangeInforScreen> createState() => _ChangeInforScreenState();
}

class _ChangeInforScreenState extends State<ChangeInforScreen> {
  late String _name;
  late double _height;
  late double _weight;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _height = widget.user.height;
    _weight = widget.user.weight;
  }

  void _editField({
    required String title,
    required String initialValue,
    required Function(String) onSubmitted,
    TextInputType inputType = TextInputType.text,
  }) {
    final TextEditingController controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa $title'),
        content: TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(hintText: 'Nhập $title mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              onSubmitted(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final updatedUser = UserModel(
      uid: widget.user.uid,
      gmail: widget.user.gmail,
      name: _name,
      height: _height,
      weight: _weight,
    );

    await UserService().updateUserProfile(
      name: _name,
      height: _height,
      weight: _weight,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lưu thành công')),
    );

    // Đợi 1.5 giây để người dùng nhìn thấy thông báo rồi mới chuyển màn
    await Future.delayed(const Duration(milliseconds: 1500));

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.profile,
      arguments: updatedUser,  // Nếu màn profile cần dữ liệu mới
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          },
        ),
      ),
      body: ListView(
        children: [
          _buildInfoTile(
            label: 'Họ tên',
            value: _name,
            onTap: () => _editField(
              title: 'Họ tên',
              initialValue: _name,
              onSubmitted: (val) => setState(() => _name = val),
            ),
          ),
          _buildInfoTile(
            label: 'Chiều cao (cm)',
            value: _height.toString(),
            onTap: () => _editField(
              title: 'Chiều cao',
              initialValue: _height.toString(),
              inputType: TextInputType.number,
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) setState(() => _height = parsed);
              },
            ),
          ),
          _buildInfoTile(
            label: 'Cân nặng (kg)',
            value: _weight.toString(),
            onTap: () => _editField(
              title: 'Cân nặng',
              initialValue: _weight.toString(),
              inputType: TextInputType.number,
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) setState(() => _weight = parsed);
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Lưu thay đổi'),
            ),
          ),
        ],
      ),
    );
  }
}
