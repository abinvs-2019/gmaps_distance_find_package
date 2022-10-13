library gmaps_by_road_distance_calculator;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gmaps_by_road_distance_calculator/src/gmaps_by_road_distance.dart';

class DistanceCalulator with DistanceMethods {
  @override
  Future<String> getDistance(String gmapsApiKey,
      {required double startLatitude,
      required double startLongitude,
      required double destinationLatitude,
      required double destinationLongitude,
      required TravelMode travelMode}) async {
    return await super.getDistance(gmapsApiKey,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLatitude,
        travelMode: travelMode);
  }
}
