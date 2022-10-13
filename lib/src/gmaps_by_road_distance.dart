import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

mixin DistanceMethods {

   List<LatLng> polylineCoordinates = [];
  // List of coordinates to join

  late PolylinePoints polylinePoints;
  // Create the polylines for showing the route between two places

  Future<String> getDistance(String gmapsApiKey,
      {required double startLatitude,
      required double startLongitude,
      required double destinationLatitude,
      required double destinationLongitude,
      required TravelMode travelMode}) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      '$gmapsApiKey', // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: travelMode,
    );
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    return await loopIt();
  }

  double totalDistance = 0.0;

// Calculating the total distance by adding the distance
// between small segments
  loopIt() async {
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += await coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    return totalDistance.toStringAsFixed(2); // Would return 0.0 km on any exception
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}