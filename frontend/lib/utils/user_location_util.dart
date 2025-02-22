// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

// //This file uses the flutter_background_geolocation: ^4.16.9 package. I decided not to use it as it required to modify the
// //main.dart file heavily

// //This file is to obtain the current location of the user.
// // Do not access any location specific services until the .ready(config) method is done running.
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     // Listen to events (See docs for all 12 available events).
//
//
//
//     // Fired whenever a location is recorded
//     bg.BackgroundGeolocation.onLocation((bg.Location location) {
//       print('[location] - $location');
//     });
//
//     bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
//       print('[motionchange] - $location');
//     });
//
//     bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
//       print('[providerchange] - $event');
//     });
//
//     bg.BackgroundGeolocation.ready(bg.Config(
//         desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//         distanceFilter: 10.0,
//         stopOnTerminate: false,
//         startOnBoot: true,
//         debug: true,
//         logLevel: bg.Config.LOG_LEVEL_VERBOSE
//     )).then((bg.State state) {
//       if (!state.enabled) {
//         bg.BackgroundGeolocation.start();
//       }
//     });
//   }
// }
