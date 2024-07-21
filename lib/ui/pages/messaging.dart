import 'dart:io';

import 'package:datty/bloc/messaging/bloc.dart';
import 'package:datty/bloc/messaging/messaging_bloc.dart';
import 'package:datty/models/message.dart';
import 'package:datty/models/user.dart';
import 'package:datty/repositories/messaging.dart';
import 'package:datty/ui/constants.dart';
import 'package:datty/ui/widgets/message.dart';
import 'package:datty/ui/widgets/photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messaging extends StatefulWidget {
  final User currentUser;
  final User selectedUser;

  const Messaging({super.key, required this.currentUser, required this.selectedUser});

  @override
  _MessagingState createState() => _MessagingState();
}

class _MessagingState extends State<Messaging> {
  final TextEditingController _messageTextController = TextEditingController();
  final MessagingRepository _messagingRepository = MessagingRepository();
  late MessagingBloc _messagingBloc;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(messagingRepository: _messagingRepository);

    _messageTextController.addListener(() {
      setState(() {
        isValid = _messageTextController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageTextController.dispose();
    _messagingBloc.close();
    super.dispose();
  }

  void _onFormSubmitted() {
    if (!isValid) return;

    _messagingBloc.add(
      SendMessageEvent(
        message: Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _messageTextController.text,
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.name,
          selectedUserId: widget.selectedUser.uid,
          receiverId: widget.selectedUser.uid,
          timestamp: Timestamp.now(),
          // photoUrl is now optional, so we can omit it if it's null
        ),
      ),
    );
    _messageTextController.clear();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: size.height * 0.02,
        title: Row(
          children: <Widget>[
            ClipOval(
              child: SizedBox(
                height: size.height * 0.06,
                width: size.height * 0.06,
                child: PhotoWidget(
                  photoLink: widget.selectedUser.photo,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(child: Text(widget.selectedUser.name)),
          ],
        ),
      ),
      body: BlocBuilder<MessagingBloc, MessagingState>(
        bloc: _messagingBloc,
        builder: (BuildContext context, MessagingState state) {
          if (state is MessagingInitialState) {
            _messagingBloc.add(
              MessageStreamEvent(
                currentUserId: widget.currentUser.uid,
                selectedUserId: widget.selectedUser.uid,
              ),
            );
          }
          if (state is MessagingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MessagingLoadedState) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: state.messageStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            "Start the conversation?",
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      if (snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MessageWidget(
                              currentUserId: widget.currentUser.uid,
                              messageId: snapshot.data!.docs[index].id,
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Start the conversation?",
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  width: size.width,
                  height: size.height * 0.06,
                  color: backgroundColor,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null) {
                            File photo = File(result.files.single.path!);
                             _messagingBloc.add(
                            SendMessageEvent(
                            message: Message(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            text: '',
                            senderName: widget.currentUser.name,
                            senderId: widget.currentUser.uid,
                            selectedUserId: widget.selectedUser.uid,
                            receiverId: widget.selectedUser.uid,
                            timestamp: Timestamp.now(),
                            photo: photo,
                      // photoUrl is now optional, so we can omit it if it's null
                           ),
                          ),
                         );
                        }
                       },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.height * 0.005),
                          child: Icon(Icons.add, color: Colors.white, size: size.height * 0.04),
                         ),
                       ),
                      Expanded(
                        child: Container(
                          height: size.height * 0.05,
                          padding: EdgeInsets.all(size.height * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(size.height * 0.04),
                          ),
                          child: TextField(
                            controller: _messageTextController,
                            textInputAction: TextInputAction.send,
                            maxLines: null,
                            decoration: null,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: backgroundColor,
                            textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                       ),
                      GestureDetector(
                        onTap: _onFormSubmitted,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.height * 0.01),
                          child: Icon(
                            Icons.send,
                            size: size.height * 0.04,
                            color: isValid ? Colors.white : Colors.grey,
                           ),
                         ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}