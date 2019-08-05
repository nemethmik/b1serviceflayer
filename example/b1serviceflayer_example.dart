import 'dart:convert';
import 'package:b1serviceflayer/b1serviceflayer.dart';

main() async {
  const url = "http://hana93srv:50001/b1s/v1/";
  const user = "manager";
  const pwd ="123qwe";
  const companyDB ="SBODEMOUS";
  final b1s = B1ServiceLayer(B1Connection(serverUrl: url, 
    companyDB: companyDB, userName: user, password: pwd),printLogins: true);
  try {
    print("Logging in ...");
    await b1s.loginAsync().timeout(const Duration(seconds: 10));

    print("Querying activities ...");
    String activitiesJson = await b1s.queryAsync("Activities");
    Map<String, dynamic> activitiesMap = json.decode(activitiesJson);
    List<dynamic> activityList = activitiesMap["value"];
    print('${activityList.length} activities returned in ${b1s.exetutionMilliseconds} ms');
    activityList.forEach((activity){
      print('Activity ${activity["ActivityCode"]} Completed ${activity["Status"]} Notes ${activity["Notes"]} ');
    });

    print("Updating activity ...");
    int activityCodeToComplete = activityList[0]["ActivityCode"];
    activityList[0]["Status"] = -3;
    activityList[0]["Notes"] = "Completed on ${DateTime.now()}";
    await b1s.updateAsync(entityName: "Activities($activityCodeToComplete)",
      entityJSON: json.encode(activityList[0]));

    print("Fetching updated activity ...");
    String activityJson = await b1s.queryAsync("Activities($activityCodeToComplete)");
    Map<String, dynamic> activityMap = json.decode(activityJson);
    print('Activity ${activityMap["ActivityCode"]} Completed ${activityMap["Status"]} Notes ${activityMap["Notes"]} in ${b1s.exetutionMilliseconds} ms');

    print("Adding a new activity ...");
    activityJson = await addActivity(b1s, 12);
    activityMap = json.decode(activityJson);
    print('Activity created with code ${activityMap["ActivityCode"]} Notes ${activityMap["Notes"]} in ${b1s.exetutionMilliseconds} ms');

    print("Deleting the new activity ...");
    activityCodeToComplete = activityMap["ActivityCode"];
    await b1s.deleteAsync(entityName: "Activities($activityCodeToComplete)", errorWhenDoesntExist: true);

    print("Querying activities with newly added activity...");
    activitiesJson = await b1s.queryAsync("Activities");
    activitiesMap = json.decode(activitiesJson);
    activityList = activitiesMap["value"];
    print('Number of activities ${activityList.length} returned in ${b1s.exetutionMilliseconds} ms');
    activityList.forEach((activity){
      print('Activity ${activity["ActivityCode"]} Completed ${activity["Status"]} Notes ${activity["Notes"]} ');
    });

    print("Logging out ...");
    await b1s.logoutAsync();
  } on B1Error catch(exception) {
      print("Exception is B1Error (${exception.statusCode}) ${exception.error.message.value} (${exception.error.code}) for Query ${exception.queryUrl}");
      print("Payload ${exception.postBody}");
  } catch(exception,stackTrace) {
    print(exception); print(stackTrace);
  }
}
Future<String> addActivity(B1ServiceLayer b1s, int userId) async {
  final Map<String,dynamic> activityData = {};
  //Subject:-1, ActivityType: -1 /*General*/, Status: -2 /*NotStarted, -3=Completed*/,
  activityData["Notes"] = "A new job to do";
  activityData["ActivityDate"] = "${DateTime.now()}";
  activityData["ActivityTime"] = "08:08:08"; //Activity creation date/time
  activityData["StartDate"] =  "${DateTime(2019,9,7)}"; //Automatically convert Dates and Times to strings in POST/PUT/PATCH
  activityData["StartTime"] = "10:10"; //UTC 0 offset, not the local time :(
  activityData["Details"] = "${DateTime.now()}: more explanation";
  activityData["ActivityType"] = -1;
  activityData["Activity"] = cn_Task;
  activityData["Priority"] = "pr_High";
  activityData["PersonalFlag"] = tNO;
  activityData["DurationType"] = "du_Hours"; 
  activityData["Duration"] = 48.0;
  activityData["HandledBy"] =  userId; //A user number
  return await b1s.createAsync(entityName: "Activities",
    entityJSON: json.encode(activityData));
}