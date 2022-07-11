import 'package:flutter/material.dart';

class FiltersProvider with ChangeNotifier {
  List<int> _statusSelected = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
  ];
  DateTime? _startTime;
  DateTime? _endTime;
  List<String> _totalClients = [];
  List<String> _selectedClients = [];

  List<int> get statusSelected {
    return _statusSelected;
  }

  DateTime? get startTime {
    return _startTime;
  }

  DateTime? get endTime {
    return _endTime;
  }

  List<String> get totalClients {
    return _totalClients;
  }

  List<String> get selectedClients {
    return _selectedClients;
  }

  void setStatusSelected(List<int> values) {
    _statusSelected = values;
    notifyListeners();
  }

  void setStartTime(DateTime value) {
    _startTime = value;
    notifyListeners();
  }

  void setEndTime(DateTime value) {
    _endTime = value;
    notifyListeners();
  }

  void resetFilters() {
    _statusSelected = [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
    ];
    _startTime = null;
    _endTime = null;
    _selectedClients = _totalClients;
    notifyListeners();
  }

  void resetTime() {
    _startTime = null;
    _endTime = null;
    notifyListeners();
  }

  void resetStatus() {
    _statusSelected = [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
    ];
    notifyListeners();
  }

  void setClients(List<String> clients) {
    if (_totalClients.isEmpty) {
      _selectedClients = clients;
    }
    _totalClients = clients;
    notifyListeners();
  }

  void setSelectedClients(List<String> selectedClients) {
    _selectedClients = selectedClients;
    notifyListeners();
  }
  
  void resetClients() {
    _selectedClients = _totalClients;
    notifyListeners();
  }
}