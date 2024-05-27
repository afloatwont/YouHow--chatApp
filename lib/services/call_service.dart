import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:youhow/consts.dart';

// TO DO:
// JOIN CHANNEL: USERS WITH SAME CHANNEL ID WILL BE IN SAME ROOM
// PUBLISH OUR STREAM
// SUBSCRIBE TO OTHER'S STREAM

class CallService {
  String appId = dotenv.env['APP_ID']!;
  String token = "";

  late RtcEngine agoraEngine;

  late Timer callTimer;
  int callDuration = 0;
  late StreamController<int> callDurationController;
  Stream<int> get callDurationStream => callDurationController.stream;

  CallService() {
    callDurationController = StreamController<int>();
  }

  bool _isJoined = false;
  int? _remoteUid;

  Future<String> fetchToken(String channelName, int uid) async {
    final response = await http.post(
      Uri.parse(tokenURL), // Replace with your server URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'channelName': channelName, 'uid': uid}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data['token']);
      return data['token'];
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request microphone permission
    await [Permission.microphone].request();

    // Create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(appId: appId));

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user uid:${connection.localUid} joined the channel");
          _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user uid:$remoteUid joined the channel");
          _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          print("Remote user uid:$remoteUid left the channel");
          _remoteUid = null;
        },
      ),
    );
    print("Setup done");
  }

  Future<void> initialize() async {
    await setupVoiceSDKEngine();
  }

  Future<void> join(String channelName, int uid) async {
    token = await fetchToken(channelName, uid);
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    // String tok = agoraEngine
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );

    _startCallTimer();
  }

  Future<void> publish() async {
    await agoraEngine.muteLocalAudioStream(false);
  }

  Future<void> leaveChannel() async {
    await agoraEngine.leaveChannel();
    _stopCallTimer();
    _resetCallTimer();
  }

  void dispose() {
    callDurationController.close();
    agoraEngine.release();
  }

  void _startCallTimer() {
    const oneSecond = Duration(seconds: 1);
    callTimer = Timer.periodic(oneSecond, (timer) {
      callDuration++;
      callDurationController.add(callDuration); // Emit call duration updates
    });
  }

  void _stopCallTimer() {
    callTimer.cancel();
  }

  void _resetCallTimer() {
    callDuration = 0;
    callDurationController.add(callDuration); // Emit call duration reset
  }
}
