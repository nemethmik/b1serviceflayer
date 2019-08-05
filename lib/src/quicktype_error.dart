import 'dart:convert';
import 'package:meta/meta.dart';
class B1Error {
  int statusCode;//Manually added for convenience, not coming from SAP B1
  String queryUrl;
  String postBody;
  void setStatusCode(int statusCode,{@required String queryUrl,String postBody}) {
    this.statusCode = statusCode;
    this.queryUrl = queryUrl;
    this.postBody = postBody;
  }
  Error error;
  B1Error({
      this.error,
  });
  factory B1Error.fromJson(String str) => B1Error.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());
  factory B1Error.fromMap(Map<String, dynamic> json) => B1Error(
      error: json["error"] == null ? null : Error.fromMap(json["error"]),
  );
  Map<String, dynamic> toMap() => {
      "error": error == null ? null : error.toMap(),
  };
}

class Error {
    int code;
    Message message;
    Error({
        this.code,
        this.message,
    });
    factory Error.fromJson(String str) => Error.fromMap(json.decode(str));
    String toJson() => json.encode(toMap());
    factory Error.fromMap(Map<String, dynamic> json) => Error(
        code: json["code"] == null ? null : json["code"],
        message: json["message"] == null ? null : Message.fromMap(json["message"]),
    );
    Map<String, dynamic> toMap() => {
        "code": code == null ? null : code,
        "message": message == null ? null : message.toMap(),
    };
}

class Message {
    String lang;
    String value;
    Message({
        this.lang,
        this.value,
    });
    factory Message.fromJson(String str) => Message.fromMap(json.decode(str));
    String toJson() => json.encode(toMap());
    factory Message.fromMap(Map<String, dynamic> json) => Message(
        lang: json["lang"] == null ? null : json["lang"],
        value: json["value"] == null ? null : json["value"],
    );
    Map<String, dynamic> toMap() => {
        "lang": lang == null ? null : lang,
        "value": value == null ? null : value,
    };
}
