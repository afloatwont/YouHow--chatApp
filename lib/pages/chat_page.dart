import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/chat.dart';
import 'package:youhow/models/message.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/database_service.dart';
import 'package:youhow/services/media_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/services/storage_service.dart';
import 'package:youhow/utils.dart';

class ChatPage extends StatefulWidget {
  // String name;
  // String url;
  UserProfile chatUser;
  ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatUser? currentUser, otherUser;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationservice = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid,
        firstName: _authService.user!.displayName,
        profileImage: _authService.user!.photoURL);
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: CircleAvatar(
            radius: 20,
            child: ClipOval(
              child: Image.network(
                widget.chatUser.pfpURL!,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
        title: Text(
          widget.chatUser.name!,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];

          if (chat != null && chat.messages != null) {
            messages = generateChatMessage(chat.messages!);
          }

          return DashChat(
            currentUser: currentUser!,
            onSend: (message) {
              _sendMessage(message);
            },
            messages: messages,
            messageOptions: const MessageOptions(
              showOtherUsersAvatar: true,
              showOtherUsersName: true,
              showTime: true,
            ),
            inputOptions: InputOptions(
              alwaysShowSend: true,
              trailing: [
                _mediaMessageButton(),
              ],
            ),
          );
        });
  }

  Future<void> _sendMessage(ChatMessage message) async {
    if (message.medias?.isNotEmpty ?? false) {
      if (message.medias!.first.type == MediaType.image) {
        Message m = Message(
          senderID: currentUser!.id,
          content: message.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(
            message.createdAt,
          ),
        );
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, m);
      }
    } else {
      Message m = Message(
        senderID: currentUser!.id,
        content: message.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(message.createdAt),
      );
      await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, m);
    }
  }

  List<ChatMessage> generateChatMessage(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: currentUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image),
            ]);
      } else {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.getImageFromGallery();

          String? downloadUrl = await _storageService.uploadImageToChat(
            file: file!,
            chatID: generateChatId(uid1: currentUser!.id, uid2: otherUser!.id),
          );
          print("downloadurl: $downloadUrl");
          if (downloadUrl != null) {
            print("uploaded and inside if");
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(
                    url: downloadUrl, fileName: "", type: MediaType.image),
              ],
            );
            _sendMessage(chatMessage);
          }
        },
        icon: Icon(Icons.image));
  }
}
