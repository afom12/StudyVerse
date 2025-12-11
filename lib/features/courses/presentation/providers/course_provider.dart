import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/course_model.dart';
import '../../data/repositories/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final repo = CourseRepository();
  repo.init();
  return repo;
});

final coursesProvider = StreamProvider<List<CourseModel>>((ref) {
  return ref.watch(courseRepositoryProvider).watchCourses();
});

final courseProvider = FutureProvider.family<CourseModel?, String>((ref, courseId) async {
  return await ref.watch(courseRepositoryProvider).getCourse(courseId);
});

