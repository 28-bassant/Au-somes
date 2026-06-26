import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../models/Centers/center_model.dart';

Future<List<CenterModel>> loadCenters() async {
  final String response =
  await rootBundle.loadString('assets/data/centers.json');

  final List data = json.decode(response);

  return data.map((e) => CenterModel.fromJson(e)).toList();
}
Future<CenterModel?> getNearestCenter(
    List<CenterModel> centers,
    ) async {

  LocationPermission permission =
  await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission =
    await Geolocator.requestPermission();
  }

  Position position =
  await Geolocator.getCurrentPosition();

  double shortestDistance = double.infinity;
  CenterModel? nearestCenter;

  for (var center in centers) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      center.latitude,
      center.longitude,
    );

    if (distance < shortestDistance) {
      shortestDistance = distance;
      nearestCenter = center;
    }
  }

  return nearestCenter;
}
