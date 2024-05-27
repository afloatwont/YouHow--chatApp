import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youhow/firebase_options.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/call_service.dart';
import 'package:youhow/services/database_service.dart';
import 'package:youhow/services/media_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/services/storage_service.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
  getIt.registerSingleton<CallService>(CallService());
}

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.bluetooth,
    Permission.notification,
    Permission.systemAlertWindow,
    Permission.sms,
    Permission.phone,
    Permission.storage,
  ].request();

  statuses.forEach((permission, status) {
    print('$permission: $status');
  });
}

String generateChatId({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "$id$uid");
  return chatID;
}
