import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../helpers/Constants.dart';
import '../widgets/header.dart';
import 'Home.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CreateEvent extends StatefulWidget {
  @override
  CreateEventState createState() => CreateEventState();
}

class CreateEventState extends State<CreateEvent>
    with SingleTickerProviderStateMixin {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  String eventId = '';
  final _eventNameTextEditingController = TextEditingController();
  final _eventDescriptionTextEditingController = TextEditingController();
  final _eventDurationTextEditingController = TextEditingController();
  final _eventLocationTextEditingController = TextEditingController();

  String eventDuration = '';
  bool _status = true;
  GiphyGif? _gif;

  DateTime eventOccurrenceDateTime = DateTime.now();

  addEvent() {
    var eventId = const Uuid().v4();
    eventsRef.doc(eventId).set({
      "eventId": eventId,
      "eventName": _eventNameTextEditingController.text,
      "eventStatus": '',
      "eventDescription": _eventDescriptionTextEditingController.text,
      "eventLocation": _eventLocationTextEditingController.text,
      "giphyUrl": _gif == null ? '' : _gif?.images.original?.url,
      "eventCreatedDateTime": DateTime.now(),
      "eventOccurrenceDateTime": eventOccurrenceDateTime,
      "eventEndDateTime": eventOccurrenceDateTime.add(Duration(minutes: int.parse(_eventDurationTextEditingController.text))).toUtc(),
      "createdByUserId": currentUser.id,
      "createdByUsername": currentUser.displayName,
      "eventEnrolledByIds": []
    }).then((value) {
      _eventNameTextEditingController.clear();
      _eventDescriptionTextEditingController.clear();
      _eventLocationTextEditingController.clear();
      _gif = null;
      eventOccurrenceDateTime = DateTime.now();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    print('Disposing CreateEvent');
    super.dispose();
    // Clean up the controller when the Widget is disposed
    _eventNameTextEditingController.dispose();
    _eventDescriptionTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: 'Add an Event'),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Stack(fit: StackFit.loose, children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 180.0,
                                height: 180.0,
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
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 120.0, left: 100.0),
                              child: InkWell(
                                onTap: () async {
                                  var gif = await GiphyPicker.pickGif(
                                      context: context,
                                      apiKey: Constants
                                          .appSettings.giphyKey![0]);
                                  if (gif != null) {
                                    setState(() => _gif = gif);
                                  }

                                  setState(() {
                                    _status = false;
                                  });
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Constants.appColor,
                                  radius: 25.0,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ]),
                      )
                    ],
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 10.0),
                              child: _status ? _getEditIcon() : Container(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const <Widget>[
                                  Text(
                                    'Event Name',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                    child: TextFormField(
                                      maxLength: 25,
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Event name is empty.';
                                        }
                                        return null;
                                      },
                                      onEditingComplete: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      controller:
                                          _eventNameTextEditingController,
                                      decoration: Constants
                                          .getTextFormFieldInputDecoration(
                                              'Event Name'),
                                      enabled: !_status,
                                      autofocus: !_status,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const <Widget>[
                                  Text(
                                    'Event Description',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                    child: TextFormField(
                                      minLines: 3,
                                      controller:
                                          _eventDescriptionTextEditingController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description for your event.';
                                        }
                                        return null;
                                      },
                                      onEditingComplete: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: Constants
                                          .getTextFormFieldInputDecoration(
                                              'Event description.'),
                                      enabled: !_status,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const <Widget>[
                                  Text(
                                    'Event occurrence date and time',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 25.0, top: 2.0),
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: !_status ? () {
                                        DatePicker.showDateTimePicker(context,
                                            showTitleActions: true,
                                            minTime: DateTime(2018, 3, 5),
                                            maxTime: DateTime(2019, 6, 7), onChanged: (date) {
                                              print('change $date');
                                            }, onConfirm: (dateTime) {
                                              eventOccurrenceDateTime = dateTime;
                                            }, currentTime: DateTime.now(), locale: LocaleType.en);
                                      } : null,
                                      icon: const Icon(Icons.calendar_today_sharp,
                                      )),
                                  Text(DateFormat('dd-MM-yyyy – kk:mm').format(eventOccurrenceDateTime))
                                ],
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const <Widget>[
                                  Text(
                                    'Event duration in minutes',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextFormField(
                                  // The validator receives the text that the user has entered.
                                  validator: (value) {
                                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                      return 'Please enter a duration for your event.';
                                    }
                                    return null;
                                  },
                                  onEditingComplete: () {
                                    eventDuration =
                                        _eventDurationTextEditingController
                                            .text;
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  },
                                  controller:
                                  _eventDurationTextEditingController,
                                  decoration: Constants
                                      .getTextFormFieldInputDecoration(
                                      'Event duration.'),
                                  enabled: !_status,
                                  autofocus: !_status,
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ],
                          ),
                        ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: const <Widget>[
                                  Text(
                                    'Enter a location for your event',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                    child: TextFormField(
                                      maxLength: 25,
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a location for your event.';
                                        }
                                        return null;
                                      },
                                      onEditingComplete: () {
                                        eventDuration =
                                            _eventLocationTextEditingController
                                                .text;
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      controller:
                                      _eventLocationTextEditingController,
                                      decoration: Constants
                                          .getTextFormFieldInputDecoration(
                                          'Event location.'),
                                      enabled: !_status,
                                      autofocus: !_status,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            !_status ? _getActionButtons() : Container(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
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
    //await EasyLoading.show();
    addEvent();
    Navigator.pop(context);
    //await EasyLoading.dismiss();
  }
}
