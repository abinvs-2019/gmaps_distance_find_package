import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gmaps_by_road_distance_calculator/gmaps_by_road_distance_calculator.dart';

class ClaculateDistance {
  DistanceCalulator distanceCalulator = DistanceCalulator();

  getDistance() async {
    var distanceInKm = await distanceCalulator.getDistance('API_KEY',
        startLatitude: 28.657030, // Starting latittude
        startLongitude: 28.613448, // Start longitude
        destinationLatitude: 77.243118, // Destination latitide
        destinationLongitude: 77.232304, // Destination longitude
        travelMode: TravelMode.bicycling);
    return distanceInKm;
  }
}
