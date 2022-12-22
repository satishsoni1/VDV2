import 'dart:async';
import 'dart:convert';
import 'package:blog_app/appColors.dart';
import 'package:blog_app/elements/drawer_builder.dart';
import 'package:blog_app/helpers/network_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;


import '../app_theme.dart';

class BlogAd extends StatefulWidget {
  final bool? showShadow;
  final bool? isFullScreen;
  final double? widthRatio;
  final double? borderRadius;
  final double? horizontalPadding;
  final List<Section>? section;

  BlogAd(  {
    this.showShadow = true,
    this.isFullScreen = false,
    this.widthRatio,
    this.borderRadius,
    this.horizontalPadding,
    this.section
  });

  @override
  _BlogAdState createState() => _BlogAdState();
}

class _BlogAdState extends State<BlogAd> {
  final ChromeSafariBrowser browser =
  new MyChromeSafariBrowser(new MyInAppBrowser());
  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );
  String backImg = '';
  String base = '${Urls.baseServer}';

  slider() {
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_currentPage < (imgList.length - 1)) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.linear,
        );
      }
    });
  }

  List<String> imgList = [];

  @override
  void initState() {
    imgList=[];
    for(int i=0;i<widget.section!.length;i++){
      imgList.add(widget.section![i].location.toString());
      print(widget.section?[i].location);
    }
    backImg=imgList.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      imgList.forEach((imageUrl) {
        precacheImage(NetworkImage(imageUrl), context);
      });
    });
    super.initState();
  }
  Future viewAction(int adID,{int action = 0}) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if(isInternet){
      Map<String, dynamic>    formMap = {
        'userID': currentUser.value.id,
        'AdsID': adID.toString(),
        "action": action.toString()
      };
      try {
        var url = "${Urls.baseUrl}Ads/action";
        print("--${currentUser.value.id}------$adID------call Api ----$action-------");
        var result = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded"
          },
          encoding: Encoding.getByName('utf-8'),
          body: formMap,
        );
        Map data = json.decode(result.body);
        if(result.statusCode == 200){
          print(data);
        }
      } catch (e) {
        print(e);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    print("========== Api view catch-----------");
    print(imgList.length);
    print("========== Api -----------");
    // Timer(Duration(seconds: 3), () {
    //   viewAction(widget.section![_currentPage].adID!.toInt());
    // });
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            imageUrl: base+backImg,
            errorWidget: (context, url, error) =>
                Image.asset("assets/logo.png"),
            fit: BoxFit.cover,
          ),
          Container(
            width: width,
            height: height,
            color: Theme.of(context).cardColor.withOpacity(0.5),
          ),
          GestureDetector(onTap: () async {
            print("====================");
            print(widget.section?[_currentPage].redirectUrl);
            print("====================");
            await browser.open(
                url: Uri.parse(
                  widget.section?[_currentPage].redirectUrl.toString() != '' ? (widget.section![_currentPage].redirectUrl.toString()) : "https://technofox.co.in/",
                ),
                options: ChromeSafariBrowserClassOptions(
                    android: AndroidChromeCustomTabsOptions(
                        addDefaultShareMenuItem: false),
                    ios: IOSSafariOptions(barCollapsingEnabled: true)));
          },
            child: Container(
                height: height,
                child: CarouselSlider.builder(
                  itemCount: imgList.length,
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    scrollPhysics: imgList.length == 1 ? NeverScrollableScrollPhysics() : null,
                    onPageChanged: (index, reason) {
                      backImg = imgList[index];
                      _currentPage=index;
                      setState(() {

                      });
                    },
                    // height: height,
                    // autoPlay: true,
                    aspectRatio: 9 / 18,
                    enlargeCenterPage: true,
                    viewportFraction: imgList.length == 1 ? 0.900 : 0.800,
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.70,
                            imageUrl: base+imgList[index].toString(),
                            errorWidget: (context, url, error) =>
                                Image.asset("assets/logo.png"),
                            fit: BoxFit.cover,
                          )),
                      // Image.network(imgList[index],
                      //     fit: BoxFit.cover)),
                    );
                  },
                )),
          ),
          if(imgList.length != 1)
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: height*0.125),
                  child: Row(
                    children: [
                      Spacer(),
                      ...imgList
                          .map((e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildReferIndicatorItem(
                              e == imgList[_currentPage]
                                  ? appMainColor
                                  : Colors.grey,
                              e == imgList[_currentPage] ? 10 : 8),
                          SizedBox(width: 5),
                        ],
                      ))
                          .toList(),
                      Spacer(),
                    ],
                  ),
                )),
          Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(onTap: () async {
                viewAction(widget.section![_currentPage].adID ?? 0,action: 1);
                print("====================");
                print(widget.section![_currentPage].redirectUrl);
                print("====================");
                await browser.open(
                    url: Uri.parse(
                      widget.section![_currentPage].redirectUrl != '' ? widget.section![_currentPage].redirectUrl.toString() : "https://technofox.co.in/",
                    ),
                    options: ChromeSafariBrowserClassOptions(
                        android: AndroidChromeCustomTabsOptions(
                            addDefaultShareMenuItem: false),
                        ios: IOSSafariOptions(barCollapsingEnabled: true)));
              },child: Container(
                height: height * 0.045,
                width: width*0.30,
                decoration: BoxDecoration(color: appMainColor,borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(vertical: height*0.06),
                child: Center(child: Text(allMessages.value.tap ?? 'Tap Me',style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.merge(
                  TextStyle(
                      color: appThemeModel
                          .value.isDarkModeEnabled.value
                          ? Colors.white
                          : HexColor("#000000"),
                      fontFamily: 'Montserrat',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600),
                ),),),
              ))),
          Positioned(
            top: 40.0,
            left: 15.0,
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _buildReferIndicatorItem(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   final height = MediaQuery.of(context).size.height;
//   final width = MediaQuery.of(context).size.width;
//   return Scaffold(body: Container(
//     decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Theme.of(context).cardColor,
//         boxShadow: widget.showShadow
//         ? [
//         BoxShadow(
//           blurRadius: 5.0,
//           offset: Offset(3.0, 3.0),
//           color: Colors.black.withOpacity(0.05),
//           spreadRadius: 4.0,
//         ),
//         ]
//         : []),
//     child: Center(child: Container(
//       height: height * 0.935,
//       width: width * 0.9335,
//       child: PageView.builder(
//         itemCount: imgList.length,
//         scrollDirection: Axis.horizontal,
//         controller: _pageController,
//         itemBuilder: (context, index) {
//           return Container(
//             // margin: const EdgeInsets.only(left: 6.0, right: 6.0, top: 15.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(5),
//               child: GestureDetector(
//                 onTap: () {
//                   // print(
//                   //     " type here --------->>>>>>. ${appState.homeBannerList.value[index].itemType}");
//                   // if (appState.homeBannerList.value[index].itemType ==
//                   //     "product") {
//                   //   Navigator.of(context).pushNamed("/ItemDetailPage",
//                   //       arguments: appState
//                   //           .homeBannerList.value[index].productModel);
//                   // }
//                   // if (appState.homeBannerList.value[index].itemType ==
//                   //     "category") {
//                   //   Navigator.of(context).pushNamed("/SpecificCategoryPage",
//                   //       arguments:
//                   //       appState.homeBannerList.value[index].category);
//                   // }
//                 },
//                 child: Container(
//                   color: appMainColor,
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: CachedNetworkImage(
//                           width: MediaQuery.of(context).size.width,
//                           height: double.infinity,
//                           imageUrl: imgList[index]?? "",
//                           errorWidget: (context, url, error) =>
//                               Image.asset("assets/logo.png"),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Container(
//                           margin: EdgeInsets.symmetric(vertical: 40),
//                           child: Row(
//                             children: [
//                               Spacer(),
//                               ...imgList.map((e) => Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   _buildReferIndicatorItem(e == imgList[index] ? appMainColor : Colors.grey,e == imgList[index] ? 12 : 10),
//                                   SizedBox(width: 5),
//                                 ],
//                               ))
//                                   .toList(),
//                               Spacer(),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     )),
//   ));
// }
// }
