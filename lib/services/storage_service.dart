import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  StorageService() {}

  Future<String?> uploadUserPfp(
      {required File file, required String uid}) async {
    Reference fileRef = firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        print("pfp saved");
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        print("message media saved");
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }
}
