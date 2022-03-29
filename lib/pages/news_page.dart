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
  @override
  void initState() {
    super.initState();
    fetchNyTimesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: 'News'),
        body: nYTimesArticleSearchResult != null
            ? Container(
          // Use ListView.builder
          child: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: ListView.builder(
              // the number of items in the list
                itemCount:
                nYTimesArticleSearchResult!.response?.docs?.length,

                // display each item of the product list
                itemBuilder: (context, index) {
                  return nYTimesArticleSearchResult!
                      .response!.docs![index].multimedia!.isNotEmpty
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
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                                nYTimesArticleSearchResult!
                                    .response!.docs![index].leadParagraph!, style: TextStyle(
                              color: Colors.grey[700],
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              timeago.format(DateTime.parse(nYTimesArticleSearchResult!
                                  .response!.docs![index].pubDate!)),
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
        )
            : circularProgress());
  }

  Future<void> _pullRefresh() async {
    fetchNyTimesData();
  }

  void fetchNyTimesData() {
    var uriToFetch =
        '${Constants
        .nyTimesBaseUri}?q=${Constants
        .appSettings
        .nyTimesApiSearchTerms![random.nextInt(
        Constants.appSettings
            .nyTimesApiSearchTerms!
            .length)]}&api-key=${Constants
        .appSettings.nyTimesApiKey?.first}';

    http
        .get(Uri.parse(uriToFetch))
        .then((value){
      setState(() {
        nYTimesArticleSearchResult = NYTimesArticleSearch.fromJson(jsonDecode(value.body));
        if(nYTimesArticleSearchResult!.response != null &&
          nYTimesArticleSearchResult!.response!.docs != null){
          nYTimesArticleSearchResult!.response!.docs?.sort((a,b) => b.pubDate!.compareTo(a.pubDate!));
        }
      });
    });
  }
}
