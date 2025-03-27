# Quick Start 🚀

## Basic Usage

```dart
import 'package:road_distance_calculator/road_distance_calculator.dart';

final calculator = ByRoadDistanceCalculator();
final points = [
  LatLng(37.7749, -122.4194),  // SF
  LatLng(34.0522, -118.2437)   // LA
];

final distance = calculator.calculateDistance(points);
print('Distance: \${distance.toStringAsFixed(2)} km');  // Output: Distance: 559.23 km
```

## API Reference 📚

### Core Methods

#### `calculateDistance(List<LatLng> points) → double`
Calculates total distance for a list of coordinates.

**Parameters:**
- `points`: Ordered list of `LatLng` coordinates.

**Returns:**
- Total distance in kilometers.

### Polyline Decoding

#### `static decodePolylineString(String encoded) → List<LatLng>`
Decodes polyline strings (e.g., `"yxocFxfgy@..."`) into coordinates.

```dart
final polyline = 'yxocFxfgy@...';
final points = ByRoadDistanceCalculator.decodePolylineString(polyline);
```

### GPS File Parsing

#### `parseGPX(String gpxContent) → List<LatLng>`
Extracts coordinates from GPX files.

```dart
final gpxFile = File('route.gpx').readAsStringSync();
final points = calculator.parseGPX(gpxFile);
```

#### `parseKML(String kmlContent) → List<LatLng>`
Extracts coordinates from KML files.

```dart
final kmlFile = File('route.kml').readAsStringSync();
final points = calculator.parseKML(kmlFile);
```

### Real-Time Tracking

#### `addPoint(LatLng point)`
Adds points incrementally for live tracking.

#### `distanceUpdates → Stream<double>`
Stream of cumulative distance updates.

```dart
calculator.distanceUpdates.listen((km) {
  print('Distance updated: \${km.toStringAsFixed(2)} km');
});

// Simulate GPS updates
await Future.delayed(Duration(seconds: 1));
calculator.addPoint(LatLng(37.3354, -122.0097));
```

## Use Cases 💡

### 1. Fitness Apps 🏃‍♂️
Track running/cycling routes from GPX files:

```dart
final gpxPoints = calculator.parseGPX(gpxData);
final distance = calculator.calculateDistance(gpxPoints);
```

### 2. Logistics Solutions 🚚
Calculate delivery route distances:

```dart
final routePoints = ByRoadDistanceCalculator.decodePolylineString(logisticsPolyline);
print('Total route: \${calculator.calculateDistance(routePoints)} km');
```

### 3. Travel Planning ✈️
Estimate road trip distances:

```dart
final tripPlan = [start, stop1, stop2, destination];
print('Total trip: \${calculator.calculateDistance(tripPlan)} km');
```

### 4. IoT Tracking Devices 📡
Live tracking integration:

```dart
void onGpsUpdate(LatLng position) {
  calculator.addPoint(position);
  // Stream updates automatically
}
```

## Offline Usage 📴
Works completely offline after initial setup:

```dart
// Load cached route data
final storedRoute = getCachedRoute(); // List<LatLng>
final distance = calculator.calculateDistance(storedRoute);
```

Compatible with offline map providers:
- Mapbox GL (offline)
- Google Maps (cached regions)
- Custom tile providers

## Contributing 🤝

1. Fork the repository.
2. Create your feature branch.
3. Add tests for new features.
4. Submit a pull request.

## License 📄
MIT License - See [LICENSE](LICENSE) for details.

## Credits
Geospatial calculations powered by [latlong2](https://pub.dev/packages/latlong2).
