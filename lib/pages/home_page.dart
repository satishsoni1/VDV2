import 'dart:async';
import 'dart:convert';

import 'package:blog_app/app_theme.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/card_item.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

//import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../appColors.dart';
import '../controllers/home_controller.dart';
import '../controllers/user_controller.dart';
import '../main.dart';
import 'auth.dart';
import 'category_post.dart';
import 'e_news.dart';
import 'live_news.dart';

const String testDevice = 'YOUR_DEVICE_ID';
//* <--------- Main Screen of the app ------------->
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends StateMVC<HomePage> with TickerProviderStateMixin {
  /* static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );

  BannerAd _bannerAd;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {},
    );
  }*/

  // PublisherBannerAd? _bannerAd;
  // final Completer<PublisherBannerAd> bannerCompleter =
  // Completer<PublisherBannerAd>();

  GlobalKey<ScaffoldState>? scaffoldKey;

  // AdSize? adSize;

  HomeController? homeController;

  ScrollController? scrollController;
  TabController? tabController;

  int currentTabIndex = 0;
  var height, width;
  bool showTopTabBar = false;
  String? localLanguage;

  @override
  void initState() {
    super.initState();
    print("Home Page");
    chackNoti();
    //Foreground Firebase message notification listener init state.
    // It's navigation manage when you come from kill state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        onSelectNotification(message.data['id'] ?? 'null');
      }
    });

    getCurrentUser();
    localLanguage = languageCode.value.language;
    currentUser.value.isPageHome = true;
    homeController = HomeController();
    scrollController = ScrollController(initialScrollOffset: 0);
    scrollController!.addListener(scrollControllerListener);
    // _bannerAd = PublisherBannerAd(
    //   adUnitId: 'ca-app-pub-3940256099942544/6300978111',// todo here change dynamic ad id from backend
    //   request: PublisherAdRequest(nonPersonalizedAds: true),
    //   sizes: [AdSize.fullBanner],
    //   listener: AdListener(
    //     onAdLoaded: (Ad ad) {
    //       print('$PublisherBannerAd loaded.');
    //       bannerCompleter.complete(ad as PublisherBannerAd);
    //     },
    //     onAdFailedToLoad: (Ad ad, LoadAdError error) {
    //       ad.dispose();
    //       print('$PublisherBannerAd failedToLoad: $error');
    //       bannerCompleter.completeError(error);
    //     },
    //     onAdOpened: (Ad ad) => print('$PublisherBannerAd onAdOpened.'),
    //     onAdClosed: (Ad ad) => print('$PublisherBannerAd onAdClosed.'),
    //     onApplicationExit: (Ad ad) =>
    //         print('$PublisherBannerAd onApplicationExit.'),
    //   ),
    // );
    // Future<void>.delayed(Duration(seconds: 1), () => _bannerAd?.load());
  }

  scrollControllerListener() {
    if (scrollController!.offset >= height * 0.58) {
      setState(() {
        showTopTabBar = true;
      });
    } else {
      setState(() {
        showTopTabBar = false;
      });
    }
  }

  Future<void> onRefreshData() async {
    languageCode.value = languageCode.value;
    Provider.of<AppProvider>(context, listen: false)
      ..getBlogData()
      ..getCategory();
    setState(() {});
  }

  @override
  void dispose() {
    //  _bannerAd?.dispose();
    //   _bannerAd?.dispose();
    //   _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("In Build home_page.dart");
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return LoadingOverlay(
        isLoading: snapshot.load,
        color: Colors.grey,
        child: Scaffold(
            //backgroundColor: Theme.of(context).cardColor,
            backgroundColor: Color(0xFFF2F2F2),
            key: scaffoldKey,
            drawer: DrawerBuilder(),
            onDrawerChanged: (value) {
              print(
                  "drawer $value ${localLanguage != languageCode.value.language}");
              if (localLanguage != languageCode.value.language) {
                Provider.of<AppProvider>(context, listen: false)
                  ..getBlogData()
                  ..getCategory();
                setState(() {
                  localLanguage = languageCode.value.language;
                });
              }
            },
            appBar: buildAppBar(context),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: onRefreshData,
                  child: SingleChildScrollView(
                    child: ListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      children: <Widget>[
                        _buildTopText(),
                        _buildRecommendationCards(),
                        _buildBottomText(),
                        //_buildTabText(),
                        Consumer<AppProvider>(builder: (context, snapshot, _) {
                          return snapshot.blog == null
                              ? Container()
                              : _buildTabView();
                        }),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  allMessages.value.stayBlessedAndConnected ??
                                      "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.merge(
                                        TextStyle(
                                            color: appThemeModel.value
                                                    .isDarkModeEnabled.value
                                                ? Colors.white
                                                : HexColor("#000000"),
                                            fontFamily: 'Inter',
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                        // SizedBox(height: double.parse(AdSize.fullBanner.height.toString())),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   bottom: 0,
                //   child: FutureBuilder<PublisherBannerAd>(
                //     future: bannerCompleter.future,
                //     builder:
                //         (BuildContext context, AsyncSnapshot<PublisherBannerAd> snapshot) {
                //       Widget child;
                //
                //       switch (snapshot.connectionState) {
                //         case ConnectionState.none:
                //         case ConnectionState.waiting:
                //         case ConnectionState.active:
                //           child = Container();
                //           break;
                //         case ConnectionState.done:
                //           if (snapshot.hasData) {
                //             child = AdWidget(ad: _bannerAd);
                //           } else {
                //             child = Text('Error loading $PublisherBannerAd');
                //           }
                //       }
                //
                //       return Container(
                //         width: _bannerAd?.sizes[0].width.toDouble(),
                //         height: _bannerAd?.sizes[0].height.toDouble(),
                //         child: child,
                //         color: Colors.blueGrey,
                //       );
                //     },
                //   ),
                // ),
              ],
            )),
      );
    });
  }

  buildAppBar(BuildContext context) {
    if (scaffoldKey?.currentState?.isDrawerOpen ?? false) {
      scaffoldKey?.currentState?.openEndDrawer();
    }
    return commonAppBar(context, width: width);
  }

  _buildTopText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Container(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        currentUser.value.name != null
                            ? "${allMessages.value.welcome ?? ""} ${currentUser.value.name ?? ""},"
                            : "${allMessages.value.welcomeGuest ?? ""}",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Inter',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400),
                            ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        allMessages.value.featuredStories ?? "",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Inter',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Consumer<AppProvider>(builder: (context, snapshot, _) {
                  return ButtonTheme(
                    minWidth: 0.1 * constraints.maxWidth,
                    height: 0.04 * height,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(
                            right: 12,
                            left: 12,
                            bottom: 0.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(
                              color: HexColor("#000000"),
                              width: 1.2,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text(
                            allMessages.value.myFeed ?? "",
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: HexColor("#000000"),
                                      fontFamily: 'Inter',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                          ),
                        ),
                        onPressed: () async {
                          bool isInternet =
                              await NetworkHelper.isInternetIsOn();
                          if (isInternet) {
                            if (currentUser.value.photo != null) {
                              snapshot.setLoading(load: true);
                              var url =
                                  "${Urls.baseUrl}getFeed/${currentUser.value.id}";
                              print(url);
                              var result = await http.get(
                                Uri.parse(url),
                              );
                              Map data = json.decode(result.body);
                              print(
                                  "result ${data['data'].length} ${currentUser.value.id} ${languageCode.value.language ?? "null"}");

                              final list = Blog.fromJson(data['data']);

                              for (DataModel item in list.data!)
                                print(
                                    " HOMEPAGE FEED :" + item.title.toString());

                              if (list != null) {
                                snapshot.setLoading(load: false);
                                setState(() {
                                  blogListHolder.clearList();
                                  blogListHolder.setList(list);
                                  blogListHolder.setIndex(0);
                                });
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SwipeablePage(
                                    0,
                                    isFromFeed: true,
                                  ),
                                ));
                              }
                            } else {
                              Navigator.of(context).pushReplacementNamed(
                                  '/AuthPage',
                                  arguments: true);
                            }
                          }
                        }),
                  );
                })
              ],
            );
          },
        ),
      ),
    );
  }

  _buildBottomText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Container(
                  width: 0.6 * constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        allMessages.value.filterByTopics ?? "",
                        style: Theme.of(context).textTheme.bodyText1?.merge(
                              TextStyle(
                                  color: appThemeModel
                                          .value.isDarkModeEnabled.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'Inter',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Consumer<AppProvider>(builder: (context, snapshot, _) {
                  return ButtonTheme(
                    minWidth: 0.1 * constraints.maxWidth,
                    height: 0.04 * height,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(
                            right: 12,
                            left: 12,
                            bottom: 0.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                            side: BorderSide(
                              color: HexColor("#0077ff"),
                              width: 1.2,
                            ),
                          ),
                          backgroundColor: HexColor("#0077ff"),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text(
                            "Visit VD",
                            style: Theme.of(context).textTheme.bodyText1?.merge(
                                  TextStyle(
                                      color: HexColor("#ffffff"),
                                      fontFamily: 'Inter',
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                          ),
                        ),
                        onPressed: () async {
                          bool isInternet =
                              await NetworkHelper.isInternetIsOn();
                          if (isInternet) {
                            if (currentUser.value.phone != null) {
                              var url =
                                  "https://vd.docexa.com/auth?m=${currentUser.value.phone}";
                              print(url);
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            } else {
                              var url = "https://vd.docexa.com/users/login";
                              print(url);
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }
                          }
                        }),
                  );
                })
              ],
            );
          },
        ),
      ),
    );
  }

  //! Top cards . .
  _buildRecommendationCards() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      height: 0.4 * MediaQuery.of(context).size.height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          bool error = false;
          try {
            if ((snapshot.blogList.data?.length ?? 0) == 0) {
              error = true;
            } else {
              error = false;
            }
          } catch (e) {
            error = true;
          }
          if (error) {
            return ListView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[100] ?? Colors.black,
                  highlightColor: Colors.grey[200] ?? Colors.black,
                  child: Container(
                    margin: const EdgeInsets.only(
                        bottom: 20.0, left: 10.0, right: 10.0),
                    height: 0.4 * MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.red,
                    ),
                  ),
                );
              },
              itemCount: 10,
            );
          }
          return (snapshot.blogList.data?.length ?? 0) == 0
              ? ListView.builder(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[100] ?? Colors.black,
                      highlightColor: Colors.grey[200] ?? Colors.black,
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom: 20.0, left: 20.0, right: 10.0),
                        height: 0.4 * MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                  itemCount: 10,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  addAutomaticKeepAlives: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    print(
                        "-------------${snapshot.blogList.data![index].title}-------------${snapshot.blogList.data!.length}");
                    if (snapshot.blogList.data![index].type == 'Ads') {
                      return Container();
                    }
                    return CardItem(snapshot.blogList.data![index], index,
                        snapshot.blogList);
                  },
                  itemCount: snapshot.blogList.data!.length > 10
                      ? 10
                      : snapshot.blogList.data!.length,
                );
        }),
      ),
    );
  }

  _buildTabBar() {
    return Consumer<AppProvider>(builder: (context, snapshot, _) {
      return TabBar(
          indicatorColor: Colors.transparent,
          controller: tabController,
          onTap: setTabIndex,
          isScrollable: true,
          tabs: snapshot.blog!.data!
              .map((e) => Tab(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.name.toString(),
                      style: Theme.of(context).textTheme.bodyText1?.merge(
                            TextStyle(
                                color: e.index == currentTabIndex
                                    ? appThemeModel
                                            .value.isDarkModeEnabled.value
                                        ? Colors.white
                                        : Colors.black
                                    : Colors.grey,
                                fontFamily: GoogleFonts.notoSans().fontFamily,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600),
                          ),
                    ),
                  )))
              .toList());
    });
  }

  setTabIndex(int value) {
    setState(() {
      this.currentTabIndex = value;
    });
  }

  _buildTabText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            allMessages.value.filterByTopics ?? "",
            style: Theme.of(context).textTheme.bodyText1?.merge(
                  TextStyle(
                      color: appThemeModel.value.isDarkModeEnabled.value
                          ? Colors.white
                          : Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
    );
  }

  _buildTabView() {
    return Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
        ),
        child: Consumer<AppProvider>(builder: (context, snapshot, _) {
          int length = 0;
          if (eLiveKey != "0" && eNewsKey != "0") {
            length = snapshot.blog!.data!.length + 2;
          } else if (eLiveKey != "0" || eNewsKey != "0") {
            length = snapshot.blog!.data!.length + 1;
          } else {
            length = snapshot.blog!.data!.length;
          }
          print("length :$length");
          return GridView.count(
              crossAxisCount: 3,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 1.8),
              controller: TrackingScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: snapshot.blog == null
                  ? List.generate(9, (index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[100] ?? Colors.black,
                        highlightColor: Colors.grey[200] ?? Colors.black,
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.red,
                          ),
                        ),
                      );
                    })
                  : List.generate(length, (index) {
                      if (eLiveKey == "0" && eNewsKey != "0") {
                        if (index == snapshot.blog!.data!.length) {
                          return newCategories(
                              title: allMessages.value.eNews ?? "",
                              image: eNewsImage ?? "assets/img/VD512.png",
                              ontap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Enews()));
                              });
                        }
                      } else if (eLiveKey != "0" && eNewsKey == "0") {
                        if (index == snapshot.blog!.data!.length) {
                          return newCategories(
                              title: allMessages.value.liveNews ?? "",
                              image: eLiveImage ?? "assets/img/VD512.png",
                              ontap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LiveNews()));
                              });
                        }
                      } else if (eLiveKey != "0" && eNewsKey != "0") {
                        if (index == snapshot.blog!.data!.length) {
                          return eNewsKey == "0"
                              ? Container()
                              : newCategories(
                                  title: allMessages.value.eNews ?? "",
                                  image: eNewsImage ?? "assets/img/VD512.png",
                                  ontap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Enews()));
                                  });
                        } else if (index == snapshot.blog!.data!.length + 1) {
                          return eLiveKey == "0"
                              ? SizedBox()
                              : newCategories(
                                  title: allMessages.value.liveNews ?? "",
                                  image: eLiveImage ?? "assets/img/VD512.png",
                                  ontap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LiveNews()));
                                  });
                        }
                      }

                      return GestureDetector(
                        onTap: () async {
                          // snapshot.setLoading(load: true);

                          // final msg = jsonEncode({
                          //   "category_id": snapshot.blog!.data![index].id
                          //   //"user_id": currentUser.value.id
                          // });
                          // print(msg);
                          // print(
                          //     "blogCategory.data[index].id ${snapshot.blog!.data![index].id}");
                          // final String url =
                          //     '${Urls.baseUrl}AllBookmarkPost';
                          // final client = new http.Client();
                          // final response = await client.post(
                          //   Uri.parse(url),
                          //   headers: {
                          //     "Content-Type": "application/json",
                          //     'userData': currentUser.value.id.toString(),
                          //     "lang-code":
                          //         languageCode.value.language ?? ''
                          //   },
                          //   body: msg,
                          // );
                          // print(
                          //     "API in home page response ${response.body}");
                          // Map data = json.decode(response.body);
                          // final list = (data['data'] as List)
                          //     .map((i) => new DataModel.fromMap(i))
                          //     .toList();
                          //
                          // // print("List Size for index $index : " +
                          // //     list.length.toString());
                          // snapshot.setLoading(load: false);
                          //
                          // // for (DataModel item in list) {
                          // //   print("item.title ${item.title}");
                          // // }
                          Blog? setList = Blog();
                          for (int i = 0;
                              i < snapshot.blog!.data!.length;
                              i++) {
                            if (snapshot.blog!.data![index].id ==
                                snapshot.blog!.data![i].id) {
                              setList = snapshot.blog!.data![i].blog;
                            }
                          }
                          if (setList != null) {
                            blogListHolder.clearList();
                            blogListHolder.setList(setList);
                            blogListHolder.setIndex(0);
                            DataModel item = blogListHolder.getList().data![0];
                            print("for FB ${item.title}");
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return SwipeablePage(0);
                              }),
                            ).then((value) {
                              blogListHolder.clearList();
                              blogListHolder.setList(snapshot.blogList);
                            });
                          } else {
                            Fluttertoast.showToast(
                                backgroundColor: appMainColor,
                                msg: allMessages.value.noNewsAvilable ?? "");
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              bottom: 5, right: 5, top: 5, left: 5),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //       color: Colors.black38.withOpacity(0.1),
                                    //       blurRadius: 5.0,
                                    //       offset: Offset(0.0, 0.0),
                                    //       spreadRadius: 1.0)
                                    // ],
                                    ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot.blog!.data![index].image,
                                    fit: BoxFit.fitWidth,
                                    cacheKey: snapshot.blog!.data![index].image,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.149,
                                            padding: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black38
                                                        .withOpacity(0.1),
                                                    blurRadius: 5.0,
                                                    offset: Offset(0.0, 0.0),
                                                    spreadRadius: 1.0)
                                              ],
                                            ),
                                            child: Image.asset(
                                              "assets/img/VD512.png",
                                            )),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(snapshot.blog!.data![index].name.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.merge(
                                        TextStyle(
                                            color: appThemeModel.value
                                                    .isDarkModeEnabled.value
                                                ? Colors.white
                                                : HexColor("#000000"),
                                            fontFamily: 'Inter',
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w600),
                                      )),
                            ],
                          ),
                        ),
                      );
                    }));
        }));
  }

  newCategories({String? title, String? image, VoidCallback? ontap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 5, right: 5, top: 5, left: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: ontap,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                // boxShadow: [
                //   BoxShadow(
                //       color: Colors.black38.withOpacity(0.1),
                //       blurRadius: 5.0,
                //       offset: Offset(0.0, 0.0),
                //       spreadRadius: 1.0)
                // ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: image!,
                  fit: BoxFit.fitWidth,
                  cacheKey: image,
                  errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.149,
                      padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38.withOpacity(0.1),
                              blurRadius: 5.0,
                              offset: Offset(0.0, 0.0),
                              spreadRadius: 1.0)
                        ],
                      ),
                      child: Image.asset(
                        "assets/img/VD512.png",
                      )),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(title!,
              style: Theme.of(context).textTheme.bodyText1?.merge(
                    TextStyle(
                        color: appThemeModel.value.isDarkModeEnabled.value
                            ? Colors.white
                            : HexColor("#000000"),
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600),
                  )),
        ],
      ),
    );
  }
}
