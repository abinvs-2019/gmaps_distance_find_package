
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:google_maps_flutter/google_maps_flutter.dart' as Gmap;
import 'package:latlong2/latlong.dart';

enum TravelModes { driving, bicycling, transit, walking }

class DistanceCalculator {
  List<Gmap.LatLng> polylineCoordinates = [];
  // List of coordinates to join

  Distance distance = Distance();

  late poly.PolylinePoints polylinePoints;
  // Create the polylines for showing the route between two places

  Future<String> getDistance(String gmapsApiKey,
      {required double startLatitude,
      required double startLongitude,
      required double destinationLatitude,
      required double destinationLongitude,
      required TravelModes travelMode}) async {
    // Initializing PolylinePoints
    polylinePoints = poly.PolylinePoints();
    // Generating the list of coordinates to be used for
    // drawing the polylines
    print('calling method');
    poly.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
            '$gmapsApiKey', // Google Maps API Key
            poly.PointLatLng(startLatitude, startLongitude),
            poly.PointLatLng(destinationLatitude, destinationLongitude),
            travelMode: travelMode == TravelModes.bicycling
                ? poly.TravelMode.bicycling
                : travelMode == TravelModes.driving
                    ? poly.TravelMode.driving
                    : travelMode == TravelModes.walking
                        ? poly.TravelMode.walking
                        : poly.TravelMode.transit);
    print(result.points);
    print(result.errorMessage);
    print(result.status);
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(Gmap.LatLng(point.latitude, point.longitude));
      }
    } else {
      print('Polylines are emplty');
    }
    return loopIt();
  }

  double totalDistance = 0.0;

  getDistanceFromPointsToPoints(LatLng start, LatLng end) {
    final num km = distance.as(LengthUnit.Kilometer, start, end);
    print(km);
    return km;
  }

// Calculating the total distance by adding the distance
// between small segments
  loopIt() {
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += distance(
          LatLng(polylineCoordinates[i].latitude,
              polylineCoordinates[i].longitude),
          LatLng(polylineCoordinates[i + 1].latitude,
              polylineCoordinates[i + 1].longitude));
    }
    totalDistance = totalDistance / 1000; // to km
    return totalDistance
        .toStringAsFixed(2); // Would return 0.0 km on any exception
  }
}
