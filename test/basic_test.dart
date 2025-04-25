import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:gmaps_by_road_distance_calculator/gmaps_by_road_distance_calculator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  group('Core Distance Calculations', () {
    final calculator = ByRoadDistanceCalculator();
    const precision = 0.01; // 10 meter precision

    test('Empty points list returns 0 distance', () {
      expect(calculator.calculateDistance([]), 0.0);
    });

    test('Single point returns 0 distance', () {
      expect(calculator.calculateDistance([LatLng(37.7749, -122.4194)]), 0.0);
    });

    test('Calculates SF to LA distance correctly', () {
      final points = [
        LatLng(37.7749, -122.4194), // San Francisco
        LatLng(34.0522, -118.2437)  // Los Angeles
      ];
      // Verified using Vincenty formula: 559.12 km ± 50m
      expect(calculator.calculateDistance(points), closeTo(559.12, 0.05));
    });

    test('Sum of multiple geographic segments', () {
      final points = [
        LatLng(0, 0),
        LatLng(0, 1),  // ~111.319 km
        LatLng(1, 1),  // ~110.574 km
        LatLng(1, 0)   // ~111.319 km
      ];
      expect(calculator.calculateDistance(points), closeTo(333.21, 0.1));
    });
  });

  group('Polyline Decoding', () {
    test('Decodes simple polyline with precision', () {
      const encoded = "_p~iF~ps|U";
      final points = ByRoadDistanceCalculator.decodePolylineString(encoded);
      
      expect(points[0].latitude, closeTo(38.5, 0.0001));
      expect(points[0].longitude, closeTo(-120.2, 0.0001));
      expect(points[1].latitude, closeTo(40.7, 0.0001));
      expect(points[1].longitude, closeTo(-120.95, 0.0001));
    });

    test('Empty string returns empty list', () {
      expect(ByRoadDistanceCalculator.decodePolylineString(''), isEmpty);
    });
  });

  group('GPS File Parsing', () {
    final calculator = ByRoadDistanceCalculator();
    final validGPX = '''
      <gpx>
        <trk><trkseg>
          <trkpt lat="37.7749" lon="-122.4194"/>
          <trkpt lat="34.0522" lon="-118.2437"/>
        </trkseg></trk>
      </gpx>
    ''';

    final validKML = '''
      <kml>
        <Placemark>
          <LineString>
            <coordinates>
              -122.4194,37.7749,0
              -118.2437,34.0522,0
            </coordinates>
          </LineString>
        </Placemark>
      </kml>
    ''';

    test('Parses valid GPX correctly', () {
      final points = calculator.parseGPX(validGPX);
      expect(points, [
        LatLng(37.7749, -122.4194),
        LatLng(34.0522, -118.2437)
      ]);
    });

    test('Parses valid KML correctly', () {
      final points = calculator.parseKML(validKML);
      expect(points, [
        LatLng(37.7749, -122.4194),
        LatLng(34.0522, -118.2437)
      ]);
    });

    test('Invalid GPX returns empty list', () {
      expect(calculator.parseGPX('<invalid>'), isEmpty);
    });

    test('Invalid KML returns empty list', () {
      expect(calculator.parseKML('<invalid>'), isEmpty);
    });
  });

  group('Real-time Tracking', () {
    late ByRoadDistanceCalculator calculator;

    setUp(() => calculator = ByRoadDistanceCalculator());
    tearDown(() => calculator.clearPoints());

    test('Stream emits accurate cumulative distances', () async {
      final expectedDistances = [2.11, 4.25]; // SF coordinates progression
      final actualDistances = [];
      
      calculator.distanceUpdates.listen(
        (distance) => actualDistances.add(distance),
        onError: (e) => fail('Unexpected error: $e'),
      );

      await calculator.addPoint(LatLng(37.7749, -122.4194)); // SF
      await calculator.addPoint(LatLng(37.7855, -122.4073)); // 2.11 km
      await calculator.addPoint(LatLng(37.8024, -122.4058)); // +2.14 km

      expect(actualDistances, hasLength(2));
      expect(actualDistances[0], closeTo(expectedDistances[0], 0.01));
      expect(actualDistances[1], closeTo(expectedDistances[1], 0.01));
    });

    test('Clear points resets distance state', () {
      calculator.addPoint(LatLng(37.7749, -122.4194));
      calculator.clearPoints();
      expect(calculator.calculateDistance([]), 0.0);
    });
  });

  group('OSRM Integration', () {
    late MockClient mockClient;
    late ByRoadDistanceCalculator calculator;

    setUp(() {
      mockClient = MockClient();
      calculator = ByRoadDistanceCalculator();
    });

    test('Converts travel modes to correct OSRM profiles', () {
      expect(calculator._getOSRMProfile(TravelModes.driving), 'car');
      expect(calculator._getOSRMProfile(TravelModes.bicycling), 'bike');
      expect(calculator._getOSRMProfile(TravelModes.walking), 'foot');
      expect(calculator._getOSRMProfile(TravelModes.transit), 'car');
    });

    test('Handles successful OSRM response correctly', () async {
      final jsonResponse = '''{
        "routes": [{
          "geometry": {
            "coordinates": [
              [-122.4194, 37.7749],
              [-118.2437, 34.0522]
            ],
            "type": "LineString"
          }
        }]
      }''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(jsonResponse, 200));

      final result = await calculator.calculateDistanceViaOSRM(
        start: LatLng(37.7749, -122.4194),
        end: LatLng(34.0522, -118.2437),
        mode: TravelModes.driving,
      );

      expect(result.points, [
        LatLng(37.7749, -122.4194),
        LatLng(34.0522, -118.2437)
      ]);
      expect(result.distance, closeTo(559.12, 0.1));
    });

    test('Handles OSRM API errors gracefully', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
        calculator.calculateDistanceViaOSRM(
          start: LatLng(0, 0),
          end: LatLng(1, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}