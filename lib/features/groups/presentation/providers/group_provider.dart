import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final repo = GroupRepository();
  repo.init();
  return repo;
});

final groupsProvider = StreamProvider<List<StudyGroupModel>>((ref) {
  return ref.watch(groupRepositoryProvider).watchGroups();
});

final groupMessagesProvider = StreamProvider.family<List<GroupMessageModel>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchMessages(groupId);
});

