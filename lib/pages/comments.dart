import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squat/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import '../helpers/Constants.dart';
import 'Home.dart';
import 'package:giphy_picker/giphy_picker.dart';

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
  GiphyGif? _gif;
  List<DocumentSnapshot> documents = [];

  // String searchText = '';

  CommentsState({
    required this.userId,
  });

  // AppBar buildSearchField() {
  //   return AppBar(
  //     backgroundColor: Colors.white,
  //     title: TextFormField(
  //       onChanged: (value) {
  //         setState(() {
  //           searchText = value;
  //         });
  //       },
  //       decoration: const InputDecoration(
  //         hintText: "Search for a comment...",
  //         filled: true,
  //         prefixIcon: Icon(
  //           Icons.comment_sharp,
  //           size: 28.0,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  buildComments() {
    return StreamBuilder(
        stream: commentsRef.orderBy("timestamp", descending: false).snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];

          documents = snapshot.data.docs;

          // if (searchText.isNotEmpty) {
          //   documents = documents.where((element) {
          //     return element
          //         .get('comment')
          //         .toString()
          //         .toLowerCase()
          //         .contains(searchText.toLowerCase());
          //   }).toList();
          // }

          if (documents.isEmpty) {
            return Image.asset('assets/images/notfound.png', fit: BoxFit.fill);
          }

          documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    if (_gif != null || commentTextEditingController.text.isNotEmpty) {
      var commentId = const Uuid().v4();
      commentsRef.doc(commentId).set({
        "commentId": commentId,
        "username": currentUser?.username,
        "userId": currentUser?.id,
        "photoUrl": currentUser?.photoUrl,
        "comment": commentTextEditingController.text,
        "giphyUrl": _gif == null ? '' : _gif?.images.original?.url,
        "timestamp": DateTime.now(),
        "commentLikedByIds": [],
        "isCommentMadeByDonationUser":
            currentUser.amountDonated > 0 ? true : false
      }).then((value) {
        commentTextEditingController.clear();
        setState(() {
          _gif = null;
        });
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }
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
      appBar: AppBar(
        title: Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Comments',
                style: Constants.appHeaderTextSTyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Image.asset('assets/images/poweredbygiphy.png')),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          const Divider(),
          Visibility(
            visible: _gif == null ? false : true,
            child: Stack(children: [
              SizedBox(
                height: 150,
                child: _gif != null
                    ? GiphyImage.original(gif: _gif!)
                    : Container(),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _gif = null;
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ),
            ]),
          ),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              cursorColor: Constants.appColor,
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  hintText: 'Share your comment',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.teal),
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.gif_sharp,
                    color: _gif == null ? Colors.grey : Constants.appColor,
                  ),
                  onPressed: () async {
                    var gif = await GiphyPicker.pickGif(
                        context: context,
                        apiKey: Constants.appSettings!.giphyKey![0]);
                    if (gif != null) {
                      setState(() => _gif = gif);
                    }
                  }),
              IconButton(
                  disabledColor: Colors.grey,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Constants.appColor,
                  ),
                  onPressed: addComment),
            ]),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String commentId;
  final String username;
  final String userId;
  final String photoUrl;
  final String comment;
  final Timestamp timestamp;
  final List<String> commentLikedByIds;
  final String giphyUrl;

  Comment({
    required this.commentId,
    required this.username,
    required this.userId,
    required this.photoUrl,
    required this.comment,
    required this.timestamp,
    required this.commentLikedByIds,
    required this.giphyUrl,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      commentId: doc['commentId'],
      username: doc['username'],
      userId: doc['userId'],
      photoUrl: doc['photoUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      commentLikedByIds:
          List<String>.from(doc["commentLikedByIds"].map((x) => x)),
      giphyUrl: doc['giphyUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        giphyUrl.isEmpty
            ? ListTile(
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comment.isNotEmpty)
                      Expanded(
                          child: Text(comment,
                              style: const TextStyle(color: Colors.black))),
                  ],
                ),
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(photoUrl),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              '$username:',
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  color: Constants.appColor),
                            ),
                          ),
                          Expanded(
                            child: Text(timeago.format(timestamp.toDate()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Badge(
                      badgeColor: Constants.appColor,
                      showBadge: commentLikedByIds.isEmpty ? false : true,
                      position: BadgePosition.bottomEnd(bottom: 15, end: -10),
                      animationDuration: const Duration(milliseconds: 300),
                      animationType: BadgeAnimationType.slide,
                      badgeContent: Text(
                          NumberFormat.compact()
                              .format(commentLikedByIds.length),
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
                        child: Icon(
                          Icons.thumb_up_sharp,
                          color: commentLikedByIds.contains(currentUser.id)
                              ? Constants.appColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (comment.isNotEmpty)
                        Expanded(
                            child: Text(comment,
                                style: const TextStyle(color: Colors.black))),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                username,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    color: Constants.appColor),
                              ),
                            ),
                            Expanded(
                                child: Text(
                                    timeago.format(
                                      timestamp.toDate(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ))),
                          ],
                        ),
                      ),
                      Badge(
                        badgeColor: Constants.appColor,
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
                              //   thumbsUpColor = Constants.appColor;
                              // });
                              commentLikedByIds.add(currentUser.id);
                              await commentsRef.doc(commentId).update({
                                'commentLikedByIds':
                                    List<dynamic>.from(commentLikedByIds)
                              });
                            }
                          },
                          child: Icon(
                            Icons.thumb_up_sharp,
                            color: commentLikedByIds.contains(currentUser.id)
                                ? Constants.appColor
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: giphyUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 230.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ]),
        const Divider(),
      ],
    );
  }
}
