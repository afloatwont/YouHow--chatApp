import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/call_service.dart';
import 'package:youhow/services/database_service.dart';
import '../models/user_profile.dart';

class CallPage extends StatefulWidget {
  final UserProfile chatUser;
  final String channelId;

  const CallPage({super.key, required this.chatUser, required this.channelId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final GetIt getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;
  late CallService _callService;
  String img = dotenv.env['CALL_BG']!;
  bool isMuted = false;
  bool isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    _databaseService = getIt.get<DatabaseService>();
    _authService = getIt.get<AuthService>();
    _callService = getIt.get<CallService>();
    _callService.initialize().then((_) {
      _callService
          .join(widget.channelId, int.parse(widget.chatUser.number!))
          .then((_) {
        _callService.publish();
        setState(() {});
      });
    });
  }

  Future<void> _toggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _callService.agoraEngine.muteLocalAudioStream(isMuted);
  }

  void _hangUp() {
    _callService.leaveChannel();
    Navigator.pop(context);
  }

  Future<void> _toggleSpeaker() async {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });

    _callService.agoraEngine.isSpeakerphoneEnabled().then((value) =>
        _callService.agoraEngine
            .setEnableSpeakerphone(!value)
            .then((_) => setState(() {})));
  }

  @override
  void dispose() {
    _callService.leaveChannel();
    _callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 255, 254, 254),
                ),
              ),
              title: Text(
                widget.chatUser.name!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
            ),
          ),
          Center(
            child: StreamBuilder<int>(
              stream: _callService.callDurationStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  return Text(
                    'Call Duration: ${snapshot.data} seconds',
                    style: const TextStyle(color: Colors.grey),
                  );
                } else {
                  return const Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.grey),
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isMuted ? Colors.black : Colors.transparent,
                    radius: 28,
                    child: IconButton(
                      icon: Icon(
                        isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () async {
                        await _toggleMute();
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 28,
                    child: IconButton(
                      icon: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _hangUp,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor:
                        isSpeakerOn ? Colors.black : Colors.transparent,
                    radius: 28,
                    child: IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () async {
                        await _toggleSpeaker();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
