import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:squat/widgets/header.dart';
import 'package:squat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import '../helpers/Constants.dart';
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
  TextEditingController commentTextEditingController = TextEditingController();
  final String userId;
  bool showPenLottie = true;
  CommentsState({
    required this.userId,
  });

  buildComments() {
    return StreamBuilder(
        stream: commentsRef.orderBy("timestamp", descending: false).snapshots(),
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
    var commentId = Uuid().v4();
    commentsRef.doc(commentId).set({
      "commentId": commentId,
      "username": currentUser?.username,
      "userId": currentUser?.id,
      "avatarUrl": currentUser?.photoUrl,
      "comment": commentTextEditingController.text,
      "timestamp": DateTime.now(),
      "commentLikedByIds": [],
      "isCommentMadeByDonationUser":
          currentUser.amountDonated > 0 ? true : false
    });

    commentTextEditingController.clear();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    commentTextEditingController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(child: buildComments()),
              const Divider(),
              ListTile(
                title: TextFormField(
                  onChanged: (val){
                    commentTextEditingController.text.isEmpty ? showPenLottie = true : showPenLottie = false;
                  },
                  controller: commentTextEditingController,
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Constants.appColor),
                  onPressed: addComment,
                  child: const Text("Post"),
                ),
              ),
            ],
          ),
          Constants.createAttributionAlignWidget('Monika Madurska/Sachin @Lottie Files', alignmentGeometry:
            Alignment.topCenter),
          Visibility(
            visible: showPenLottie,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Lottie.asset('assets/pen.json', width: 50, height: 50)
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String commentId;
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;
  final List<String> commentLikedByIds;
  final bool isCommentMadeByDonationUser;
  final String giphyUrl;

  Comment({
    required this.commentId,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
    required this.commentLikedByIds,
    required this.isCommentMadeByDonationUser,
    required this.giphyUrl,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      commentId: doc['commentId'],
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      commentLikedByIds:
          List<String>.from(doc["commentLikedByIds"].map((x) => x)),
      isCommentMadeByDonationUser: doc['isCommentMadeByDonationUser'],
      giphyUrl: doc['giphyUrl'],
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
                    if (commentLikedByIds.contains(currentUser.id)) {
                      // setState(() {
                      //   thumbsUpColor = Colors.white;
                      // });
                      commentLikedByIds.remove(currentUser.id);
                      await commentsRef.doc(commentId).update({
                        'commentLikedByIds':
                            List<dynamic>.from(commentLikedByIds)
                      });
                    } else {
                      // setState(() {
                      //   thumbsUpColor = Colors.pink;
                      // });
                      commentLikedByIds.add(currentUser.id);
                      await commentsRef.doc(commentId).update({
                        'commentLikedByIds':
                            List<dynamic>.from(commentLikedByIds)
                      });
                    }
                  },
                  child: Row(
                    children: [
                      isCommentMadeByDonationUser
                          ? Lottie.asset('assets/dollar.json')
                          : const Text(''),
                      Icon(
                        Icons.thumb_up_sharp,
                        color: commentLikedByIds.contains(currentUser.id)
                            ? Colors.pink
                            : Colors.grey,
                      ),
                    ],
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
