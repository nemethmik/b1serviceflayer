A library for Dart developers that makes [SAP BusinessOne](https://www.sap.com/products/business-one.html)(B1) Service Layer (SL) programming a lot simpler than using plain http package. B1 is one of the most popular information systems for small and mid sized companies. It runs on Microsoft SQL Server as well as on SAP HANA. SL is available only for the HANA version. B1 is a commercial product, and if you want to be a developer, you should contact a SAP Partner or SAP to become a partner. This Dart package is only for developers who are part of this community. If you work for a company that already has B1, this package could be very helpful, too, for building custom applications, since then you are entitled to use SL.
[Official Service Layer documentation](https://help.sap.com/doc/0d2533ad95ba4ad7a702e83570a21c32/9.3/en-US/Working_with_SAP_Business_One_Service_Layer.pdf) is available only if you have an S user ID. On the other hand, a six part [Service Layer API video](https://www.youtube.com/watch?v=zaF_i7x9-s0&list=PLMdHXbewhZ2QsgYSICRQuoL8lkoEHjNzS&index=22) is publicly available.

The f in the name was inspired by the name sqflite.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

SAP, SAP Business One are registered trademarks of [SAP](https://www.sap.com/corporate/en/company.html)  

## Usage

For a full working example review the example folder as well as the nice collection of automated Dart test scripts in the test folder.
Here is a typical skeleton of an application using the functionality of the package:

```dart
import 'dart:convert';
import 'package:b1serviceflayer/b1serviceflayer.dart';

main() async {
  ...
  final b1s = B1ServiceLayer(B1Connection(serverUrl: url, 
    companyDB: companyDB, userName: user, password: pwd));
  try {    
    await b1s.loginAsync().timeout(const Duration(seconds: 10));
    ...
    String activitiesJson = await b1s.queryAsync("Activities");
    Map<String, dynamic> activitiesMap = json.decode(activitiesJson);
    ...
    await b1s.updateAsync(entityName: "Activities($activityCodeToComplete)",
      entityJSON: json.encode(activityList[0]));
    ...
    String activityJson = await b1s.queryAsync("Activities($activityCodeToComplete)");
    ...
    activityJson =   return await b1s.createAsync(entityName: "Activities",
      entityJSON: json.encode(activityData));
    ...
    await b1s.deleteAsync(entityName: "Activities($activityCodeToComplete)",
      errorWhenDoesntExist: true);
    ...
    await b1s.logoutAsync();
  } on B1Error catch(exception) {
      print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl}");
      print("Payload ${exception.postBody}");
  } catch(exception,stackTrace) {
    print(exception); print(stackTrace);
  }
}
```
All SL invocation is performed via the regular, and brilliant, Dart [http](https://pub.dev/packages/http) package.
All functions return a Future, which can be used with the regular await keywords in an async body; this is the reason all function names is suffixed with Async as reminder, that these should be invoket with await, or the classic Future handling ways.

The main class is **B1ServiceLayer**, which requires a **B1Connection** object. The B1Connection is initialiyed with the four mandatory SL login parameters.
Here is the list of the functions:
- **loginAsync** the library automatically calls login when the session is expired after 30 minutes. So, all subsequent calls of the same service layer object use the same connection, but after 30 minutes, a relogin is automatically performed. 
- **queryAsync** returns a list of objects or a single one, depending on the query string.
- **createAsync** creates an B1 entity object in B1, and returns the full details of the created object.
- **updateAsync** updates a B1 entity object. Make sure to pass only the values that you really want to update, otherwise you may overwrite some valuable data by mistake.
- **deleteAsync** deletes a B1 entity object. Very few objects are allowed to be deleted in SAP. Activities are very good for tests, since they are deletable.
- **logoutAsync** Sessions are automatically timeouted in B1 SL, so calling logout is required only when the user is changed.

Only *queryAsync* and *createAsync* have return value, a JSON string, which can be parsed with the dart **json.decode** function into a **Map<String,dynamic>**. 
The functions *createAsync* and *updateAsync* are expecting JSON strings as input parameters. The **json.encode** function can be used to concvert Map<String,dynamic> objects into JSON strings.
These functions are meant for rudimentary JSON communication, they don't parse the JSON string, except the error responses. This layer gives the ultimate performance, as much as possible with the SL and Dart infrastructure. If you want a higher level of convenience you can use JSON Dart conversion generators. For example, the B1Error class was generated with [quicktype](https://app.quicktype.io), but other tools can be used either. Pay attention, however that the B1 JSON structures are big, and a performance may be a problem with these code generators.  

In future versions additional functions are added for batch execution, image uploading.

You can use the Future's **timeout** to control the tolerable duration in your application. I was experimenting with using the *connectionTimeout* of the HttpClient of dart:io, but the Future timeout is a lot more convenient.
When SL returns an error response, B1ServiceLayer functions throw **B1Error**. Upon timeout or network errors the corresponding exceptions are thrown by the underlying Dart machinery. B1Error has a nice bunch of properties for error analysis, which makes programming clean.

## Performance
Here is a log of the sample application from the example folder:
```
Logging in ...
Querying activities ...
9 activities returned in 5274 ms
Activity 8 Completed -3 Notes Completed on 2019-08-05 21:17:13.951161 in 53 ms
Activity created with code 15 Notes A new job to do in 147 ms
Querying activities with newly added activity...
Number of activities 9 returned in 102 ms
```
The first operation was slow, even after an explicit login, but then the performance was quite acceptable.

## License
The license is an open source BSD license as suggested by the [Dart package publishing documentation](https://dart.dev/tools/pub/publishing), since Dart itself has BSD license. 

See the [LICENSE.md](https://github.com/nemethmik/b1serviceflayer/blob/master/LICENSE.md) file.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/nemethmik/b1serviceflayer
