import 'package:blog_app/models/blog_category.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class ReadBlogScreenshot extends StatefulWidget {
  final DataModel item;
  ReadBlogScreenshot(this.item);

  @override
  _ReadBlogScreenshotState createState() => _ReadBlogScreenshotState();
}

class _ReadBlogScreenshotState extends State<ReadBlogScreenshot> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Image.network(
            widget.item.bannerImage[0],
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.item.title ?? 'title',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Text(
                      parse(widget.item.description ?? "").body?.text ?? 'disc',
                      style: TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.w100),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/google_play.png',
                        height: 50,
                        width: 75,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Image.asset(
                        'assets/img/VD512.png',
                        height: 50,
                        width: 75,
                      ),
                      Spacer(),
                      Image.asset(
                        'assets/img/VD512.png',
                        height: 60,
                        width: 50,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/img/VD512.png',
                        height: 50,
                        width: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
