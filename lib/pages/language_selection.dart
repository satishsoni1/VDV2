import 'dart:convert';
import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/providers/app_provider.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appColors.dart';
import '../app_theme.dart';

class LanguageSelection extends StatefulWidget {
  final isInHomePage;
  LanguageSelection({this.isInHomePage = false});
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  bool _userLog = false;
  UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    getAllAvialbleLanguages();
  }

  String? helpLang;
  getAllAvialbleLanguages() async {
    print("allLanguages ${allLanguages.length}");
    if (!widget.isInHomePage) {
      helpLang = '';
    } else {
      helpLang = languageCode.value.name.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
              ),
              Image.asset(
                "assets/img/VD_512_transparent.png",
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 60,
              ),
              Text(
                allMessages.value.chooseYourLanguage ?? "Choose your language",
                style: TextStyle(color: appThemeModel.value.isDarkModeEnabled.value ? Colors.white : Colors.black, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                allMessages.value.chooseYourLanguage2 ?? "भाषा जा चयन कीजिये",
                style: TextStyle(color: appThemeModel.value.isDarkModeEnabled.value ? Colors.white : Colors.black, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 3.3),
                itemCount: allLanguages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      BotToast.showLoading();
                      languageCode.value = allLanguages[index];
                      Provider.of<AppProvider>(context, listen: false)
                        ..getBlogData()
                        ..getCategory();
                      await userController.getCMS(lng: languageCode.value.language.toString());
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("defalut_language",
                          json.encode(languageCode.value.toJson()));
                      prefs.setString("local_data",
                          json.encode(allMessages.value.toJson()));
                      await userController.getLanguageFromServer(context);
                      BotToast.cleanAll();
                      if (!widget.isInHomePage) {
                        Navigator.pushReplacementNamed(context, '/AuthPage');
                      } else {
                        if (currentUser.value.name != null) {
                          userController.updateLanguage(context);
                        }
                        Navigator.pop(context, false);
                        Navigator.pop(context, true);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        left: Helper.rightHandLang
                                .contains(languageCode.value.language)
                            ? index % 2 != 0
                                ? 30
                                : 5
                            : index % 2 == 0
                                ? 30
                                : 5,
                        right: !Helper.rightHandLang
                                .contains(languageCode.value.language)
                            ? index % 2 != 0
                                ? 30
                                : 5
                            : index % 2 == 0
                                ? 30
                                : 5,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[400]!,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: helpLang == allLanguages[index].name.toString()
                            ? appMainColor
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          allLanguages[index].name.toString(),
                          style: TextStyle(
                            color:
                                helpLang == allLanguages[index].name.toString()
                                    ? Colors.white
                                    : appMainColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
