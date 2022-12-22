import 'package:blog_app/appColors.dart';
import 'package:blog_app/pages/club_point.dart';
import 'package:blog_app/pages/messenger_list.dart';
import 'package:blog_app/pages/profile_edit.dart';
import 'package:blog_app/repository/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/my_theme.dart';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:blog_app/helpers/reg_ex_inpur_formatter.dart';
//import 'package:blog_app/repositories/wallet_repository.dart';
import 'package:blog_app/helpers/shimmer_helper.dart';
import 'package:blog_app/custom/toast_component.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:blog_app/pages/recharge_wallet.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/pages/myprofile.dart';
import 'package:blog_app/pages/box_decorations.dart';
import 'package:blog_app/repository/user_repository.dart';

class Profile extends StatefulWidget {
  const Profile();

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  // var name = "Nazmus Joe";
  // var email = "NazmusJoe@gmail.co";
  var incart = "";
  var wishlist = "";
  var ordered = "1";
  int _totalPointCounter = 0;
  String _totalPointCounterString = "...";
  int _earnedPointCounter = 0;
  String _earnedPointCounterString = "...";
  int _pendingPointCounter = 0;
  String _pendingPointCounterString = "...";
  bool is_logged_in = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in == true) {
      fetchAll();
    }
  }

  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  fetchAll() {
    fetchCounters();
    getCurrentUser();
  }

  fetchCounters() async {
    var profileCountersResponse =
        await ProfileRepository().getProfileCountersResponse();
    print(profileCountersResponse);
    _totalPointCounter = profileCountersResponse.total_point;
    _pendingPointCounter = profileCountersResponse.pending_point;
    _earnedPointCounter = profileCountersResponse.earned_point;
    _totalPointCounterString =
        counterText(_totalPointCounter.toString(), default_length: 2);
    _pendingPointCounterString =
        counterText(_pendingPointCounter.toString(), default_length: 2);
    _earnedPointCounterString =
        counterText(_earnedPointCounter.toString(), default_length: 2);

    setState(() {});
  }

  String counterText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (txt != null) {
      if (default_length == 3 && txt.length == 1) {
        leading_zeros = "00";
      } else if (default_length == 3 && txt.length == 2) {
        leading_zeros = "0";
      } else if (default_length == 2 && txt.length == 1) {
        leading_zeros = "0";
      }
    }

    var newtxt = (txt == null || txt == "" || txt == null.toString())
        ? blank_zeros
        : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  reset() {
    _totalPointCounter = 0;
    _totalPointCounterString = "...";
    _earnedPointCounter = 0;
    _earnedPointCounterString = "...";
    _pendingPointCounter = 0;
    _pendingPointCounterString = "...";
    setState(() {});
  }

  onTapLogout(context) async {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return HomePage();
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 2.2,
              width: MediaQuery.of(context).size.width,
              color: appMainColor,
              alignment: Alignment.topRight,
              child: Image.asset(
                "assets/img/background_1.png",
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 100),
              child: SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.only(right: 18),
                        height: 30,
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              color: MyTheme.white,
                              size: 20,
                            )),
                      ),
                    ),

                    // Container(
                    //   margin: EdgeInsets.symmetric(vertical: 8),
                    //   width: MediaQuery.of(context).size.width,height: 1,color: MyTheme.medium_grey_50,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: buildTopSection(),
                    ),
                  ],
                ),
              ),
            ),
            body: RefreshIndicator(
              color: MyTheme.white,
              backgroundColor: appMainColor,
              onRefresh: _onPageRefresh,
              displacement: 10,
              child: CustomScrollView(
                controller: _mainScrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: buildCountersRow(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: buildHorizontalSettings(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: buildSettingAndAddonsVerticalMenu(),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      //   child: buildSettingAndAddonsHorizontalMenu(),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      //   child: buildBottomVerticalCardList(),
                      // ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomVerticalCardList() {
    return Container(
      margin: EdgeInsets.only(bottom: 120, top: 14),
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        children: [
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Image.asset(
                      "assets/img/coupon.png",
                      height: 16,
                      width: 16,
                    ),
                  ),
                  Text(
                    "local.profile_screen_coupons",
                    style: TextStyle(fontSize: 12, color: MyTheme.dark_grey),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Image.asset(
                      "assets/img/favoriteseller.png",
                      height: 16,
                      width: 16,
                    ),
                  ),
                  Text(
                    "local.profile_screen_favorite_seller",
                    style: TextStyle(fontSize: 12, color: MyTheme.dark_grey),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return Filter(
                //     selected_filter: "sellers",
                //   );
                // }));
              },
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Image.asset(
                      "assets/img/shop.png",
                      height: 16,
                      width: 16,
                    ),
                  ),
                  Text(
                    "local.profile_screen_browse_all_sellers",
                    style: TextStyle(fontSize: 12, color: MyTheme.dark_grey),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Container(
            height: 40,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: Image.asset(
                      "assets/img/blog.png",
                      height: 16,
                      width: 16,
                    ),
                  ),
                  Text(
                    "local.profile_screen_blogs",
                    style: TextStyle(fontSize: 12, color: MyTheme.dark_grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalSettings() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) {
              //       return ChangeLanguage();
              //     },
              //   ),
              // );
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/img/bank.png",
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Bank account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          /*InkWell(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) {
              //   return OrderList();
              // }));
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/img/currency.png",
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppLocalizations.of(context).profile_screen_currency,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),*/
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfileEdit();
              })).then((value) {
                onPopped(value);
              });
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/img/edit.png",
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) {
              //       return Address();
              //     },
              //   ),
              // );
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/img/withdraw.png",
                  height: 16,
                  width: 16,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Withdraw",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingAndAddonsHorizontalMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.only(top: 14),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        //color: Colors.blue,
        child: Wrap(
          direction: Axis.horizontal,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 20,
          spacing: 10,
          //mainAxisAlignment: MainAxisAlignment.start,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Container(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width / 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Wallet();
                  }));
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/img/wallet.png",
                      width: 16,
                      height: 16,
                      color: MyTheme.dark_grey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Wallet",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.dark_grey, fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
            Container(
              // color: Colors.pink,
              width: MediaQuery.of(context).size.width / 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MessengerList();
                  }));
                },
                child: Column(
                  children: [
                    Image.asset(
                      "assets/img/messages.png",
                      width: 16,
                      height: 16,
                      color: MyTheme.dark_grey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Messages",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.dark_grey, fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingAndAddonsVerticalMenu() {
    return Container(
      margin: EdgeInsets.only(bottom: 120, top: 14),
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
        children: [
          Visibility(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Wallet();
                      }));
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        alignment: Alignment.center,
                        padding: EdgeInsets.zero),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/wallet.png",
                          width: 16,
                          height: 16,
                          color: MyTheme.dark_grey,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          "My Wallet",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: MyTheme.dark_grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: MyTheme.light_grey,
          ),
          Visibility(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Clubpoint();
                      }));
                    },
                    style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        alignment: Alignment.center,
                        padding: EdgeInsets.zero),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/points.png",
                          width: 16,
                          height: 16,
                          color: MyTheme.dark_grey,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Text(
                          "Earned Points",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: MyTheme.dark_grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: MyTheme.light_grey,
                ),
              ],
            ),
          ),
          Visibility(
            child: Container(
              height: 40,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MessengerList();
                  }));
                },
                style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    alignment: Alignment.center,
                    padding: EdgeInsets.zero),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/img/messages.png",
                      width: 16,
                      height: 16,
                      color: MyTheme.dark_grey,
                    ),
                    SizedBox(
                      width: 24,
                    ),
                    Text(
                      "Messages",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MyTheme.dark_grey, fontSize: 12),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCountersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCountersRowItem(
          _totalPointCounterString,
          "Available Points",
        ),
        buildCountersRowItem(
          _pendingPointCounterString,
          "Pending Points",
        ),
        buildCountersRowItem(
          _earnedPointCounterString,
          "Earned Points",
        ),
      ],
    );
  }

  Widget buildCountersRowItem(String counter, String title) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 14),
      width: MediaQuery.of(context).size.width / 3.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            counter,
            maxLines: 2,
            style: TextStyle(
                fontSize: 16,
                color: MyTheme.dark_grey,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            maxLines: 2,
            style: TextStyle(
              fontSize: 12,
              color: MyTheme.dark_grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopSection() {
    return Container(
      // color: Colors.amber,
      alignment: Alignment.center,
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Container(
            child: InkWell(
              //padding: EdgeInsets.zero,
              onTap: (){
              Navigator.pop(context);
            } ,child:Icon(Icons.arrow_back,size: 25,color: MyTheme.white,), ),
          ),*/
          // SizedBox(width: 10,),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: MyTheme.white, width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/img/placeholder.png',
                    image: "${currentUser.value.photo}",
                    fit: BoxFit.fill,
                  )),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${currentUser.value.name.toString()}",
                style: TextStyle(
                    fontSize: 14,
                    color: MyTheme.white,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    //if user email is not available then check user phone if user phone is not available use empty string
                    "${currentUser.value.email.toString()}",
                    style: TextStyle(
                      fontSize: 12,
                      color: MyTheme.light_grey,
                    ),
                  )),
            ],
          ),
          Spacer(),
          Container(
            width: 70,
            height: 26,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                // 	rgb(50,205,50)
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: MyTheme.white)),
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                onTapLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      automaticallyImplyLeading: false,
      /* leading: GestureDetector(
        child: widget.show_back_button
            ? Builder(
                builder: (context) => IconButton(
                  icon:
                      Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 0.0),
                    child: Container(
                      child: Image.asset(
                        'assets/hamburger.png',
                        height: 16,
                        color: MyTheme.dark_grey,
                      ),
                    ),
                  ),
                ),
              ),
      ),*/
      title: Text(
        "profile_screen_account",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
