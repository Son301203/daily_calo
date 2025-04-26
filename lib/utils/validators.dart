class FormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email là bắt buộc';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Hãy nhập email hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu là bắt buộc';
    }
    if (value.length < 6) {
      return 'Mật khẩu cần ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yêu cầu nhập đầy đủ tên';
    }
    if (value.length < 3) {
      return 'Tên đầy đủ cần ít nhất 3 ký tự';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu xác nhận là bắt buộc';
    }
    if (value != password) {
      return 'Mật khẩu không trùng khớp';
    }
    return null;
  }
}
