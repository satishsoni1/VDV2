import 'dart:convert';

import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/read_blog.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../appColors.dart';

const int maxFailedLoadAttempts = 3;

class SwipeablePage extends StatefulWidget {
  final int index;
  final bool isFromFeed;
  SwipeablePage(this.index, {this.isFromFeed = false});

  @override
  _SwipeablePageState createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage> {
//  PageController pageController;
  PreloadPageController? pageController;
  double? height, width;
  int currentPage = 0;
  // InterstitialAd? _interstitialAd;
  // static final AdRequest request = AdRequest(
  //   testDevices: testDevice != null ? <String>[testDevice] : null,
  //   keywords: <String>['foo', 'bar'],
  //   contentUrl: 'http://foo.com/bar.html',
  //   nonPersonalizedAds: true,
  // );
  bool _interstitialReady = false;
  bool isLoading = false;
  bool isLastPage = false;
  @override
  void initState() {
    print("-00-0-00-090-0-09-090-90-9-090-90-9");
    if ((blogListHolder.getList().data?.length ?? 0) == 0) {
      Fluttertoast.showToast(
          msg: "Blog not available",
          backgroundColor: appMainColor,
          gravity: ToastGravity.TOP);
      Navigator.pop(context);
    }
    // pageController = PageController(initialPage: widget.index);
    pageController = PreloadPageController(initialPage: widget.index);
    currentPage = widget.index;
    pageController?.addListener(listener);
    // if (blogListHolder.getList().length == 1) {
    //   Fluttertoast.showToast(msg: "Last News",backgroundColor: appMainColor,);
    // }
    // MobileAds.instance.initialize().then((InitializationStatus status) {
    //   print('Initialization done: ${status.adapterStatuses}');
    //   MobileAds.instance
    //       .updateRequestConfiguration(RequestConfiguration(
    //       tagForChildDirectedTreatment:
    //       TagForChildDirectedTreatment.unspecified))
    //       .then((value) {
    //     createInterstitialAd();
    //   });
    // });
  }

  // void createInterstitialAd() {
  //   _interstitialAd ??= InterstitialAd(
  //     adUnitId: InterstitialAd.testAdUnitId,
  //     request: request,
  //     listener: AdListener(
  //       onAdLoaded: (Ad ad) {
  //         print('${ad.runtimeType} loaded.');
  //         _interstitialReady = true;
  //       },
  //       onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //         print('${ad.runtimeType} failed to load: $error.');
  //         ad.dispose();
  //         _interstitialAd = null;
  //         createInterstitialAd();
  //       },
  //       onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
  //       onAdClosed: (Ad ad) {
  //         print('${ad.runtimeType} closed.');
  //         ad.dispose();
  //         createInterstitialAd();
  //       },
  //       onApplicationExit: (Ad ad) =>
  //           print('${ad.runtimeType} onApplicationExit.'),
  //     ),
  //   )..load();
  // }

  listener() {
    if (pageController!.position.atEdge) {
      if (pageController!.position.pixels == 0) {
        setState(() {
          isLoading = false;
        });
        // Fluttertoast.showToast(msg: "T",backgroundColor: appMainColor,);
      } else {
        if (blogListHolder.getList().nextPageUrl != 'Notification') {
          setState(() {
            isLoading = true;
          });
          getLatestBlog(blogListHolder.getList().nextPageUrl);
        } else if (blogListHolder.getList().nextPageUrl != null) {
          setState(() {
            isLoading = true;
          });
          getLatestBlog(blogListHolder.getList().nextPageUrl);
        } else {
          Fluttertoast.showToast(
            msg: "Last News",
            backgroundColor: appMainColor,
          );
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future getLatestBlog(String? nextPageUrl) async {
    var url = nextPageUrl.toString();
    var result;
    print(url);
    try {
      result = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "lang-code": languageCode.value.language ?? ''
        },
      );
    } on Exception catch (e) {
      print(e);
    }
    if (widget.isFromFeed == false && result.statusCode == 200) {
      print('------');
      Map<String, dynamic> data = json.decode(result.body);
      BlogCategory category = BlogCategory.fromMap(data);
      setState(() {
        Blog? setList = blogListHolder.getList();
        for (int k = 0; k < (category.data?.length ?? 0); k++) {
          for (int i = 0;
              i < (category.data?[k].blog?.data?.length ?? 0);
              i++) {
            setList.data!.add(category.data![k].blog!.data![i]);
          }
        }

        Blog finalData = Blog();
        finalData = category.data![currentPage].blog!;
        finalData.data = setList.data!;
        blogListHolder.clearList();
        blogListHolder.setList(finalData);
        print('--------');
        isLoading = false;
      });
    } else if (widget.isFromFeed == true && result.statusCode == 200) {
      print('------');
      Map<String, dynamic> data = json.decode(result.body);
      Blog category = Blog.fromJson(data['data']);
      setState(() {
        Blog? setList = blogListHolder.getList();
        for (int i = 0; i < (category.data?.length ?? 0); i++) {
          setList.data!.add(category.data![i]);
        }
        Blog finalData = Blog();
        finalData = category;
        finalData.data = setList.data!;
        blogListHolder.clearList();
        blogListHolder.setList(finalData);
        print('--------');
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Last News",
        backgroundColor: appMainColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          color: HexColor("#323232"),
          child: PreloadPageView.builder(
            itemBuilder: (ctx, index) {
              if (blogListHolder.getList().data![index].title != null &&
                  (blogListHolder.getList().data![index].section?.length ??
                          0) ==
                      0) {
                return ReadBlog(blogListHolder.getList().data![index],
                    onUpSwip: (DragUpdateDetails value) {
                  if (value.delta.dy < 0) {
                    if (blogListHolder.getList().data!.length == 1) {
                      Fluttertoast.showToast(
                        msg: "Last News",
                        backgroundColor: appMainColor,
                      );
                    } else {
                      pageController?.animateToPage(
                        index + 1,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.linear,
                      );
                    }
                  } else if (value.delta.dy > 0) {
                    pageController?.animateToPage(
                      index - 1,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.linear,
                    );
                  }
                });
              } else {
                return ReadBlog(blogListHolder.getList().data![index],
                    onUpSwip: (DragUpdateDetails value) {});
              }
            },
            itemCount: blogListHolder.getList().data!.length,
            scrollDirection: Axis.vertical,
            preloadPagesCount: 0,
            // reverse: true,
            //allowImplicitScrolling: false,
            physics: CustomPageViewScrollPhysics(parent: null),
            controller: pageController,
            pageSnapping: true,
            onPageChanged: (value) {
              if (value % defaultAdsFrequency.value == 0) {
                int adIndex = 0;
                if ((blogListHolder.getList().data![value].section?.length ??
                        0) ==
                    0) {
                  if (value > defaultAdsFrequency.value) {
                    for (int i = 0; i < adList.value.length; i++) {
                      if (blogListHolder
                              .getList()
                              .data![value - defaultAdsFrequency.value]
                              .id ==
                          adList.value[i].id) {
                        if ((i + 1) < adList.value.length) {
                          adIndex = i + 1;
                        } else {
                          adIndex = 0;
                        }
                        break;
                      }
                    }
                  }
                  blogListHolder
                      .getList()
                      .data!
                      .insert(value, adList.value[adIndex]);
                  setState(() {});
                }
              }
              // if((value+1) % 5 == 0){
              //   print('-----------');
              //   int leftBlog = blogListHolder.getList().total! - (value + 1);
              //   Fluttertoast.showToast(msg: "${leftBlog.toString()} unread stories below",backgroundColor: appMainColor,);
              // }
              if (_interstitialReady) {
                // _interstitialAd?.show();
                _interstitialReady = false;
              } else {
                // _interstitialAd = null;
                // createInterstitialAd();
              }
              print("---------------");
              print("page change");
              currentUser.value.isNewUser = false;
              blogListHolder.setIndex(value);
              // currentUser.value =
              //     Users.fromJSON(json.decode(prefs.get('current_user')));
              currentPage = value;
              if (value == (blogListHolder.getList().data!.length - 1)) {
                isLastPage = true;
              } else {
                isLastPage = false;
              }
              setState(() {});
            },
          ),
        ),
        if (isLoading && isLastPage)
          Align(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(),
          )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    // _interstitialAd?.dispose();
    pageController?.removeListener(listener);
    pageController?.dispose();
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}
