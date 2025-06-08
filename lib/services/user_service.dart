import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime? _weightUpdatedAt;

  DateTime? get weightUpdatedAt => _weightUpdatedAt;

  Future<UserModel?> fetchCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('UserService: Chưa đăng nhập');
      return null;
    }

    try {
      final doc =
          await _firestore.collection('Users').doc(currentUser.uid).get();

      if (!doc.exists) {
        print('UserService: Không tồn tại user với UID ${currentUser.uid}');
        return null;
      }

      final data = doc.data()!;
      return UserModel.fromMap(currentUser.uid, {
        ...data,
        'gmail': currentUser.email ?? '',
      });
    } catch (e) {
      print('UserService: Lỗi khi lấy user: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required double height,
    required double weight,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('UserService: Chưa đăng nhập');
      throw Exception('Chưa đăng nhập');
    }

    try {
      await _firestore.collection('Users').doc(uid).update({
        'name': name,
        'height': height,
        'weight': weight,
        'weightUpdatedAt': Timestamp.now(),
      });
      _weightUpdatedAt = DateTime.now();
      print('UserService: Đã cập nhật thông tin người dùng');
    } catch (e) {
      print('UserService: Lỗi khi cập nhật: $e');
      throw Exception('Không thể cập nhật: $e');
    }
  }

  Future<void> changePasswordWithReauth({
  required String oldPassword,
  required String newPassword,
}) async {
  final user = _auth.currentUser;
  if (user == null || user.email == null) {
    throw Exception('Chưa đăng nhập');
  }

  try {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message ?? 'Lỗi Firebase khi đổi mật khẩu');
  } catch (e) {
    throw Exception('Lỗi không xác định khi đổi mật khẩu');
  }
}

  Future<Map<String, dynamic>?> fetchCurrentUserWithWeightUpdate() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc =
          await _firestore.collection('Users').doc(currentUser.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      DateTime? weightUpdatedAt;
      if (data['weightUpdatedAt'] != null) {
        weightUpdatedAt = (data['weightUpdatedAt'] as Timestamp).toDate();
      }

      final user = UserModel.fromMap(currentUser.uid, {
        ...data,
        'gmail': currentUser.email ?? '',
      });

      return {'user': user, 'weightUpdatedAt': weightUpdatedAt};
    } catch (e) {
      print('UserService: Lỗi khi lấy user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('UserService: Đã đăng xuất');
    } catch (e) {
      print('UserService: Lỗi khi đăng xuất: $e');
      throw Exception('Lỗi khi đăng xuất: $e');
    }
  }
}