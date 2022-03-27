import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:squat/models/user.dart';
import 'package:squat/utils/user_preferences.dart';
import 'package:squat/widgets/button_widget.dart';
import 'package:squat/widgets/profile_widget.dart';
import 'package:squat/widgets/textfield_widget.dart';

import '../widgets/header.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  EditProfilePage({required this.user}) : super();

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Builder(
      builder: (context) =>
          Scaffold(
            appBar: header(context, titleText: 'Edit profile page'),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              physics: const BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: user.photoUrl,
                  isEdit: true,
                  onClicked: () async {},
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Display Name',
                  text: user.displayName,
                  onChanged: (name) {},
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Email',
                  text: user.email,
                  onChanged: (email) {},
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'About',
                  text: user.bio,
                  maxLines: 5,
                  onChanged: (about) {},
                ),
              ],
            ),
          ),
    );
  }
}