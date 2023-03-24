import 'package:droid_hole/screens/logs/logs_filters_modal.dart';
import 'package:flutter/material.dart';

class FiltersProvider with ChangeNotifier {
  List<int> _statusSelected = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
  ];
  DateTime? _startTime;
  DateTime? _endTime;
  List<String> _totalClients = [];
  List<String> _selectedClients = [];
  String? _selectedDomain;
  RequestStatus _requestStatus = RequestStatus.all;

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

  String? get selectedDomain {
    return _selectedDomain;
  }

  RequestStatus get requestStatus {
    return _requestStatus;
  }

  void setStatusSelected(List<int> values) {
    _statusSelected = values;
    if (values == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]) {
      _requestStatus = RequestStatus.all;
    }
    else if (values == [2, 3]) {
      _requestStatus = RequestStatus.allowed;
    }
    else if (values == [1, 4, 5, 6, 7, 8, 9, 10, 11, 14]) {
      _requestStatus = RequestStatus.blocked;
    }
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
    _requestStatus = RequestStatus.all;
    _startTime = null;
    _endTime = null;
    _selectedClients = _totalClients;
    _selectedDomain = null;
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
    _requestStatus = RequestStatus.all;
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

  void setSelectedDomain(String? domain) {
    _selectedDomain = domain;
    notifyListeners();
  }
  
  void resetClients() {
    _selectedClients = _totalClients;
    notifyListeners();
  }

  void setRequestStatus(RequestStatus status) {
    _requestStatus = status;
    if (status == RequestStatus.all) {
      _statusSelected = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
      ];
    }
    else if (status == RequestStatus.allowed) {
      _statusSelected = [2, 3];
    }
    else if (status == RequestStatus.blocked) {
      _statusSelected = [
        1, 4, 5, 6, 7, 8, 9, 10, 11, 14
      ];
    }
    notifyListeners();
  }
}