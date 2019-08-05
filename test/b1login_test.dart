import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import "package:http/http.dart" as http;
import 'package:b1serviceflayer/b1serviceflayer.dart';
import 'logindetailsfortests.dart' as conf;

void main() {
  group("B1SL_LoginTestSeries", () {
    test("SuccessfulLogin",() async {
      // final b1s = B1Services(serverUrl: ipAddress + url, companyDB: companyDB, userName: user, password: pwd);
      final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
        companyDB: conf.companyDB, userName: conf.user, password: conf.pwd));
      try {
        final sessionId = await b1s.loginAsync().timeout(const Duration(seconds: 15));
        print("Execution time ${b1s.exetutionMilliseconds}");
        expect(sessionId.b1connection,isNotNull);
      } on B1Error catch(exception) {
        print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl}");
        print("Payload ${exception.postBody}");
        expect(exception,isNull);
      } on http.Response catch(exception) {
        print("Exception is HTTP.Response ${exception.body}");
        expect(exception,isNull);
      } catch(exception,stackTrace) {
        print(exception);
        print(stackTrace);
        expect(exception,isNull);
      }
    }); 
    test("LoginAttemptWithInvalidUser",() async {
      // final b1s = B1Services(serverUrl: ipAddress + url, companyDB: companyDB, userName: "krikszkraksz", password: pwd);
      final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
        companyDB: conf.companyDB, userName: "krikszkraksz", password: conf.pwd));
      try {
        final sessionId = await b1s.loginAsync();
        expect(sessionId,isNull);
      } catch(exception) {
        if(exception is B1Error) {
          print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl} Payload ${exception.postBody}");
        }
        expect(exception is B1Error,isTrue);
      }
    }); 
    test("LoginAttemptWithInvalidURL", () async {
      //(401) Invalid session. (301)
      final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url + "krikszkraksz",
        companyDB: conf.companyDB, userName: conf.user, password: conf.pwd));
      try {
        await b1s.loginAsync();
        expect(false,isTrue);
      } catch(exception) {
        if(exception is B1Error) {
          print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl} Payload ${exception.postBody}");
        }
        expect(exception is B1Error,isTrue);
      }
    });
    test("LoginAttemptWithInvalidCompanyDB", () async {
      final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
        companyDB: "krikszkraksz", userName: conf.user, password: conf.pwd));
      try {
        await b1s.loginAsync();
        expect(false,isTrue);
      } catch(exception) {
        if(exception is B1Error) {
          print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl} Payload ${exception.postBody}");
        }
        expect(exception is B1Error,isTrue);
      }
    });
    test("LoginAttemptWithInvalidPassword", () async {
      final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
        companyDB: conf.companyDB, userName: conf.user, password: "krikszkraksz"));
      try {
        await b1s.loginAsync();
      } catch(exception) {
        if(exception is B1Error) {
          print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl} Payload ${exception.postBody}");
        }
        expect(exception is B1Error,isTrue);
      }
    });
    test("LoginAttemptWithFaultyIPAddress", () async {
      //This is a long timeout error because of the underlying network layer's timeout
      final b1s = B1ServiceLayer(B1Connection(serverUrl: "http://192.168.250.92:50001" + conf.url,
        companyDB: conf.companyDB, userName: conf.user, password: conf.pwd));
      try {
        await b1s.loginAsync().timeout(const Duration(seconds: 5));
      } catch(error) {
        print(error);
        expect(error,isNotNull);
      }
    },timeout: Timeout(Duration(minutes: 5)));
    test("Login with HTTPClient",() async {
      //This is just a fun experiment with using the low level HttpClient
      try {
        final String postBody = '{"UserName":"${conf.user}", "Password":"${conf.pwd}", "CompanyDB":"${conf.companyDB}"}';
        final String queryUrl = conf.ipAddress + conf.url + "Login";
        //final String queryUrl = "http://192.168.250.92:50001" + url + "Login";
        final HttpClient client = HttpClient()..connectionTimeout = Duration(seconds: 15);
        final HttpClientRequest request = await client.postUrl(Uri.parse(queryUrl));
        request.write(postBody);
        final HttpClientResponse response = await request.close();
        dynamic responseBodyText = await _getResponseBody(response);
        print(responseBodyText);
        expect(responseBodyText, isNotNull);
        expect(responseBodyText.isNotEmpty, isTrue);
      } catch(error,stackTrace) {
        print(error);
        print(stackTrace);
        expect(error,isNull);
      }
    });
  });
}
Future<dynamic> _getResponseBody(HttpClientResponse response) {
  StringBuffer responseBody = StringBuffer();
  Completer completer = Completer();
  response.transform(utf8.decoder).listen((String onData){
    responseBody.write(onData);
  }, onDone: ()=> completer.complete(responseBody.toString()));
  return completer.future;
}
