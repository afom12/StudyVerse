import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/models/group_model.dart';
import '../../../../services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class GroupRepository {
  static const String _groupsBoxName = 'study_groups';
  static const String _messagesBoxName = 'group_messages';
  Box<Map>? _groupsBox;
  Box<Map>? _messagesBox;

  Future<void> init() async {
    if (_groupsBox == null) {
      _groupsBox = await Hive.openBox<Map>(_groupsBoxName);
    }
    if (_messagesBox == null) {
      _messagesBox = await Hive.openBox<Map>(_messagesBoxName);
    }
  }

  String? get _userId {
    try {
      return FirebaseService.currentUser?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveGroupToLocal(StudyGroupModel group) async {
    await init();
    await _groupsBox!.put(group.id, group.toJson());
  }

  Future<void> _saveMessageToLocal(GroupMessageModel message) async {
    await init();
    await _messagesBox!.put(message.id, message.toJson());
  }

  List<StudyGroupModel> _getGroupsFromLocal() {
    if (_groupsBox == null) return [];
    return _groupsBox!.values
        .map((json) => StudyGroupModel.fromJson(Map<String, dynamic>.from(json)))
        .where((group) => group.members.contains(_userId) || group.createdBy == _userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<GroupMessageModel> _getMessagesFromLocal(String groupId) {
    if (_messagesBox == null) return [];
    return _messagesBox!.values
        .map((json) => GroupMessageModel.fromJson(Map<String, dynamic>.from(json)))
        .where((msg) => msg.groupId == groupId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _saveGroupToCloud(StudyGroupModel group) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    try {
      await FirebaseService.firestore
          .collection('study_groups')
          .doc(group.id)
          .set(group.toJson());
    } catch (e) {
      print('Error saving group to cloud: $e');
    }
  }

  Future<void> _saveMessageToCloud(GroupMessageModel message) async {
    if (!FirebaseService.isInitialized || _userId == null) return;
    try {
      await FirebaseService.firestore
          .collection('group_messages')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      print('Error saving message to cloud: $e');
    }
  }

  Stream<List<StudyGroupModel>> watchGroups() {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getGroupsFromLocal());
    }

    try {
      return FirebaseService.firestore
          .collection('study_groups')
          .where('members', arrayContains: _userId)
          .snapshots()
          .map((snapshot) {
        final groups = snapshot.docs
            .map((doc) => StudyGroupModel.fromJson(doc.data()))
            .toList();
        
        // Also get groups created by user
        return groups;
      });
    } catch (e) {
      print('Error watching groups: $e');
      return Stream.value(_getGroupsFromLocal());
    }
  }

  Stream<List<GroupMessageModel>> watchMessages(String groupId) {
    if (!FirebaseService.isInitialized || _userId == null) {
      return Stream.value(_getMessagesFromLocal(groupId));
    }

    try {
      return FirebaseService.firestore
          .collection('group_messages')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) => GroupMessageModel.fromJson(doc.data()))
            .toList();
        
        for (final message in messages) {
          _saveMessageToLocal(message);
        }
        
        return messages;
      });
    } catch (e) {
      print('Error watching messages: $e');
      return Stream.value(_getMessagesFromLocal(groupId));
    }
  }

  Future<StudyGroupModel> createGroup({
    required String name,
    String? description,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final inviteCode = _generateInviteCode();
    final group = StudyGroupModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdBy: _userId!,
      members: [_userId!],
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    await _saveGroupToLocal(group);
    await _saveGroupToCloud(group);

    return group;
  }

  Future<void> joinGroup(String inviteCode) async {
    if (_userId == null) return;

    try {
      final snapshot = await FirebaseService.firestore
          .collection('study_groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Invalid invite code');
      }

      final groupData = snapshot.docs.first.data();
      final group = StudyGroupModel.fromJson(groupData);

      if (group.members.contains(_userId)) {
        return; // Already a member
      }

      final updatedMembers = [...group.members, _userId!];
      final updatedGroup = StudyGroupModel(
        id: group.id,
        name: group.name,
        description: group.description,
        createdBy: group.createdBy,
        members: updatedMembers,
        inviteCode: group.inviteCode,
        createdAt: group.createdAt,
      );

      await _saveGroupToLocal(updatedGroup);
      await _saveGroupToCloud(updatedGroup);
    } catch (e) {
      print('Error joining group: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String message,
    String? attachmentUrl,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final groupMessage = GroupMessageModel(
      id: const Uuid().v4(),
      groupId: groupId,
      userId: _userId!,
      message: message,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );

    await _saveMessageToLocal(groupMessage);
    await _saveMessageToCloud(groupMessage);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    for (int i = 0; i < 6; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    return code.toString();
  }
}

