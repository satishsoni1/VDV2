// To parse this JSON data, do
//
//     final profileCountersResponse = profileCountersResponseFromJson(jsonString);

import 'dart:convert';

ProfileCountersResponse profileCountersResponseFromJson(String str) =>
    ProfileCountersResponse.fromJson(json.decode(str));

String profileCountersResponseToJson(ProfileCountersResponse data) =>
    json.encode(data.toJson());

class ProfileCountersResponse {
  ProfileCountersResponse({
    required this.total_point,
    required this.pending_point,
    required this.earned_point,
  });

  int total_point;
  int pending_point;
  int earned_point;

  factory ProfileCountersResponse.fromJson(Map<String, dynamic> json) =>
      ProfileCountersResponse(
        total_point: json["total_point"],
        pending_point: json["pending_point"],
        earned_point: json["earned_point"],
      );

  Map<String, dynamic> toJson() => {
        "total_point": total_point,
        "pending_point": pending_point,
        "earned_point": earned_point,
      };
}
