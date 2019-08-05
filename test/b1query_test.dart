import 'package:test/test.dart';
import 'package:b1serviceflayer/b1serviceflayer.dart';
import 'logindetailsfortests.dart' as conf;

void main() {
  group("Low Level SL Tests",() {
    final b1s = B1ServiceLayer(B1Connection(serverUrl: conf.ipAddress + conf.url,
      companyDB: conf.companyDB, userName: conf.user, password: conf.pwd));
    test("ErrorHandlingForInvalidPropertyName", () async {
      try {
        await b1s.queryAsync("Items?\$select=ItemCodeX,ItemName");
      } catch(e) {
        if(e is B1Error) {
          print("Exception is B1Error (${e.statusCode}) ${e.error.message.value} (${e.error.code}) for Query ${e.queryUrl} Payload ${e.postBody}");
        }
        const expectedErrorCode = -1000; //Property ItemCodeX of Item is invalid
        expect(b1s.b1Error.error.code, equals(expectedErrorCode));
      }
    });
    test("ErrorHandlingForInvalidDocStatusCode", () async {
      try {
        await b1s.queryAsync("PurchaseOrders?\$filter=DocumentStatus eq 'bost_OpenX'");
      } catch(e) {
        if(e is B1Error) {
          print("Exception is B1Error (${e.statusCode}) ${e.error.message.value} (${e.error.code}) for Query ${e.queryUrl} Payload ${e.postBody}");
        }
        const expectedErrorCode = -1013; // Invalid item name bost_OpenX in Enum BoStatus The valid names are: bost_Open-O, bost_Close-C, bost_Paid-P, bost_Delivered-D
        expect(b1s.b1Error.error.code, equals(expectedErrorCode));
      }
    });
  });
}