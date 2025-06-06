import 'package:flutter/material.dart';
import 'package:services_app/models/service_model.dart';
import 'package:services_app/services/api.dart';

enum ServiceStatus { loading, success, error }

class ServicesNotifier with ChangeNotifier {
  ServicesNotifier({Api? api}) : _api = api ?? Api();

  final Api _api;
  List<ServiceModel> _services = [];
  ServiceStatus _status = ServiceStatus.loading;

  List<ServiceModel> get services => _services;

  ServiceStatus get status => _status;

  Future<void> fetchServices() async {
    try {
      _status = ServiceStatus.loading;
      final services = await _api.getServices();
      _services = services;
      _status = ServiceStatus.success;
    } catch (err) {
      _services = [];
      _status = ServiceStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
