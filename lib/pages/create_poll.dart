import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';
import '../helpers/Constants.dart';
import '../widgets/header.dart';
import 'home.dart';

class CreatePoll extends StatefulWidget {
  @override
  CreatePollState createState() => CreatePollState();
}

class CreatePollState extends State<CreatePoll>
    with SingleTickerProviderStateMixin {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controllers = [];
  List<TextField> _fields = [];

  String pollId = '';
  final _pollTitleTextEditingController = TextEditingController();
  final _pollImageTextEditingController = TextEditingController();
  final _pollDurationTextEditingController = TextEditingController();

  String pollDuration = '';
  bool _status = true;

  DateTime pollOccurrenceDateTime = DateTime.now();

  @override
  void dispose() {
    super.dispose();

    _pollTitleTextEditingController.dispose();
    _pollImageTextEditingController.dispose();

    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: header(context, titleText: 'Create a Poll'),
            floatingActionButton: FloatingActionButton(
              onPressed: (_controllers.length >= 4 || _status) ? null : () {
                final controller = TextEditingController();
                final field = TextField(
                  maxLength: 25,
                  controller: controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Option ${_controllers.length + 1}",
                    errorText: _validateOptions() ? null : 'Add atleast 2 non-empty options for your poll.',
                  ),
                );

                setState(() {
                  _controllers.add(controller);
                  _fields.add(field);
                });
              },
              child: const Icon(Icons.add_circle_rounded),
            ),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                getUpperContent(),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                  child: Text(
                     _controllers.isNotEmpty ? 'Options :' : 'Add some options.',
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ),
                _listView(),
                !_status ? _getActionButtons() : Container(),
              ],
            )));
  }

  Widget _listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: _fields.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
          child: _fields[index],
        );
      },
    );
  }

  Column getUpperContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 10.0,
                height: 10.0,
                child: Stack(children: [
                  SizedBox(
                    height: 10,
                    child: Container(),
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
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                  child: _status ? _getEditIcon() : Container(),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const <Widget>[
                      Text(
                        'Poll title',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          maxLength: 25,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Poll title is empty.';
                            }
                            return null;
                          },
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          controller: _pollTitleTextEditingController,
                          decoration: Constants.getTextFormFieldInputDecoration(
                              'Poll title'),
                          enabled: !_status,
                          autofocus: !_status,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const <Widget>[
                      Text(
                        'Poll Image',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 25.0, right: 5.0, top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              maxLines: 5,
                              onChanged: (val){
                                setState(() {
                                _pollImageTextEditingController.text = val;
                                });
                              },
                              controller: _pollImageTextEditingController,
                              onEditingComplete: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              decoration: Constants.getTextFormFieldInputDecoration(
                                  'Optionally provide an Image Url for your poll.'),
                              enabled: !_status,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ),),
                    Expanded(
                      flex: 2,
                      child: Padding(padding: const EdgeInsets.fromLTRB(5, 5, 20, 5), child: CachedNetworkImage(
                        imageUrl: _pollImageTextEditingController.text,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: const <Widget>[
                      Text(
                        'Poll duration in days',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'Please enter a duration for your Poll.';
                            }
                            return null;
                          },
                          onEditingComplete: () {
                            pollDuration =
                                _pollDurationTextEditingController.text;
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          controller: _pollDurationTextEditingController,
                          decoration: Constants.getTextFormFieldInputDecoration(
                              'Poll duration.'),
                          enabled: !_status,
                          autofocus: !_status,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                child: ElevatedButton(
                    child: const Text("Save"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await onProfilePageSaveClicked();
                      }
                    }),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                  child: ElevatedButton(
                child: const Text("Cancel"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )),
                ),
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Constants.appColor,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Future cacheImage(BuildContext context, String urlImage) =>
      precacheImage(CachedNetworkImageProvider(urlImage), context);

  Future onProfilePageSaveClicked() async {
    if (await addPoll()) {
      Navigator.pop(context);
    }
  }

  addPoll() async {
    if (_validateOptions()) {
      EasyLoading.show();
      var options = [];
      _controllers
          .where((element) => element.text != "").forEach((element) {
            options.add(element.text);
      });

      var pollId = const Uuid().v4();
      await pollsRef.doc(pollId).set({
        "pollId": pollId,
        "pollTitle": _pollTitleTextEditingController.text,
        "pollImage": _pollImageTextEditingController.text,
        "createdByUserId": currentUser.id,
        "createdByUsername": currentUser.displayName,
        "pollCreatedDateTime": DateTime.now(),
        "pollEndDateTime": pollOccurrenceDateTime
            .add(Duration(
                days: int.parse(_pollDurationTextEditingController.text)))
            .toUtc(),
        "options": options,
        "voters": {}
      });
      _pollTitleTextEditingController.clear();
      _pollImageTextEditingController.clear();
      pollOccurrenceDateTime = DateTime.now();
      FocusManager.instance.primaryFocus?.unfocus();
      EasyLoading.dismiss();
      return true;
    } else {
      return false;
    }
  }

  bool _validateOptions() {
    return _controllers.where((element) => element.text != "").length > 1;
  }
}
