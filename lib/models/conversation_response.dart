// To parse this JSON data, do
//
//     final conversationResponse = conversationResponseFromJson(jsonString);

import 'dart:convert';

ConversationResponse conversationResponseFromJson(String str) =>
    ConversationResponse.fromJson(json.decode(str));

String conversationResponseToJson(ConversationResponse data) =>
    json.encode(data.toJson());

class ConversationResponse {
  ConversationResponse({
    required this.conversation_item_list,
    required this.meta,
    required this.success,
    required this.status,
  });

  List<ConversationItem> conversation_item_list;
  Meta meta;
  bool success;
  int status;

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      ConversationResponse(
        conversation_item_list: List<ConversationItem>.from(
            json["data"].map((x) => ConversationItem.fromJson(x))),
        meta: Meta.fromJson(json["meta"]),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data":
            List<dynamic>.from(conversation_item_list.map((x) => x.toJson())),
        "meta": meta.toJson(),
        "success": success,
        "status": status,
      };
}

class ConversationItem {
  ConversationItem({
    required this.id,
    required this.receiver_id,
    required this.receiver_type,
    required this.shop_id,
    required this.shop_name,
    required this.shop_logo,
    required this.title,
    required this.sender_viewed,
    required this.receiver_viewed,
    required this.date,
  });

  int id;
  int receiver_id;
  String receiver_type;
  int shop_id;
  String shop_name;
  String shop_logo;
  String title;
  int sender_viewed;
  int receiver_viewed;
  DateTime date;

  factory ConversationItem.fromJson(Map<String, dynamic> json) =>
      ConversationItem(
        id: json["id"],
        receiver_id: json["receiver_id"],
        receiver_type: json["receiver_type"],
        shop_id: json["shop_id"],
        shop_name: json["shop_name"],
        shop_logo: json["shop_logo"],
        title: json["title"],
        sender_viewed: json["sender_viewed"],
        receiver_viewed: json["receiver_viewed"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "receiver_id": receiver_id,
        "receiver_type": receiver_type,
        "shop_id": shop_id,
        "shop_name": shop_name,
        "shop_logo": shop_logo,
        "title": title,
        "sender_viewed": sender_viewed,
        "receiver_viewed": receiver_viewed,
        "date": date.toIso8601String(),
      };
}

class Meta {
  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  int currentPage;
  int from;
  int lastPage;
  String path;
  int perPage;
  int to;
  int total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        currentPage: json["current_page"],
        from: json["from"],
        lastPage: json["last_page"],
        path: json["path"],
        perPage: json["per_page"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "from": from,
        "last_page": lastPage,
        "path": path,
        "per_page": perPage,
        "to": to,
        "total": total,
      };
}
