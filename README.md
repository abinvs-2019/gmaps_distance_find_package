# gmaps_by_road_distance_calculator

A Dart package for calculating distances along roads and routes using multiple APIs and formats.

## Features

- Calculate distances between geographical points
- Support for real-time distance tracking
- Calculate distances along roads using OSRM (Open Source Routing Machine)
- Multiple travel modes: driving, bicycling, walking, transit
- Parse and work with GPX and KML route files
- Decode polyline strings to geographical points

## Getting Started

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  gmaps_by_road_distance_calculator: ^1.0.0
```

Then run:

```
flutter pub get
```

### Import

```dart
import 'package:gmaps_by_road_distance_calculator/gmaps_by_road_distance_calculator.dart';
```

## Usage

### Basic Distance Calculation

Calculate straight-line distances between geographical points:

```dart
final calculator = ByRoadDistanceCalculator();
final points = [
  LatLng(37.7749, -122.4194), // San Francisco
  LatLng(34.0522, -118.2437), // Los Angeles
];

// Calculate straight-line distance in kilometers
final distance = calculator.calculateDistance(points);
print('Distance: $distance km');
```

### Calculate Road Distance Using OSRM

Calculate actual road distance between two points using the OSRM service:

```dart
final calculator = ByRoadDistanceCalculator();
final start = LatLng(37.7749, -122.4194); // San Francisco
final end = LatLng(34.0522, -118.2437); // Los Angeles

// Calculate driving distance
calculator.calculateDistanceViaOSRM(
  start: start,
  end: end,
  mode: TravelModes.driving,
).then((result) {
  print('Driving distance: ${result.distance} km');
  print('Route consists of ${result.points.length} points');
});

// Calculate walking distance
calculator.calculateDistanceViaOSRM(
  start: start,
  end: end,
  mode: TravelModes.walking,
).then((result) {
  print('Walking distance: ${result.distance} km');
});
```

### Real-time Distance Tracking

Track and update distance in real-time as new points are added:

```dart
final calculator = ByRoadDistanceCalculator();

// Listen for distance updates
calculator.distanceUpdates.listen((distance) {
  print('Current distance: $distance km');
});

// Add points as they become available (e.g., from GPS)
calculator.addPoint(LatLng(37.7749, -122.4194));
calculator.addPoint(LatLng(37.7850, -122.4100));
calculator.addPoint(LatLng(37.7950, -122.4000));

// Reset tracking when needed
calculator.clearPoints();
```

### Working with GPX Files

Parse GPX files to extract geographical points:

```dart
final calculator = ByRoadDistanceCalculator();
final gpxContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1">
  <trk>
    <trkseg>
      <trkpt lat="37.7749" lon="-122.4194"></trkpt>
      <trkpt lat="37.7850" lon="-122.4100"></trkpt>
      <trkpt lat="37.7950" lon="-122.4000"></trkpt>
    </trkseg>
  </trk>
</gpx>
''';

final points = calculator.parseGPX(gpxContent);
final distance = calculator.calculateDistance(points);
print('Distance from GPX: $distance km');
```

### Working with KML Files

Parse KML files to extract geographical points:

```dart
final calculator = ByRoadDistanceCalculator();
final kmlContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <Placemark>
      <LineString>
        <coordinates>
          -122.4194,37.7749,0
          -122.4100,37.7850,0
          -122.4000,37.7950,0
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>
''';

final points = calculator.parseKML(kmlContent);
final distance = calculator.calculateDistance(points);
print('Distance from KML: $distance km');
```

### Decode Polyline Strings

Convert encoded polyline strings to geographical points:

```dart
final encodedPolyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@";
final points = ByRoadDistanceCalculator.decodePolylineString(encodedPolyline);
```

## Advanced Configuration

### Custom OSRM Server

You can specify a custom OSRM server URL if you're hosting your own instance:

```dart
calculator.calculateDistanceViaOSRM(
  start: start,
  end: end,
  mode: TravelModes.driving,
  customOSRMUrl: 'https://your-custom-osrm-server.com/route/v1',
).then((result) {
  print('Distance: ${result.distance} km');
});
```

## Dependencies

This package depends on:
- `latlong2`: For geographical coordinate operations
- `http`: For API requests
- `xml`: For parsing GPX and KML files

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues and Feedback

Please file issues and feedback [here](https://github.com/abinvs-2019/gmaps_distance_find_package/issues).
