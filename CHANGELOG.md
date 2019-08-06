## 1.0.0

- The project was initated with Stagehand, and then a nicely working version is available with this version. Tests have been added as well as an example. Breaking changes are not expected. 

## 1.0.1

- Documentation has been extended significantly.
- Since logins are so important to monitor, a **printLogins** optional bool parameter added to the B1ServiceLayer constructor, which enables printing a line in the console for debugging purposes.
- **executionMilliseconds** property added to B1ServiceLayer to help monitoring performance, which is so crytical in mobile applications.
- The example and some of the test scripts have been adjusted accordingly.

## 1.0.2

- tYES, tNO relocated into a new BoYesNoEnum class.
- BoEnums abstract class was added as a base class for defining typesafe string enumeration types.
