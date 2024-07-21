import 'package:datty/bloc/message/bloc.dart';
import 'package:datty/repositories/message_repository.dart';
import 'package:datty/ui/widgets/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Messages extends StatefulWidget {
  final String userId;

  const Messages({super.key, required this.userId});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final MessageRepository _messagesRepository = MessageRepository();
  late MessageBloc _messageBloc;

  @override
  void initState() {
    super.initState();
    _messageBloc = MessageBloc(messageRepository: _messagesRepository);
    _messageBloc.add(ChatStreamEvent(currentUserId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      bloc: _messageBloc,
      builder: (BuildContext context, MessageState state) {
        if (state is ChatLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ChatLoadedState) {
          return StreamBuilder<QuerySnapshot>(
            stream: state.chatStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  "You don't have any conversations",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final doc = snapshot.data!.docs[index];
                  return ChatWidget(
                    creationTime: doc['timestamp'],
                    userId: widget.userId,
                    selectedUserId: doc.id,
                  );
                },
              );
            },
          );
        }
        return Container();
      },
    );
  }

  @override
  void dispose() {
    _messageBloc.close();
    super.dispose();
  }
}