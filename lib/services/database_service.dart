import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/chat.dart';
import 'package:youhow/models/message.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/utils.dart';

class DatabaseService {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    setupCollectionReferences();
    _authService = _getIt.get<AuthService>();
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

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
