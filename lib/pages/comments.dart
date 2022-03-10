import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squat/widgets/header.dart';
import 'package:squat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'Home.dart';

class Comments extends StatefulWidget {
  final String userId;

  Comments({
    required this.userId,
  });

  @override
  CommentsState createState() => CommentsState(
    userId: this.userId,
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String userId;

  CommentsState({
    required this.userId,
  });

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.docs.forEach((doc) {
            print(doc);
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentsRef.doc(currentUser.id).set({
      "username": currentUser?.username,
      "userId": currentUser?.id,
      "avatarUrl": currentUser?.photoUrl,
      "comment": commentController.text,
      "timestamp": timestamp,
      "commentLikedByIds": []
    });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              child: const Text("Post"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final List<String> commentLikedByIds;

  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
    required this.commentLikedByIds,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      commentLikedByIds:  List<String>.from(doc["commentLikedByIds"].map((x) => x)),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(userId);
    return Column(
      children: <Widget>[
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(comment),
              Badge(
                showBadge: commentLikedByIds.isEmpty ? false : true,
                position: BadgePosition.bottomEnd(bottom: 15, end: -10),
                animationDuration: const Duration(milliseconds: 300),
                animationType: BadgeAnimationType.slide,
                badgeContent: Text(commentLikedByIds.length.toString(),
                    style: const TextStyle(color: Colors.white)),
                child: InkWell(
                  onTap: () async {
                    if (commentLikedByIds
                        .contains(currentUser.id)) {
                      // setState(() {
                      //   thumbsUpColor = Colors.white;
                      // });
                      commentLikedByIds.remove(currentUser.id);
                      await commentsRef
                          .doc(userId)
                          .update({
                        'commentLikedByIds': List<dynamic>.from(commentLikedByIds)
                      });
                    } else {
                      // setState(() {
                      //   thumbsUpColor = Colors.pink;
                      // });
                      commentLikedByIds.add(currentUser.id);
                      await commentsRef
                          .doc(userId)
                          .update({
                        'commentLikedByIds': List<dynamic>.from(commentLikedByIds)
                      });
                    }
                  },
                  child: Icon(
                    Icons.thumb_up_sharp,
                    color: commentLikedByIds.contains(userId) ? Colors.pink : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        const Divider(),
      ],
    );
  }
}
