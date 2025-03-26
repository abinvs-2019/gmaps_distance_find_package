library gmaps_by_road_distance_calculator;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

enum TravelModes { driving, bicycling, walking }

class ByRoadDistanceCalculator {
  Future<double> getDistance({
    required double startLatitude,
    required double startLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    required TravelModes travelMode,
  }) async {
    try {
      // Convert travel mode to OSRM-compatible profile
      final profile = _convertTravelModeToProfile(travelMode);
      
      // Construct OSRM API URL
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$profile/'
        '$startLongitude,$startLatitude;'
        '$destinationLongitude,$destinationLatitude?overview=false'
      );

      // Make API request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final distanceInMeters = data['routes'][0]['distance'].toDouble();
        return distanceInMeters / 1000; // Convert to kilometers
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating distance: $e');
    }
  }

  String _convertTravelModeToProfile(TravelModes mode) {
    switch (mode) {
      case TravelModes.driving:
        return 'car';
      case TravelModes.bicycling:
        return 'bike';
      case TravelModes.walking:
        return 'foot';
      default:
        return 'car';
    }
  }
}
    totalDistance = totalDistance / 1000; // to km
    return totalDistance
        .toStringAsFixed(2); // Would return 0.0 km on any exception
  }
}
