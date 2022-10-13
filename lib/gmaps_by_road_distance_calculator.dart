library gmaps_by_road_distance_calculator;

import 'package:gmaps_by_road_distance_calculator/src/gmaps_by_road_distance.dart';

import 'src/enums.dart';

class DistanceCalulator with DistanceMethods {
  @override
  Future<String> getDistance(String gmapsApiKey,
      {required double startLatitude,
      required double startLongitude,
      required double destinationLatitude,
      required double destinationLongitude,
      required TravelModes travelMode}) async {
    return await super.getDistance(gmapsApiKey,
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLatitude,
        travelMode: TravelModes.driving);
  }
}

