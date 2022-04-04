import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:squat/pages/home.dart';
import 'package:squat/widgets/progress.dart';
import '../helpers/Constants.dart';
import '../json_parsers/json_parser_nytimes_articlesearch.dart';
import '../json_parsers/json_parser_nytimes_latest_world_news.dart';
import '../widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

import 'news_page.dart';

class NewsLatest extends StatefulWidget {
  const NewsLatest({Key? key}) : super(key: key);

  @override
  State<NewsLatest> createState() => _NewsLatestState();
}

class _NewsLatestState extends State<NewsLatest> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Latest News',
              style: Constants.appHeaderTextSTyle,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: (Constants.nYTimesLatestWorldNews != null &&
                  Constants.nYTimesLatestWorldNews!.results != null)
              ? ListView.builder(
                  itemCount: Constants.nYTimesLatestWorldNews!.results?.length,

                  // display each item of the product list
                  itemBuilder: (context, index) {
                    return Constants.nYTimesLatestWorldNews!.results![index].multimedia !=
                            null
                        ? Constants.nYTimesLatestWorldNews!
                                .results![index].multimedia!.isNotEmpty
                            ? Card(
                                // In many cases, the key isn't mandatory
                                child: Constants.nYTimesLatestWorldNews!
                                            .results![index].multimedia !=
                                        null
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/images/loading.gif',
                                              image: Constants.nYTimesLatestWorldNews!
                                                  .results![index]
                                                  .multimedia!
                                                  .first
                                                  .url!,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                Constants.nYTimesLatestWorldNews!
                                                    .results![index]
                                                    .multimedia!
                                                    .first
                                                    .caption!,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: Text(
                                                timeago.format(DateTime.parse(
                                                    Constants.nYTimesLatestWorldNews!
                                                        .results![index]
                                                        .publishedDate!)),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              )
                            : Container()
                        : Container();
                  })
              : circularProgress(),
        ),
        Constants.createAttributionAlignWidget('Joy M @Lottie Files',
            alignmentGeometry: Alignment.bottomLeft),
      ],
    );
  }
}
