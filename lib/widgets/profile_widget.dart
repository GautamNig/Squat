import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isCurrentUser;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.isCurrentUser,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: isCurrentUser ? buildEditIcon(color) : Container(),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = CachedNetworkImageProvider(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: Container(),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
          color: color,
          all: 0.0,
          child: IconButton(
            onPressed: onClicked,
            icon: const Icon(Icons.delete_forever_rounded, size: 30,),
            color: Colors.white,
          ),
        );


  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
