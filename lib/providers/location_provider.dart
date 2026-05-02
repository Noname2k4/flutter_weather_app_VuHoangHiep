import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationService _service;

  LocationModel? currentLocation;
  bool isLoading = false;
  String? error;

  /// Constructor for LocationProvider with optional service injection
  LocationProvider({LocationService? service})
    : _service = service ?? LocationService();

  /// Fetches current location using LocationService
  Future<void> fetchLocation() async {
    try {
      isLoading = true;
      notifyListeners();

      currentLocation = await _service.getCurrentLocation();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
