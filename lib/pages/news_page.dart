import 'package:flutter/material.dart';
import 'package:squat/pages/Home.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/Constants.dart';
import '../json_parsers/json_parser_nytimes_articlesearch.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  NYTimesArticleSearch? nYTimesArticleSearchResult;
  bool isPullToRefreshPerformed = false;

  @override
  void initState() {
    super.initState();
    fetchNyTimesData();
  }

  @override
  Widget build(BuildContext context) {
    return  (nYTimesArticleSearchResult != null &&
        nYTimesArticleSearchResult!.response!.docs != null
        && nYTimesArticleSearchResult!.response!.docs!.isNotEmpty)
        ? Scaffold(
          appBar: header(context, titleText: 'More Articles'),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _pullRefresh,
              child: isPullToRefreshPerformed ? circularProgress() : ListView.builder(
                  // the number of items in the list
                  itemCount: nYTimesArticleSearchResult!.response?.docs?.length,

                  // display each item of the product list
                  itemBuilder: (context, index) {
                    return (nYTimesArticleSearchResult!
                        .response!.docs![index].multimedia != null && nYTimesArticleSearchResult!
                            .response!.docs![index].multimedia!.isNotEmpty)
                        ? Card(
                            // In many cases, the key isn't mandatory
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loading.gif',
                                    image:
                                        '${Constants.nyTimesBaseUriForImages}${nYTimesArticleSearchResult!.response!.docs![index].multimedia!.first.url!}',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      nYTimesArticleSearchResult!.response!
                                          .docs![index].leadParagraph!,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      timeago.format(DateTime.parse(
                                          nYTimesArticleSearchResult!.response!
                                              .docs![index].pubDate!)),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container();
                  }),
            ),
              Constants.createAttributionAlignWidget(
                  'Joy M @Lottie Files',
                  alignmentGeometry: Alignment.bottomLeft)
            ]
          ),
        )
        : circularProgress();
  }

  Future<void> _pullRefresh() async {
    setState(() {
      isPullToRefreshPerformed = true;
      fetchNyTimesData();
    });
    Future.delayed(const Duration(milliseconds: 6000), () {
      setState(() {
        isPullToRefreshPerformed = false;
      });
    });
  }

  void fetchNyTimesData() {
    var uriToFetch =
        '${Constants.nyTimesArticleSearchBaseUri}?q=${Constants.appSettings!.nyTimesApiSearchTerms![random.nextInt(Constants.appSettings!.nyTimesApiSearchTerms!.length)]}&api-key=${Constants.appSettings!.nyTimesApiKey?.first}';

      http.get(Uri.parse(uriToFetch)).then((value) {
        setState(() {
          nYTimesArticleSearchResult =
              NYTimesArticleSearch.fromJson(jsonDecode(value.body));
        });

        if (nYTimesArticleSearchResult!.response != null &&
            nYTimesArticleSearchResult!.response!.docs != null) {
          nYTimesArticleSearchResult!.response!.docs
              ?.sort((a, b) => b.pubDate!.compareTo(a.pubDate!));
        }
      });
  }
}
