import 'package:blog_app/helpers/helper.dart';
import 'package:blog_app/helpers/urls.dart';
import 'package:blog_app/models/cms_model.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../appColors.dart';
import '../app_theme.dart';

class Cmsdetail extends StatefulWidget {
  CmsModel data;

  Cmsdetail(this.data);

  @override
  _CmsdetailState createState() => _CmsdetailState();
}

class _CmsdetailState extends State<Cmsdetail> {
  @override
  Widget build(BuildContext context) {
    print(widget.data.pageTitle);
    print(widget.data.description);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appMainColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).cardColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.data.pageTitle.toString(),
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                          TextStyle(
                              color: appMainColor,
                              fontFamily: 'Montserrat',
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold),
                        ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    // imageUrl: "https://images.pexels.com/photos/206359/pexels-photo-206359.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                    imageUrl:
                        "${Urls.baseServer}upload/cms/original/${widget.data.image}",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
              SizedBox(
                height: 10,
              ),
              Html(
                data: widget.data.description,
                onLinkTap: (url, context, attributes, element) {
                  try {
                    Fluttertoast.showToast(
                      msg: "Opening News in Web",
                      backgroundColor: appMainColor,
                    );
                    Helper.launchURL(url.toString());
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: "Invalid Link",
                      backgroundColor: appMainColor,
                    );
                  }
                  print("Opening $url...");
                },
                style: {
                  "body": Style(
                    fontSize: FontSize(18.0),
                    fontWeight: FontWeight.bold,
                    color: appThemeModel.value.isDarkModeEnabled.value
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                },
                onImageTap: (src, _, __, ___) {
                  print(src);
                },
                onImageError: (exception, stackTrace) {
                  print(exception);
                },
                onCssParseError: (css, messages) {
                  print("css that errored: $css");
                  print("error messages:");
                  messages.forEach((element) {
                    print(element);
                  });
                },
              ),
              // Text(HtmlCharacterEntities.decode(widget.data.description),style: Theme.of(context).textTheme.bodyText1.merge(
              //   TextStyle(
              //       color: appMainColor,
              //       fontFamily: 'Montserrat',
              //       fontSize: 26.0,
              //       fontWeight: FontWeight.bold),),
              // ),
            ],
          ),
        )),
      ),
    );
  }
}
