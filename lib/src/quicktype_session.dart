import 'dart:convert';
//Generated with https://app.quicktype.io/ from assets/login_response.json
class Session {
    final String odataMetadata;
    final String sessionId;
    final String version;
    final int sessionTimeout;
    Session({
        this.odataMetadata,
        this.sessionId,
        this.version,
        this.sessionTimeout,
    });
    factory Session.fromJson(String str) => Session.fromMap(json.decode(str));
    String toJson() => json.encode(toMap());
    factory Session.fromMap(Map<String, dynamic> json) => Session(
        odataMetadata: json["odata.metadata"] == null ? null : json["odata.metadata"],
        sessionId: json["SessionId"] == null ? null : json["SessionId"],
        version: json["Version"] == null ? null : json["Version"],
        sessionTimeout: json["SessionTimeout"] == null ? null : json["SessionTimeout"],
    );
    Map<String, dynamic> toMap() => {
        "odata.metadata": odataMetadata == null ? null : odataMetadata,
        "SessionId": sessionId == null ? null : sessionId,
        "Version": version == null ? null : version,
        "SessionTimeout": sessionTimeout == null ? null : sessionTimeout,
    };
}
