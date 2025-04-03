library gmaps_by_road_distance_calculator;

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:async';
import 'dart:convert';



enum TravelModes { driving, bicycling, trnasit, walking }


class ByRoadDistanceCalculator {
  final Distance _distance = Distance();
  final List<LatLng> _points = [];
  final StreamController<double> _controller = StreamController<double>();
  double _totalDistance = 0.0;

  // Original functionality (maintained)
  double calculateDistance(List<LatLng> points) {
    _totalDistance = _sumDistance(points);
    return _totalDistance / 1000;
  }

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

  // New feature: Polyline decoding
  static List<LatLng> decodePolylineString(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    double lat = 0, lng = 0;

    while (index < encoded.length) {
      int char, shift = 0, result = 0;
      do {
        char = encoded.codeUnitAt(index++) - 63;
        result |= (char & 0x1F) << shift;
        shift += 5;
      } while (char >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        char = encoded.codeUnitAt(index++) - 63;
        result |= (char & 0x1F) << shift;
        shift += 5;
      } while (char >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // New feature: GPS file parsing
  List<LatLng> parseGPX(String gpxContent) {
    final document = XmlDocument.parse(gpxContent);
    return document.findAllElements('trkpt').map((node) {
      return LatLng(
        double.parse(node.getAttribute('lat')!),
        double.parse(node.getAttribute('lon')!),
      );
    }).toList();
  }

  List<LatLng> parseKML(String kmlContent) {
    final document = XmlDocument.parse(kmlContent);
    final coordinates = document
        .findAllElements('coordinates')
        .first
        .text
        .trim()
        .split(RegExp(r'\s+'));
    return coordinates.map((coord) {
      final parts = coord.split(',');
      return LatLng(double.parse(parts[1]), double.parse(parts[0]));
    }).toList();
  }

  // New feature: Real-time updates
  Stream<double> get distanceUpdates => _controller.stream;

  void addPoint(LatLng point) {
    if (_points.isNotEmpty) {
      _totalDistance += _distance(_points.last, point);
      _controller.add(_totalDistance / 1000);
    }
    _points.add(point);
  }

  void clearPoints() {
    _points.clear();
    _totalDistance = 0.0;
  }

  // Helper method
  double _sumDistance(List<LatLng> points) {
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _distance(points[i], points[i + 1]);
    }
    return total;
  }
}
