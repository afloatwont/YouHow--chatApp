// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/models/chat.dart';
import 'package:youhow/models/message.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/pages/call_page.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/call_service.dart';
import 'package:youhow/services/database_service.dart';
import 'package:youhow/services/media_service.dart';
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
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late CallService _callService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _callService = _getIt.get<CallService>();
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
  void dispose() {
    _callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
          child: CircleAvatar(
            radius: 10, // Set a non-zero radius value
            backgroundImage: NetworkImage(widget.chatUser.pfpURL!),
          ),
        ),
        title: Text(
          widget.chatUser.name!,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(
                      chatUser: widget.chatUser,
                      channelId: generateChatId(
                          uid1: currentUser!.id, uid2: otherUser!.id),
                    ),
                  ));
              // _callService.join(
              //     generateChatId(uid1: currentUser!.id, uid2: otherUser!.id),
              //     0);
            },
            icon: const Icon(Icons.call),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.video_call,
                size: 28,
              ),
            ),
          ),
        ],
        elevation: 8,
        shadowColor: Colors.black,
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
              sendButtonBuilder: (send) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: GestureDetector(
                    onTap: send,
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                      child: Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                );
              },
              trailing: [
                _mediaMessageButton(),
              ],
              inputDecoration: InputDecoration(
                hintText: "Enter a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                alignLabelWithHint: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
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
        icon: const Icon(Icons.image));
  }
}
