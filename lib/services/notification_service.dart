import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:youhow/services/navigation_service.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _navigationService = NavigationService();

  // function to initialise notifications
  Future<void> initNotifications() async {
    // request permissions
    await _firebaseMessaging.requestPermission();
    // fetch FCM token
    final fcmToken = await _firebaseMessaging.getToken();

    // print token
    print("Token: $fcmToken");
    
    await initPushNotifications();
  }

  // function to respond to recieved messages
  void handleMessage(RemoteMessage? m) {
    if (m == null) {
      return;
    }
    _navigationService.navigatorKey?.currentState
        ?.pushNamed('/home', arguments: m);
  }

  // function to initialise foreground and background settings

  Future initPushNotifications() async {
    _firebaseMessaging.getInitialMessage().then((value) => handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
