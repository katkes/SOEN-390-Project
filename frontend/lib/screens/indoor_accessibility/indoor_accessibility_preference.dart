//This page is a widget which contains the ability to mention any disabilities
//by the user which requires additional help/considerations when forming indoor
//navigation routes
//for the purpose of indoor navigation, there only needs to be the consideration
//for if the user has impaired mobility since that is the factor which will
//determine if the user will either use the escelators/stairs or the elevators.
//Additionally, the state is persisted by using the sharedPreferences package
//Functions were set in place to setting, loading and retrieving the state
//other files should call the getMobilityStatusPreference() function to access
//the state variable. This is the API

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndoorAccessibilityPage extends StatefulWidget {
  const IndoorAccessibilityPage({super.key});

  @override
  IndoorAccessibilityState createState() => IndoorAccessibilityState();
}

class IndoorAccessibilityState extends State<IndoorAccessibilityPage> {
  bool _isMobilityImpaired = false;
  //the key itself should be private for security reasons and data consistency (avoiding data corruption)
  //however, the value will be made accessible globally.
  static const String _mobilityKey = 'mobility_impaired';
  int _setStateCount = 0;

  bool getMobilityStatus() {
    //necessary for UI and UI testing
    return _isMobilityImpaired;
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load, save and get the mobility preference from shared_preferences API
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMobilityImpaired = prefs.getBool(_mobilityKey) ?? false;
      print(_isMobilityImpaired);
    });
  }

  Future<void> _savePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mobilityKey, value);
  }

  //this is the function other files should call to obtain the mobility preference state
  static Future<bool> getMobilityStatusPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_mobilityKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Accessibility'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PREFERENCES", style: TextStyle(fontSize: 15)),
            const Divider(
              color: Colors.grey,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            //if you wish to add more specifications for disabilities, add another row() widget as a child of the column() widget.
            Row(
              children: [
                Text('Requires mobility considerations: $_isMobilityImpaired'),
                Checkbox(
                  value: _isMobilityImpaired,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isMobilityImpaired = newValue ?? false;
                      _setStateCount++;
                    });
                    _savePreference(_isMobilityImpaired);
                  },
                ),
              ],
            ),
          ], //end of children. If you wish to add more options. Add it before the end of the brackets.
        ),
      ),
    );
  }

  int getSetStateCount() {
    return _setStateCount;
  }
}

//just to test how it looks inside of the app. Uncomment when necessary if adding additional options.
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   //used for
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: IndoorAccessibilityPage(),
//     );
//   }
// }
