import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String?> getCurrentLocationQuery() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      // wttr.in accepts lat,long query format: "10.7769,106.7009"
      return '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}';
    } catch (_) {
      return null;
    }
  }
}
