import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:osrm/osrm.dart';

class RouteProvider extends ChangeNotifier {
  LatLng from = const LatLng(45.497288, -73.578843);
  LatLng to = const LatLng(45.495150, -73.577253);

  List<LatLng> points = [];

  num distance = 0.0;
  num duration = 0.0;

  Future<void> getRoute() async {
    final osrm = Osrm();
    final options = RouteRequest(
      coordinates: [
        (from.longitude, from.latitude),
        (to.longitude, to.latitude)
      ],
      overview: OsrmOverview.full,
    );

    final route = await osrm.route(options);
    distance = route.routes.first.distance!;
    duration = route.routes.first.duration!;
    points = route.routes.first.geometry!.lineString!.coordinates.map(
      (e) {
        var location = e.toLocation();
        return LatLng(location.lat, location.lng);
      }
    ).toList();

    notifyListeners();
  }

  void updateFrom(String value) {
    // TEST that it's hex
    from = LatLng.fromSexagesimal(value);
    notifyListeners();
  }

  void updateTo(String value) {
    // TEST that it's hex
    to = LatLng.fromSexagesimal(value);
    notifyListeners();
  }


}
