import 'package:flutter/material.dart';

// Walking, escalator, elevator, stairs.
//
class IndoorAccessibilityPage extends StatefulWidget {
  const IndoorAccessibilityPage({super.key});

  @override
  IndoorAccessibilityState createState() => IndoorAccessibilityState();
}

class IndoorAccessibilityState extends State<IndoorAccessibilityPage> {
  bool isMobilityImpaired = false;

  //will be used for testing
  bool getMobilityStatus() {
    return isMobilityImpaired;
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
              color: Colors.grey, // Line color
              thickness: 2, // Line thickness
              indent: 10, // Left padding
              endIndent: 10, // Right padding
            ),
            Row(
              children: [
                Text('Requires mobility considerations: $isMobilityImpaired'),
                Checkbox(
                  value: isMobilityImpaired,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isMobilityImpaired = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
          ], //end of children. If you wish to add more options. Add it before the end of the brackets.
        ),
      ),
    );
  }
}

//just to test how it looks inside of the app. Uncomment when necessary if adding additional options.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //used for
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IndoorAccessibilityPage(),
    );
  }
}