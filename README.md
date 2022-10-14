<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->


## Features

A Flutter Package to calculate the distance(By-Road) from gmaps of two points.
## Getting started

All you need to do is get a Gmaps Platform API which is Required.
You can choose your travel type in your requirement.

## Usage



```dart
ByRoadDistanceCalculator distance = ByRoadDistanceCalculator();


var distance = await distance.getDistance('YOUR API KEY',
       startLatitude,
       startLongitude,
       destinationLatitude,
       destinationLongitude,
       travelMode: TravelModes.bicycling);

```

## Additional information

Really need contibutors to make this more good and usefull,
Hope this helps.
