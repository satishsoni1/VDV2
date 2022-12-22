import 'package:blog_app/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blog_app/helpers/shared_value_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:blog_app/models/clubpoint_response.dart';
import 'package:blog_app/models/clubpoint_to_wallet_response.dart';

class ClubpointRepository {
  Future<ClubpointResponse> getClubPointListResponse(
      {@required page = 1}) async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/clubpoint/get-list?page=$page");
    print("url(${url.toString()}) access token (Bearer ${access_token.$})");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${access_token.$}",
        "App-Language": app_language.$
      },
    );
    // print(response.body.toString());
    return clubpointResponseFromJson(response.body);
  }

  Future<ClubpointToWalletResponse> getClubpointToWalletResponse(
      @required int id) async {
    var post_body = jsonEncode({
      "id": "${id}",
    });
    Uri url = Uri.parse("${AppConfig.BASE_URL}/clubpoint/convert-into-wallet");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${access_token.$}",
          "App-Language": app_language.$
        },
        body: post_body);

    return clubpointToWalletResponseFromJson(response.body);
  }
}
