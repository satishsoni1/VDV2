import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mdi/mdi.dart';
import 'package:http/http.dart' as http;

import '../appColors.dart';
import '../app_theme.dart';

//* <------- Bottom card of home page ------->

class BottomCardSaved extends StatelessWidget {
  final DataModel item;
  final bool isTrending;
  var height, width;
  BottomCardSaved(this.item, {this.isTrending = false});

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 13.0, right: 20.0),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 0.2 * height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Theme.of(context).cardColor,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: <Widget>[
                  _buildContents(context, height, constraints.maxWidth),
                  Positioned(
                    bottom: 0.03 * height,
                    right: 0.03 * width,
                    child: isTrending
                        ? Image.asset(
                            "assets/img/trending.png",
                            height: 20,
                            width: 20,
                          )
                        : Container(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _buildContents(BuildContext context, var height, var width) {
    return Row(
      children: <Widget>[
        GestureDetector(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
                height: 0.2 * height * 0.80,
                width: 0.2 * height * 0.80,
                child: Image.network(
                  item.bannerImage[0],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child,
                      loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                int.parse(loadingProgress.expectedTotalBytes.toString())
                            : null,
                      ),
                    );
                  },
                )),
          ),
          onTap: () {
            Navigator.of(context).pushNamed("/ReadBlog", arguments: item);
          },
        ),
        _buildTextAndUserWidget(context, width),
      ],
    );
  }

  _buildTextAndUserWidget(BuildContext context, var width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  child: Container(
                    width: 0.48 * width,
                    child: AutoSizeText(
                      item.title.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color:
                                    appThemeModel.value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.normal),
                          ),
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                      minFontSize: 8,
                      maxFontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed("/ReadBlog", arguments: item);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: InkWell(
                  child: Image.asset(
                    "assets/img/delete.png",
                    width: 0.075 * width,
                  ),
                  onTap: () async {
                    Fluttertoast.showToast(
                        msg: "Story remove from bookmark",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIos: 5,
                        backgroundColor: appMainColor,
                        textColor: Colors.white);
                    _deleteSavedPost(context);
                  },
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            width: width * 0.53,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 4.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 0.035 * width,
                          height: 0.035 * width,
                          decoration: new BoxDecoration(
                            color: HexColor(item.categoryColor.toString()),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          item.categoryName.toString(),
                          style: Theme.of(context).textTheme.bodyText1?.merge(
                                TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  //   child: Icon(
                  //     Mdi.eye,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                  // Text(
                  //   item.viewCount.toString(),
                  //   style: Theme.of(context).textTheme.bodyText1?.merge(
                  //         TextStyle(
                  //             color: appThemeModel.value.isDarkModeEnabled.value
                  //                 ? Colors.white
                  //                 : Colors.black,
                  //             fontFamily: 'Inter',
                  //             fontSize: 13.0,
                  //             fontWeight: FontWeight.normal),
                  //       ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSavedPost(context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if(isInternet){
      final msg =
      jsonEncode({"blog_id": item.id, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}deleteBookmarkPost';
      final client = new http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map data = json.decode(response.body);
      Navigator.of(context).pushNamed("/SavedPage");
    }
    }
}
