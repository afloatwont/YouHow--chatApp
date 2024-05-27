// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:youhow/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  Function onTap;
  ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        dense: false,
        leading: CircleAvatar(
          foregroundImage: NetworkImage(userProfile.pfpURL!),
        ),
        title: Text(userProfile.name!),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}
