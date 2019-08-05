import 'dart:convert';
import 'package:test/test.dart';
import 'package:b1serviceflayer/b1serviceflayer.dart';
import 'logindetailsfortests.dart' as conf;
void main() {
  group("Low Level SL Activity Queries",(){
    final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
      companyDB: conf.companyDB, userName: conf.user, password: conf.pwd));
    test("QueryAllActivities", () async {
      try {
        final queryResponseJSON = await b1s.queryAsync("Activities?\$select=ActivityCode,HandledByEmployee,Details");
        Map<String, dynamic> queryResponseMap = json.decode(queryResponseJSON);
        print("Execution millis ${b1s.exetutionMilliseconds}");
        expect(queryResponseMap.isNotEmpty,isTrue);
        expect(queryResponseMap["value"][0]["ActivityCode"], greaterThan(0));
      } catch(e,stackTrace) {
        if(e is B1Error) {
          print("Exception is B1Error (${e.statusCode}) ${e.error.message.value} (${e.error.code}) for Query ${e.queryUrl} Payload ${e.postBody}");
        } else {
          print(e); print(stackTrace);
        }
        expect(e,isNull);
      }
    });
  });
}