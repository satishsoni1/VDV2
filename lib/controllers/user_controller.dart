import 'dart:convert';

import 'package:blog_app/helpers/network_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:blog_app/data/blog_list_holder.dart';
import 'package:blog_app/elements/reset_password_sheet.dart';
import 'package:blog_app/elements/sign_in_bottom_sheet.dart';
import 'package:blog_app/helpers/notification_helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/blog_category.dart';
import 'package:blog_app/pages/SwipeablePage.dart';
import 'package:blog_app/pages/home_page.dart';
import 'package:blog_app/pages/select_categories.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
    as firebase_messaging;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appColors.dart';
import '../app_theme.dart';
import '../main.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../repository/user_repository.dart' as repository;
import 'package:http/http.dart' as http;

SharedPreferences? prefs;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class UserController extends ControllerMVC {
  Users? user = new Users();
  bool? hidePassword = true;
  bool? forgotHidePassword = true;
  bool? loading = false;
  GlobalKey<FormState>? loginFormKey;
  GlobalKey<FormState>? updateFormKey;
  GlobalKey<FormState>? signupFormKey;
  GlobalKey<FormState>? forgetFormKey;
  GlobalKey<FormState>? resetFormKey;
  GlobalKey<ScaffoldState>? scaffoldKey;
  firebase_messaging.FirebaseMessaging? _firebaseMessaging;

  bool _isLoading = false;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );

  UserController() {
    loginFormKey = new GlobalKey<FormState>();
    updateFormKey = new GlobalKey<FormState>();
    signupFormKey = new GlobalKey<FormState>();
    forgetFormKey = new GlobalKey<FormState>();
    resetFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = firebase_messaging.FirebaseMessaging.instance;
    notificationInit();
    _firebaseMessaging?.getToken().then((String? _deviceToken) {
      print("_deviceToken ${_deviceToken}");
      user?.deviceToken = _deviceToken!;
      updateToken();
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void googleLogin(GlobalKey<ScaffoldState> scKey, BuildContext context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      BotToast.showLoading();
      try {
        GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
        print("googleSignInAccount $googleSignInAccount");
        repository.googleLogin(googleSignInAccount!).then((value) async {
          print("value $value");
          if (value != null && value.apiToken != null) {
            await getLanguageFromServer(context);
            if (value.isNewUser ?? false) {
              Navigator.of(scKey.currentContext!)
                  .pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
              Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
                builder: (context) => SelectCategories(
                  isFromDrawer: false,
                ),
              ));
            } else {
              Navigator.of(scKey.currentContext!)
                  .pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
              Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
                builder: (context) => SwipeablePage(
                  0,
                  isFromFeed: true,
                ),
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(repository.allMessages.value.wrongEmailAndPassword
                  .toString()),
            ));
          }
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(repository.allMessages.value.emailNotExist.toString()),
          ));
          BotToast.closeAllLoading();
        }).whenComplete(() {
          BotToast.closeAllLoading();
        });
      } catch (e) {
        BotToast.showText(text: e.toString());
        // BotToast.showCustomText(toastBuilder: (void Function() cancelFunc) {
        //   return Container(height: 10,width: double.infinity,color: Colors.red,);
        // });
      }
    }
  }

  void appleLogin(GlobalKey<ScaffoldState> scKey, BuildContext context,
      {List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      BotToast.showLoading();
      try {
        // 1. perform the sign-in request
        final result = await TheAppleSignIn.performRequests(
            [AppleIdRequest(requestedScopes: scopes)]);
        // 2. check the result
        switch (result.status) {
          case AuthorizationStatus.authorized:
            final appleIdCredential = result.credential;
            final oAuthProvider = OAuthProvider('apple.com');
            /*   final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );*/

            Map<String, dynamic> resultData = {
              "name": (appleIdCredential?.fullName?.givenName ?? "") +
                  (appleIdCredential?.fullName?.familyName ?? ""),
              "email": appleIdCredential?.email ?? null,
              "image": "",
              "apple_token": appleIdCredential?.user,
            };

            repository.appleLogin(resultData).then((value) async {
              print("value $value");
              if (value != null && value.apiToken != null) {
                await getLanguageFromServer(context);
                if (value.isNewUser ?? false) {
                  Navigator.of(scKey.currentContext!)
                      .pushReplacement(MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
                  Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
                    builder: (context) => SelectCategories(
                      isFromDrawer: false,
                    ),
                  ));
                } else {
                  Navigator.of(scKey.currentContext!)
                      .pushReplacement(MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
                  Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
                    builder: (context) => SwipeablePage(
                      0,
                      isFromFeed: true,
                    ),
                  ));
                }
              } else {
                ScaffoldMessenger.of(scKey.currentContext!)
                    .showSnackBar(SnackBar(
                  content: Text(repository
                      .allMessages.value.wrongEmailAndPassword
                      .toString()),
                ));
              }
            }).catchError((e) {
              ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
                content:
                    Text(repository.allMessages.value.emailNotExist.toString()),
              ));
            }).whenComplete(() {
              BotToast.closeAllLoading();
            });
            break;
          case AuthorizationStatus.error:
            BotToast.closeAllLoading();
            ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
              content: Text(result.error.toString()),
            ));
            break;

          case AuthorizationStatus.cancelled:
            BotToast.closeAllLoading();
            ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
              content: Text('Sign in aborted by user'),
            ));
            break;
          default:
            BotToast.closeAllLoading();
            ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
              content: Text('Something went wrong'),
            ));
            break;
        }
      } catch (e) {
        BotToast.showText(text: e.toString());
        // BotToast.showCustomText(toastBuilder: (void Function() cancelFunc) {
        //   return Container(height: 10,width: double.infinity,color: Colors.red,);
        // });
      }
    }
  }

  Future getLatestBlog() async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      blogListHolder.clearList();
      var url = "${Urls.baseUrl}getFeed/${currentUser.value.id}";
      print(url);
      var result = await http.get(
        Uri.parse(url),
      );
      try {
        Map data = json.decode(result.body);
        final list = Blog.fromJson(data['data']);
        if (list != null) {
          blogListHolder.setList(list);
          blogListHolder.setIndex(0);
          BotToast.showText(
              text: "getLatestBlog",
              textStyle: TextStyle(color: Colors.transparent),
              backgroundColor: Colors.transparent,
              contentColor: Colors.transparent);
          await Future.delayed(Duration(microseconds: 500));
        }
      } catch (e) {
        BotToast.showText(text: "getLatestBlog set data --->>> $e");
        print(e);
      }
    }
    return true;
  }

  void login(GlobalKey<ScaffoldState> scKey) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      if (user?.password != "") {
        if (loginFormKey!.currentState!.validate()) {
          loginFormKey!.currentState!.save();
          BotToast.showLoading();
          repository.login(user!).then((value) async {
            await getLatestBlog();
            print("value $value ${value!.apiToken}");
            if (value != null && value.apiToken != null) {
              // await getLanguageFromServer();
              print("in if");
              // Get.offAll(HomePage());
              Navigator.of(scKey.currentContext!).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                  (Route<dynamic> route) => false);
              Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
                builder: (context) => SwipeablePage(
                  0,
                  isFromFeed: true,
                ),
              ));
            } else {
              print("else error");
              // scKey.currentState?.showSnackBar(SnackBar(
              //   content: Text(repository.allMessages.value.wrongEmailAndPassword
              //       .toString()),
              // ));
            }
          }).catchError((e) {
            print("catch error");
            // scKey.currentState?.showSnackBar(SnackBar(
            //   content:
            //       Text(repository.allMessages.value.emailNotExist.toString()),
            // ));
          }).whenComplete(() {
            BotToast.closeAllLoading();
          });
        } else {
          print("login validate fail");
        }
      } else {
        repository.login(user!).then((value) {
          if (value != null && value.apiToken != null) {
            Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
              builder: (context) => SwipeablePage(
                0,
                isFromFeed: true,
              ),
            ));
            // Navigator.of(scKey.currentContext)
            //     .pushReplacementNamed('/MainPage', arguments: false);
          } else {
            ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
              content: Text(repository.allMessages.value.wrongEmailAndPassword
                  .toString()),
            ));
          }
        }).catchError((e) {
          ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
            content:
                Text(repository.allMessages.value.emailNotExist.toString()),
          ));
        }).whenComplete(() {
          BotToast.closeAllLoading();
        });
      }
    }
  }

  void register(GlobalKey<ScaffoldState> scKey) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      if (signupFormKey!.currentState!.validate()) {
        print("dfsa");
        signupFormKey!.currentState!.save();
        BotToast.showLoading();
        repository.register(user!).then((value) {
          if (value != null && value.apiToken != null) {
            Navigator.of(scKey.currentContext!)
                .pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
            // Navigator.of(scKey.currentContext).push(MaterialPageRoute(builder: (context) => SwipeablePage(0),
            Navigator.of(scKey.currentContext!).push(MaterialPageRoute(
              builder: (context) => SelectCategories(
                isFromDrawer: false,
              ),
            ));
          } else {
            ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
              content: Text(repository.allMessages.value.wrongEmailAndPassword
                  .toString()),
            ));
          }
        }).catchError((e) {
          ScaffoldMessenger.of(scKey.currentContext!).showSnackBar(SnackBar(
            content:
                Text(repository.allMessages.value.emailNotExist.toString()),
          ));
        }).whenComplete(() {
          BotToast.closeAllLoading();
        });
      }
    }
  }

  void forgetPassword(
      GlobalKey<ScaffoldState> scKey, BuildContext context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      if (forgetFormKey!.currentState!.validate()) {
        forgetFormKey!.currentState!.save();
        BotToast.showLoading();
        repository.forgetPassword(user!).then((value) async {
          BotToast.closeAllLoading();
          if (value != null) {
            Fluttertoast.showToast(
                msg: "OTP sent to your email address",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIos: 5,
                backgroundColor: appMainColor,
                textColor: Colors.white);
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                context: scKey.currentContext!,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: ResetPasswordSheet(scKey, user!.email.toString()),
                  );
                });
          } else {
            print("else ");
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Error",
                  style: Theme.of(context).textTheme.bodyText1?.merge(
                        TextStyle(
                            color: appThemeModel.value.isDarkModeEnabled.value
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'Inter',
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal),
                      ),
                ),
                content: Text("Something Went Wrong Try Again Later."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(allMessages.value.ok.toString()),
                  ),
                ],
              ),
            );
          }
        }).whenComplete(() {});
      }
    }
  }

  void resetPassword(GlobalKey<ScaffoldState> scKeys, String email) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      if (resetFormKey!.currentState!.validate()) {
        resetFormKey!.currentState!.save();
        repository.resetPassword(user!, email).then((value) async {
          if (value != null && value == true) {
            showCustomDialog(
                context: scKeys.currentContext,
                text: "Your password reset successfully",
                title: "Success",
                onTap: () {
                  Navigator.pop(scKeys.currentContext!);
                  Navigator.pop(scKeys.currentContext!);
                  Navigator.pop(scKeys.currentContext!);
                });
          } else {
            // showCustomDialog(
            //     context: scKeys.currentContext,
            //     text: "Something went wrong",
            //     title: "Error",
            //     onTap: () {
            //       Navigator.pop(scKeys.currentContext!);
            //     });
          }
        }).whenComplete(() {});
      }
    }
  }

  showCustomDialog(
      {BuildContext? context,
      String? title,
      String? text,
      VoidCallback? onTap}) async {
    await showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text(
          title.toString(),
          style: Theme.of(context).textTheme.bodyText1?.merge(
                TextStyle(
                    color: appThemeModel.value.isDarkModeEnabled.value
                        ? Colors.white
                        : Colors.black,
                    fontFamily: 'Inter',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
        ),
        content: Text(text.toString()),
        actions: <Widget>[
          TextButton(
            onPressed: onTap,
            child: Text(allMessages.value.ok.toString()),
          ),
        ],
      ),
    );
  }

  void profile(GlobalKey<ScaffoldState> scKeys) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      if (updateFormKey!.currentState!.validate()) {
        updateFormKey!.currentState!.save();
        repository.update(user!).then((value) {
          if (value != null && value.apiToken != null) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(scKeys.currentContext!).showSnackBar(SnackBar(
              content:
                  Text(repository.allMessages.value.profileUpdated.toString()),
            ));
          }
        }).catchError((e) {
          ScaffoldMessenger.of(scKeys.currentContext!).showSnackBar(SnackBar(
            content:
                Text(repository.allMessages.value.emailNotExist.toString()),
          ));
        }).whenComplete(() {});
      }
    }
  }

  void updateLanguage(BuildContext context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      repository.updateLanguage().then((value) {
        if (value != null && value.apiToken != null) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(repository.allMessages.value.profileUpdated.toString()),
          ));
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist.toString()),
        ));
      }).whenComplete(() {});
    }
  }

  void changePassword(BuildContext context,
      {required String conPass,
      required String newPass,
      required String oldPass}) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      repository
          .changePassword(context,
              oldPass: oldPass, newPass: newPass, conPass: conPass)
          .then((value) {})
          .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(repository.allMessages.value.emailNotExist.toString()),
        ));
      }).whenComplete(() {});
    }
  }

  getLanguageFromServer(BuildContext context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      await repository.getLocalText().then((value) {
        if (value != null) {
          repository.allMessages.value = value;
          print("repository ${repository.allMessages.value.skip}");
        }
      }).catchError((e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("--->>$e<<--- getLanguageFromServer----->>>> " +
              (repository.allMessages.value.noLanguageFound).toString()),
        ));
      }).whenComplete(() {});
    }
  }

  getAllAvialbleLanguages(BuildContext context) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      await repository.getAllLanguages().then((value) {
        if (value != null) {
          repository.allLanguages = value;
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('getAllAvialbleLanguages --->>>' +
              repository.allMessages.value.noLanguageFound.toString()),
        ));
      }).whenComplete(() {});
    }
  }

  getCMS({String lng = 'en'}) async {
    bool isInternet = await NetworkHelper.isInternetIsOn();

    if (isInternet) {
      await repository.getCMS(lng).then((value) {
        if (value != null) {
          repository.allCMS = value;
        }
      }).catchError((e, BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('getCMS --->>>' +
              (repository.allMessages.value.noLanguageFound.toString())),
        ));
      }).whenComplete(() {});
    }
  }

  void updateToken() async {
    repository
        .updateToken(user!)
        .then((value) {})
        .catchError((e) {})
        .whenComplete(() {});
  }

  Future<void> notificationInit() async {
    await Firebase.initializeApp();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('logo');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    chackNoti();
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (value) async {
      //   final prefs = await SharedPreferences.getInstance();
      //   await prefs.setString('notification', value.toString());
      //   Phoenix.rebirth(navigatorKey.currentState!.context);
      // },
    );
    Future<void> _firebaseMessagingBackgroundHandler(
        firebase_messaging.RemoteMessage message) async {
      print('Handling a background message ${message.messageId}');
      await Firebase.initializeApp();
      showNotificationWithDefaultSound(message);
    }

    firebase_messaging.FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
    firebase_messaging.FirebaseMessaging.instance
        .getInitialMessage()
        .then((message) {
      if (message != null && message.data['id'] != null) {
        onSelectNotification(
            message.data == null ? 'null' : message.data['id'].toString());
      }
    });
    firebase_messaging.FirebaseMessaging.onMessage
        .listen((firebase_messaging.RemoteMessage message) async {
      if (message.notification != null) {
        showNotificationWithDefaultSound(message);
      }
    });
    firebase_messaging.FirebaseMessaging.onMessageOpenedApp
        .listen((firebase_messaging.RemoteMessage message) async {
      // BotToast.showText(text: "onMessageOpenedApp");
      if (message.notification != null && message.data['id'] != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('notification', message.data['id'].toString());
          Phoenix.rebirth(navigatorKey.currentState!.context);
        });
      }
    });
  }
}

Future onSelectNotification(String payload) async {
  /// todo here handele Notification navigation
  print('click =$payload');
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('notification');
  // BotToast.showText(text: "onSelectNotification");
  if (payload != 'null') {
    bool isInternet = await NetworkHelper.isInternetIsOn();
    if (isInternet) {
      var url = "${Urls.baseUrl}blog-details/$payload";
      print(url);
      var result = await http.get(
        Uri.parse(url),
      );
      Map data = json.decode(result.body);
      print(
          "result ${data['data'].length} ${currentUser.value.id} ${languageCode.value.language ?? "null"}");
      final list = Blog.fromJson(data['data']);
      list.nextPageUrl == 'Notification';
      for (DataModel item in list.data!)
        print("Notification FEED :" + item.title.toString());
      if (list != null) {
        blogListHolder.clearList();
        blogListHolder.setList(list);
        blogListHolder.setIndex(0);
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => SwipeablePage(
            0,
            isFromFeed: true,
          ),
        ));
      }
    }
  }
}
