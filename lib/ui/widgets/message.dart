import 'package:datty/models/message.dart';
import 'package:datty/repositories/messaging.dart';
import 'package:datty/ui/constants.dart';
import 'package:datty/ui/widgets/photo.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatefulWidget {
  final String messageId;
  final String currentUserId;

  const MessageWidget({Key? key, required this.messageId, required this.currentUserId}) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final MessagingRepository _messagingRepository = MessagingRepository();
  late Future<Message> _messageFuture;

  @override
  void initState() {
    super.initState();
    _messageFuture = _messagingRepository.getMessageDetail(messageId: widget.messageId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder<Message>(
      future: _messageFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final message = snapshot.data!;
        final isCurrentUser = message.senderId == widget.currentUserId;

        return Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            if (message.text != null)
              _buildTextMessage(message, isCurrentUser, size)
            else
              _buildPhotoMessage(message, isCurrentUser, size),
          ],
        );
      },
    );
  }

  Widget _buildTextMessage(Message message, bool isCurrentUser, Size size) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      children: <Widget>[
        if (isCurrentUser) _buildTimestamp(message, size),
        Padding(
          padding: EdgeInsets.all(size.height * 0.01),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width * 0.7),
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentUser ? backgroundColor : Colors.grey[400],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.height * 0.02),
                  topRight: Radius.circular(size.height * 0.02),
                  bottomLeft: Radius.circular(isCurrentUser ? size.height * 0.02 : 0),
                  bottomRight: Radius.circular(isCurrentUser ? 0 : size.height * 0.02),
                ),
              ),
              padding: EdgeInsets.all(size.height * 0.01),
              child: Text(
                message.text!,
                style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
        if (!isCurrentUser) _buildTimestamp(message, size),
      ],
    );
  }

  Widget _buildPhotoMessage(Message message, bool isCurrentUser, Size size) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      children: <Widget>[
        if (isCurrentUser) _buildTimestamp(message, size),
        Padding(
          padding: EdgeInsets.all(size.height * 0.01),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.7,
              maxHeight: size.width * 0.8,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: backgroundColor),
                borderRadius: BorderRadius.circular(size.height * 0.02),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.height * 0.02),
                child: PhotoWidget(photoLink: message.photoUrl!),
              ),
            ),
          ),
        ),
        if (!isCurrentUser) _buildTimestamp(message, size),
      ],
    );
  }

  Widget _buildTimestamp(Message message, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Text(timeago.format(message.timestamp.toDate())),
    );
  }
}