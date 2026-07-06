import 'package:hive/hive.dart';
import '../models/user_model.dart';


class AuthService {
  static const String _userBoxName = 'user_profile';
  
  // Simulated login logic
  Future<bool> login(String username, String password) async {
    // For this minimal app, we accept any login and store it.
    // In a real app, you'd verify against a JSON configuration or API.
    var box = await Hive.openBox<User>(_userBoxName);
    
    if (username.isNotEmpty && password.length >= 4) {
      if (box.isEmpty) {
        await box.put('current_user', User(username: username));
      }
      return true;
    }
    return false;
  }

  User? getCurrentUser() {
    var box = Hive.box<User>(_userBoxName);
    return box.get('current_user');
  }

  void logout() {
    Hive.box<User>(_userBoxName).clear();
  }
}
