// // 도영 : 야호~~~~~~~~^^

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
// import 'package:team4shoeshop_refactoring/vm/4_location_provider.dart';

// class LocationSearch extends ConsumerWidget{
//   const LocationSearch({super.key});
  

//   Future<void> _loadCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever) return;

//     final pos = await Geolocator.getCurrentPosition();
//     setState(() {
//       currentLocation = LatLng(pos.latitude, pos.longitude);
//     });
//   }

//   Future<void> fetchDealers() async {
//     final url = Uri.parse("http://127.0.0.1:8000/employee_list");
//     final response = await http.get(url);
//     final data = json.decode(utf8.decode(response.bodyBytes));

//     if (data["result"] is List) {
//       setState(() {
//         dealers = List<Map<String, dynamic>>.from(data["result"]);
//         if (dealers.isNotEmpty) {
//           selectedDealer = dealers.first;
//         }
//       });
//     }
//   }

//   void _moveToDealerLocation(Map<String, dynamic> dealer) {
//     final lat = double.tryParse(dealer["lat"].toString()) ?? 0.0;
//     final lng = double.tryParse(dealer["lng"].toString()) ?? 0.0;
//     if (_isMapReady) {
//       _mapController.move(LatLng(lat, lng), 17);
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final locationState = ref.watch(locationProvider);



//     return Scaffold(
//       appBar: AppBar(title: const Text("대리점 위치 검색")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DropdownButton<Map<String, dynamic>>(
//               isExpanded: true,
//               value: selectedDealer,
//               hint: const Text("지점을 선택하세요"),
//               items:
//                   dealers.map((dealer) {
//                     return DropdownMenuItem<Map<String, dynamic>>(
//                       value: dealer,
//                       child: Text(dealer["ename"]),
//                     );
//                   }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     selectedDealer = value;
//                   });
//                   _moveToDealerLocation(value);
//                 }
//               },
//             ),
//           ),
//           Expanded(
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: currentLocation ?? LatLng(37.494444, 127.03),
//                 initialZoom: 13,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   userAgentPackageName: 'com.example.app',
//                 ),
//                 if (selectedDealer != null)
//                   MarkerLayer(
//                     markers: [
//                       // 현재 위치 마커
//                       if (currentLocation != null)
//                         Marker(
//                           point: currentLocation!,
//                           width: 40,
//                           height: 40,
//                           child: const Icon(
//                             Icons.person_pin_circle,
//                             color: Colors.blue,
//                             size: 40,
//                           ),
//                         ),
//                       // 선택된 대리점 마커
//                       if (selectedDealer != null)
//                         Marker(
//                           point: LatLng(
//                             double.tryParse(
//                                   selectedDealer!["lat"].toString(),
//                                 ) ??
//                                 0.0,
//                             double.tryParse(
//                                   selectedDealer!["lng"].toString(),
//                                 ) ??
//                                 0.0,
//                           ),
//                           width: 40,
//                           height: 40,
//                           child: const Icon(
//                             Icons.location_on,
//                             color: Colors.red,
//                             size: 40,
//                           ),
//                         ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
