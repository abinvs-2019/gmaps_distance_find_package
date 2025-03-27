library gmaps_by_road_distance_calculator;

import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:google_maps_flutter/google_maps_flutter.dart' as Gmap;
import 'package:latlong2/latlong.dart';


import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';
import 'dart:async';
import 'dart:convert';

enum TravelModes { driving, bicycling, trnasit, walking }


class ByRoadDistanceCalculator {
  final Distance _distance = Distance();
  final List<LatLng> _points = [];
  final StreamController<double> _controller = StreamController<double>();
  double _totalDistance = 0.0;
  static const _osrmBaseUrl = 'https://router.project-osrm.org/route/v1';

  // Original calculation method
  double calculateDistance(List<LatLng> points) {
    _totalDistance = _sumDistance(points);
    return _totalDistance / 1000;
  }

  // New: OSRM-based distance calculation with travel modes
  Future<DistanceResult> calculateDistanceViaOSRM({
    required LatLng start,
    required LatLng end,
    TravelModes mode = TravelModes.driving,
    String? customOSRMUrl,
  }) async {
    final profile = _getOSRMProfile(mode);
    final url = Uri.parse(
      '${customOSRMUrl ?? _osrmBaseUrl}/$profile/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson'
    );

    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception('OSRM API Error');

    final data = jsonDecode(response.body);
    final encodedPolyline = data['routes'][0]['geometry']['coordinates'];
    
    final points = (encodedPolyline as List)
        .map((coord) => LatLng(coord[1], coord[0]))
        .toList();

    return DistanceResult(
      distance: _sumDistance(points) / 1000,
      points: points,
      mode: mode,
    );
  }

  String _getOSRMProfile(TravelModes mode) {
    switch (mode) {
      case TravelModes.driving:
        return 'car';
      case TravelModes.bicycling:
        return 'bike';
      case TravelModes.walking:
        return 'foot';
      case TravelModes.transit:
        return 'car'; // OSRM doesn't support transit, fallback to car
    }
  }

  // Existing polyline decoding
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

  // Existing GPS parsing
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

  // Real-time tracking
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

  double _sumDistance(List<LatLng> points) {
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _distance(points[i], points[i + 1]);
    }
    return total;
  }
}

class DistanceResult {
  final double distance; // In kilometers
  final List<LatLng> points;
  final TravelModes mode;

  DistanceResult({
    required this.distance,
    required this.points,
    required this.mode,
  });
}