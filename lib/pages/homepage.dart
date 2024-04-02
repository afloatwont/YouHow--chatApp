import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/pages/chat_page.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/database_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/widgets/chat_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationservice = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                print("logout: $result");
                if (result) {
                  _alertService.showToast(
                      text: "Successfully logged out!", icon: Icons.check);
                  _navigationservice.pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: _chatList(),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Unable to load Chats!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // print(snapshot.data);
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final UserProfile user = users[index].data() as UserProfile;
                  return ChatTile(
                    userProfile: user,
                    onTap: () async {
                      bool res = await _databaseService.checkChatExists(
                          _authService.user!.uid, user.uid!);
                      print("chat exists: $res");
                      if (res == false) {
                        _databaseService.createNewChat(
                          _authService.user!.uid,
                          user.uid!,
                        );
                      }
                      _navigationservice.push(
                          MaterialPageRoute(builder: (context) => ChatPage(chatUser: user,)));
                    },
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
