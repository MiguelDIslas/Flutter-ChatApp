import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    messagesStream();
  }

  void getCurrentUser() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        loggedInUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data().keys);
        print(message.data().values);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Text(''),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('💬 Live Chat'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            SafeArea(
              child: Container(
                height: 55,
                decoration: kMessageContainerDecoration,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.keyboard_voice),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 5, bottom: 4, left: 7, right: 7),
                          child: TextField(
                            controller: messageTextController,
                            onChanged: (value) => message = value,
                            decoration: kMessageTextFieldDecoration,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          var date = Timestamp.fromDate(DateTime.now());
                          messageTextController.clear();
                          _firestore.collection('messages').add({
                            'text': message,
                            'sender': loggedInUser.email,
                            'date': date
                          });
                        },
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').orderBy('date').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: const CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ));
          } else {
            final messages = snapshot.data.docs.reversed;
            List<MessageBubble> messageBubbles = [];
            for (var message in messages) {
              final messageText = message['text'];
              final messageSender = message['sender'];
              final currentUser = loggedInUser.email;
              final messageWidget = MessageBubble(
                  messageText, messageSender, currentUser == messageSender);
              messageBubbles.add(messageWidget);
            }
            return Expanded(
                child: ListView(
              reverse: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              children: messageBubbles,
            ));
          }
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String messageText;
  final String messageSender;
  final bool isMe;

  MessageBubble(this.messageText, this.messageSender, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$messageSender',
              style: const TextStyle(fontSize: 12),
            ),
            Material(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              elevation: 5.0,
              color: isMe ? kLightBlue : kGreenColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '$messageText',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ]),
    );
  }
}
