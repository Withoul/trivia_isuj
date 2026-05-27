import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

// Dynamically fetches the current logged-in user profile, including points and quizzes stats
final profileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final api = ApiService();
  return await api.getUserProfile();
});
