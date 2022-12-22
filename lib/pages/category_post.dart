import 'dart:convert';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/bottom_card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';

//* <----------- Search Blog Page -------------->

class CategoryPostPage extends StatefulWidget {
  final int useHeroWidget;

  CategoryPostPage(this.useHeroWidget);

  @override
  _CategoryPostPageState createState() => _CategoryPostPageState();
}

class _CategoryPostPageState extends State<CategoryPostPage> {
  TextEditingController? searchController;
  Blog blogList = Blog();
  bool _isLoading = false;
  bool _isFound = true;
  var height, width;

  @override
  initState() {
    currentUser.value.isPageHome = false;
    getLatestBlog();
    super.initState();
    searchController = TextEditingController();
    
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if(isInternet){
      _isLoading = true;
      final msg = jsonEncode(
          {"category_id": widget.useHeroWidget, "user_id": currentUser.value.id});
      final String url = '${Urls.baseUrl}AllBookmarkPost';
      final client = new http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          'userData': currentUser.value.id.toString(),
          "lang-code": languageCode.value.language ?? ''
        },
        body: msg,
      );
      Map data = json.decode(response.body);
      final list = Blog.fromJson(data['data']);
      setState(() {
        print(list);
        blogListHolder.clearList();
        blogListHolder.setList(list);
        blogList = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return LoadingOverlay(
      isLoading: _isLoading,
      color: Colors.grey,
      child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          drawer: DrawerBuilder(),
          onDrawerChanged: (value) {
            if (!value) {
              setState(() {});
            }
          },
          appBar: commonAppBar(context,width:width),
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).cardColor,
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 20.0),
                          child: Text(
                            allMessages.value.categoryPost.toString(),
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: appThemeModel
                                              .value.isDarkModeEnabled.value
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Inter',
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.w800),
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: _isFound
                            ? Column(
                                children: blogList.data!
                                    .map((e) => BottomCard(
                                          e,
                                          blogList.data!.indexOf(e),
                                          blogList,
                                          isTrending: false,
                                          ontap: () {},
                                        ))
                                    .toList(),
                              )
                            : Column(
                                children: [
                                  Text(
                                    allMessages.value
                                        .noResultsFoundMatchingWithYourKeyword
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.merge(
                                          TextStyle(
                                              color: appThemeModel.value
                                                      .isDarkModeEnabled.value
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontFamily: 'Inter',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
AppBar commonAppBar(BuildContext context, {width, bool isProfile = false}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Theme.of(context).canvasColor,
    automaticallyImplyLeading: false,
    title: LayoutBuilder(builder: (contextname, constraints) {
      return GestureDetector(
        onTap: () {
          Scaffold.of(contextname).openDrawer();
        },
        child: Row(
          children: [
            
            Padding(
              padding: const EdgeInsets.only(right: 23.0),
              child: Image.asset(
                "assets/img/menu.png",
                fit: BoxFit.none,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            Image.asset(
              "assets/img/vd.png",
              width: 0.3 * width,
              fit: BoxFit.contain,
            ),
            Spacer(),
            GestureDetector(
              child: Image.asset(
                "assets/img/search.png",
                width: 0.06 * width,
                color: appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : Colors.black,
              ),
              onTap: () {
                Navigator.pushNamed(context, '/SearchPage');
              },
            ),
            SizedBox(
              width: 0.044 * constraints.maxWidth,
            ),
            Container(
              width: 0.08 * constraints.maxWidth,
              height: 0.08 * constraints.maxWidth,
              child: GestureDetector(
                onTap: () async{
                  if(isProfile){
                  var url = "https://vd.docexa.com/auth?m=";
                  url = "$url""${currentUser.value.phone ?? ""}";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
                  
                    
                    //Navigator.of(context)
                    //    .pushNamed('/UserProfile', arguments: true);
                  }else{
                    const url = "https://vd.docexa.com/users/login";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
                   // Navigator.of(context)
                   //     .pushNamed('/AuthPage', arguments: true);
                  }
                },
                child: Hero(
                  tag: 'photo',
                  child: CircleAvatar(
                    backgroundImage: currentUser.value.photo != null &&
                        currentUser.value.photo != ''
                        ? NetworkImage(currentUser.value.photo)
                        : AssetImage('assets/img/VD512.png')
                    as ImageProvider,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
  );
}
