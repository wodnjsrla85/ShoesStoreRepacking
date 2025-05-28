// 도영 : 야~~~~~호 ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationNotifier extends AsyncNotifier<LatLng?>{

  @override
  Future<LatLng?> build() async{
    return await loadCurrentLocation();
  }

  Future<LatLng?> loadCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return null;

    final pos = await Geolocator.getCurrentPosition();
          return LatLng(pos.latitude, pos.longitude);
  }

}

final locationNotifier = AsyncNotifierProvider<LocationNotifier, LatLng?>(
  () => LocationNotifier(),
);

