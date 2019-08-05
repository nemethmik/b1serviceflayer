import 'dart:async';
import 'dart:io';
import 'dart:convert';
import "package:meta/meta.dart";
import "package:http/http.dart" as http;
import "./quicktype_session.dart";
import "./quicktype_error.dart";
class B1Connection {
  final String serverUrl;
  final String userName;
  final String password;
  final String companyDB;
  int timeoutInSeconds;
  Session get b1session => _b1session; Session _b1session;
  String get b1Cookies => _b1Cookies; String _b1Cookies;
  DateTime get loginTime => _loginTime; DateTime _loginTime;
  B1Connection({@required this.serverUrl, @required this.userName, @required this.password, @required this.companyDB, this.timeoutInSeconds});
  bool get isSessionExpired => loginTime == null || b1session == null || (DateTime.now().millisecondsSinceEpoch - loginTime.millisecondsSinceEpoch) >= (b1session.sessionTimeout * 60 * 1000);
  _setSession(Session session,String cookies) {
    _b1session = session;
    //b1session.sessionTimeout ??= 30 * 60 * 1000; // Same as if b1session.sessionTimeout == null then session.sessionTimeout = value
    _loginTime = DateTime.now();
    _b1Cookies = cookies;
  }
}
class B1ServiceLayer {
  final B1Connection b1connection;
  String get queryUrl => _queryUrl; String _queryUrl;
  http.Response get queryResponse => _queryResponse; http.Response _queryResponse;
  B1Error get b1Error => _b1Error; B1Error _b1Error;
  bool get hasError => b1Error != null;
  B1ServiceLayer(this.b1connection);
  Future<B1ServiceLayer> loginAsync() async {
    _b1Error = null;
    _queryUrl = b1connection.serverUrl + "Login";
    String postBody = '{"UserName":"${b1connection.userName}", "Password":"${b1connection.password}", "CompanyDB":"${b1connection.companyDB}"}';
    if(b1connection.timeoutInSeconds == null) {
      _queryResponse = await http.post(queryUrl,body:postBody);
    } else {
    }
    if(queryResponse.statusCode == HttpStatus.ok) {
      b1connection._setSession(Session.fromJson(queryResponse.body),queryResponse.headers["set-cookie"]); 
      //loginResponse.headers["set-cookie"] is empty in a browser (client)
      //b1session.setLoggedIn(loginResponse.headers["set-cookie"], loginResponse.data.SessionTimeout);
      //print("B1SLServices.loginAsync:" + queryResponse.body);
    } else {
      if(queryResponse.body != null) {
        try { 
          _b1Error = B1Error.fromJson(queryResponse.body) 
            ..statusCode = queryResponse.statusCode
            ..postBody = postBody
            ..queryUrl = queryUrl;
          throw b1Error;
        } finally{}
      }
      throw queryResponse;
    }
    return this;
  }
  Future<bool> logoutAsync() async {
    if(b1connection.isSessionExpired) { 
      return true;
    } else {
      _queryUrl = b1connection.serverUrl + "Logout";
      _b1Error = null;  
      _queryResponse = await http.get(queryUrl, headers: {HttpHeaders.cookieHeader: b1connection.b1Cookies});
      if(queryResponse.statusCode == HttpStatus.noContent) {
        b1connection._loginTime = null; //Mark logged out
        return true;
      } else {
        if(queryResponse.body != null) {
          try{
            _b1Error = B1Error.fromJson(queryResponse.body) 
              ..statusCode = queryResponse.statusCode
              ..queryUrl = queryUrl;
            throw b1Error;
          }finally{}
        }
        throw queryResponse;
      }
    }
  }
  Future<String> queryAsync(String queryString,{bool errorWhenNotFound = false}) async {
    if(b1connection.isSessionExpired) { await this.loginAsync();}
    _queryUrl = b1connection.serverUrl + queryString;
    _b1Error = null;  
    _queryResponse = await http.get(queryUrl, headers: {HttpHeaders.cookieHeader: b1connection.b1Cookies});
    if(queryResponse.statusCode == HttpStatus.ok) {
      return queryResponse.body;
    } else {
      if(queryResponse.body != null) {
        if(queryResponse.statusCode == HttpStatus.notFound && !errorWhenNotFound) return null; 
        _b1Error = B1Error.fromJson(queryResponse.body) 
          ..statusCode = queryResponse.statusCode
          ..queryUrl = queryUrl;
        throw b1Error;
      }      
      throw queryResponse;
    }
  }
  Future<String> createAsync({@required String entityName, String entityJSON}) async {
    if(b1connection.isSessionExpired) {await loginAsync();}
    _queryUrl = b1connection.serverUrl + entityName;
    _b1Error = null;
    _queryResponse = await http.post(queryUrl,body: entityJSON, headers: {HttpHeaders.cookieHeader: b1connection.b1Cookies});
    if(queryResponse.statusCode == HttpStatus.created) {
      return queryResponse.body;
    } else {
      if(queryResponse.body != null) {
        try {
          _b1Error = B1Error.fromJson(queryResponse.body) 
            ..statusCode = queryResponse.statusCode
            ..queryUrl = queryUrl
            ..postBody = entityJSON;
          throw b1Error;
        } finally {}
      }
      throw queryResponse;
    }
  }
  Future<void> updateAsync({@required String entityName, String entityJSON}) async  {
    if(b1connection.isSessionExpired){ await loginAsync();}
    _queryUrl = b1connection.serverUrl + entityName;
    _b1Error = null;  
    _queryResponse = await http.patch(queryUrl,body:entityJSON, headers: {HttpHeaders.cookieHeader: b1connection.b1Cookies});
    if(queryResponse.statusCode == HttpStatus.noContent) {
    } else {
      if(queryResponse.body != null) {
        _b1Error = B1Error.fromJson(queryResponse.body)
          ..setStatusCode(queryResponse.statusCode,queryUrl: queryUrl,postBody: entityJSON);
        throw b1Error;
      }
      throw queryResponse;
    }
  }
  Future<void> deleteAsync({@required String entityName,bool errorWhenDoesntExist = false}) async {
    if(this.b1connection.isSessionExpired) {await loginAsync();}
    _queryUrl = b1connection.serverUrl + entityName;
    _queryResponse = await http.delete(queryUrl,headers: {HttpHeaders.cookieHeader: b1connection.b1Cookies});
    _b1Error = null;  
    if(queryResponse.statusCode == HttpStatus.noContent) {
    } else {
      if(queryResponse.body != null) {
        _b1Error = B1Error.fromJson(queryResponse.body)
          ..setStatusCode(queryResponse.statusCode,queryUrl: queryUrl);
        var throwError = true;
        if(b1Error.error.code == -2028 && !errorWhenDoesntExist) {
          throwError = false;
        }
        if(throwError) {throw b1Error;}
        else {return null;}
      }
      throw queryResponse;
    }
  }  
}
