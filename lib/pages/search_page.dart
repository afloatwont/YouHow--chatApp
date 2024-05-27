import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _suggestions = [];
  bool _isSearching = false;
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;

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
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: _buildUI(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleSearch,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
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
    );
  }

  Widget _buildUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final user = _suggestions[index];
                return ListTile(
                  title: Text(user.name ?? ''),
                  subtitle: Text(user.number ?? ''),
                  leading: user.pfpURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.pfpURL!),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                  onTap: () async {
                    // Handle user selection
                    await _databaseService.addFriend(user.uid!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
