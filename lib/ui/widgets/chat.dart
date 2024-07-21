import 'package:datty/models/chat.dart';
import 'package:datty/models/message.dart';
import 'package:datty/models/user.dart';
import 'package:datty/repositories/message_repository.dart';
import 'package:datty/ui/pages/messaging.dart';
import 'package:datty/ui/widgets/pageTurn.dart';
import 'package:datty/ui/widgets/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatWidget extends StatefulWidget {
  final String userId;
  final String selectedUserId;
  final Timestamp creationTime;

  const ChatWidget({
    Key? key,
    required this.userId,
    required this.selectedUserId,
    required this.creationTime,
  }) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final MessageRepository messageRepository = MessageRepository();
  late User user;

  Future<Chat> getUserDetail() async {
    user = await messageRepository.getUserDetail(userId: widget.selectedUserId);
    Message message = await messageRepository.getLastMessage(
      currentUserId: widget.userId,
      selectedUserId: widget.selectedUserId,
    ).catchError((error) {
      // Return a default Message object in case of error
      return Message(
        id: 'error',
        text: 'Error fetching message',
        timestamp: Timestamp.now(),
        senderId: widget.selectedUserId,
        receiverId: widget.userId,
        photoUrl: '',
        senderName: '',
        photo: null,
        selectedUserId: '',
      );
    });

    return Chat(
      name: user.name ?? 'Unknown', // Provide a default value for name
      photoUrl: user.photo ?? '', // Provide a default value for photoUrl
      lastMessage: message.text ?? 'No message available', // Provide a default value for lastMessage
      lastMessagePhoto: message.photoUrl ?? '', // Provide a default value for lastMessagePhoto
      timestamp: message.timestamp,
    );
  }

  Future<void> openChat() async {
    User currentUser = await messageRepository.getUserDetail(userId: widget.userId);
    User selectedUser = await messageRepository.getUserDetail(userId: widget.selectedUserId);

    // Ensure the usage of BuildContext is safe
    if (!mounted) return;

    pageTurn(
      Messaging(currentUser: currentUser, selectedUser: selectedUser),
      context,
    );
  }

  Future<void> deleteChat() async {
    await messageRepository.deleteChat(
      currentUserId: widget.userId,
      selectedUserId: widget.selectedUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<Chat>(
      future: getUserDetail(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(); // Optionally, you can add a loading indicator here
        } else {
          Chat chat = snapshot.data!;
          return GestureDetector(
            onTap: () async {
              await openChat();
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Wrap(
                    children: <Widget>[
                      Text(
                        "Do you want to delete this chat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "This action is irreversible.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await deleteChat();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(size.height * 0.02),
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.height * 0.02),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            height: size.height * 0.06,
                            width: size.height * 0.06,
                            child: PhotoWidget(
                              photoLink: chat.photoUrl,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              chat.name,
                              style: TextStyle(fontSize: size.height * 0.03),
                            ),
                            chat.lastMessage.isNotEmpty
                                ? Text(
                              chat.lastMessage,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            )
                                : chat.lastMessagePhoto.isEmpty
                                ? const Text("Chat Room Open")
                                : Row(
                              children: <Widget>[
                                Icon(
                                  Icons.photo,
                                  color: Colors.grey,
                                  size: size.height * 0.02,
                                ),
                                Text(
                                  "Photo",
                                  style: TextStyle(
                                    fontSize: size.height * 0.015,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(timeago.format(chat.timestamp.toDate())),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
