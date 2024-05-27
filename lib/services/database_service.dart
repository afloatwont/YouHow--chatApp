import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/chat.dart';
import 'package:youhow/models/message.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/utils.dart';

class DatabaseService {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  late AuthService _authService;
  late AlertService _alertService;
  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    setupCollectionReferences();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
  }

  void setupCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userprofile, _) => userprofile.toJson(),
            );
    _chatsCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  Stream<QuerySnapshot<Object?>>? getUserProfiles() {
    return _usersCollection
        ?.where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>?;
  }

  Stream<QuerySnapshot<UserProfile>>? getFriendsUserProfiles() async* {
    final docRef = _usersCollection!.doc(_authService.user!.uid);
    print("uid: ${_authService.user!.uid}");
    final userData = await docRef.get();
    print("here");
    print(userData);
    if (userData.exists) {
      final friendsField = userData['Friends'];
      print("here again");
      if (friendsField != null &&
          friendsField is List &&
          friendsField.isNotEmpty) {
        final friends =
            List<String>.from(friendsField.map((friend) => friend.toString()));
        yield* _usersCollection!
            .where('uid', whereIn: friends)
            .snapshots()
            .cast<QuerySnapshot<UserProfile>>();
      } else {
        print("fail");
        yield* Stream<QuerySnapshot<UserProfile>>.fromIterable([]);
      }
    } else {
      print("fail");
      yield* Stream<QuerySnapshot<UserProfile>>.fromIterable([]);
    }
  }

  Future<void> createUserProfile({
    required UserProfile userProfile,
  }) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection!.doc(chatId).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update(
      {
        'messages': FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        ),
      },
    );
  }

  Future<UserProfile?> getUserProfileByUID(String uid) async {
    DocumentSnapshot docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      return UserProfile.fromJson(docSnapshot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> addFriend(String uid) async {
    // String chatId = generateChatId(uid1: _authService.user!.uid, uid2: uid);
    final docRef = _usersCollection!.doc(_authService.user!.uid);
    await docRef.update(
      {
        'Friends': FieldValue.arrayUnion(
          [
            uid,
          ],
        ),
      },
    );
    final docRef2 = _usersCollection!.doc(uid);
    await docRef2.update(
      {
        'Friends': FieldValue.arrayUnion(
          [
            _authService.user!.uid,
          ],
        ),
      },
    );
    _alertService.showToast(text: "Friend Added");
    await createNewChat(_authService.user!.uid, uid);
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    UserProfile currentUser =
        (await getUserProfileByUID(_authService.user!.uid))!;
    List<UserProfile> suggestions;
    if (query.isEmpty) {
      suggestions = [];

      return <UserProfile>[];
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('number', isGreaterThanOrEqualTo: query)
        .where('number', isLessThanOrEqualTo: '$query\uf8ff')
        .where('number', isNotEqualTo: currentUser.number)
        .get();

    suggestions = snapshot.docs
        .map((doc) => UserProfile.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return suggestions;
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
