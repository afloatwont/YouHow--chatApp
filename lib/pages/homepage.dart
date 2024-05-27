import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/pages/chat_page.dart';
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
  late DatabaseService _databaseService;

  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _suggestions = [];
  bool _isSearching = false;
  UserProfile currUser =
      UserProfile(uid: "", name: "", pfpURL: "", number: "", email: "");

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _suggestions = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationservice = _getIt.get<NavigationService>();
    _databaseService = _getIt.get<DatabaseService>();
    _databaseService
        .getUserProfileByUID(_authService.user!.uid)
        .then((value) => setState(() {
              currUser = value!;
              print("curr User: ${currUser.email}");
            }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _searchController.clear();
        setState(() {
          _suggestions = [];
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? GestureDetector(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter phone number',
                      border: InputBorder.none,
                    ),
                    onChanged: (query) async {
                      final s = await _databaseService.searchUsers(query);
                      setState(() {
                        _suggestions = s;
                      });
                    },
                    autofocus: true,
                  ),
                )
              : const Text(
                  'Messages',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: _buildUI(),
        drawer: _drawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleSearch,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: ClipOval(
              child: CircleAvatar(
                radius: 60,
                child: currUser.pfpURL == ""
                    ? const Icon(
                        Icons.person,
                        size: BorderSide.strokeAlignCenter,
                      )
                    : Image.network(
                        currUser.pfpURL!,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          Column(children: [
            Text(
              "${currUser.name}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "${currUser.number}",
              style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
            ),
          ]),
          const Divider(
            color: Colors.black,
            indent: 18,
            endIndent: 18,
            thickness: 0.4,
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await _authService.logout();
              _navigationservice.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: Stack(
          children: [
            _chatList(),
            if (_isSearching) _searchList(context),
          ],
        ),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: _databaseService.getFriendsUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.hasError) {
            return const Center(
              child: Text(
                "Add friends",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final UserProfile user = users[index].data();
                  return ChatTile(
                    userProfile: user,
                    onTap: () async {
                      bool res = await _databaseService.checkChatExists(
                          _authService.user!.uid, user.uid!);
                      print("chat exists: $res");
                      if (!res) {
                        _databaseService.createNewChat(
                          _authService.user!.uid,
                          user.uid!,
                        );
                      }
                      _navigationservice.push(MaterialPageRoute(
                          builder: (context) => ChatPage(
                                chatUser: user,
                              )));
                    },
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _searchList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                height: _suggestions.length < 3
                    ? _suggestions.length * 117
                    : MediaQuery.sizeOf(context).height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final user = _suggestions[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        title: Text(
                          user.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          user.number ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        leading: user.pfpURL != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(user.pfpURL!),
                                radius: 25,
                              )
                            : const CircleAvatar(
                                radius: 25,
                                child: Icon(Icons.person),
                              ),
                        onTap: () async {
                          // Handle user selection
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                            _suggestions.clear();
                          });
                          await _databaseService.addFriend(user.uid!);
                          // await _databaseService.getFriends();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
