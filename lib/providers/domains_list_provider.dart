import 'package:flutter/material.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsListProvider with ChangeNotifier {
  int _loadingStatus = 0;
  List<Domain> _whitelistDomains = [];
  List<Domain> _blacklistDomains = [];

  List<Domain> _filteredWhitelistDomains = [];
  List<Domain> _filteredBlacklistDomains = [];

  int? _selectedTab;

  String _searchTerm = "";

  bool _searchMode = false;

  int get loadingStatus {
    return _loadingStatus;
  }

  List<Domain> get whitelistDomains {
    return _whitelistDomains;
  }

  List<Domain> get blacklistDomains {
    return _blacklistDomains;
  }

  List<Domain> get filteredWhitelistDomains {
    return _filteredWhitelistDomains;
  }

  List<Domain> get filteredBlacklistDomains {
    return _filteredBlacklistDomains;
  }

  int? get selectedTab {
    return _selectedTab;
  }
  
  String get searchTerm {
    return _searchTerm;
  }

  bool get searchMode {
    return _searchMode;
  }

  void setLoadingStatus(int status) {
    _loadingStatus = status;
  }

  void setWhitelistDomains(List<Domain> domains) {
    _whitelistDomains = domains;
    notifyListeners();
  }

  void setBlacklistDomains(List<Domain> domains) {
    _blacklistDomains = domains;
    notifyListeners();
  }

  void setSelectedTab(int? tab) {
    _selectedTab = tab;
  }

  void setSearchMode(bool value) {
    _searchMode = value;
    notifyListeners();
  }

  void onSearch(String value) {
    _searchTerm = value;

    if (value != "") {
      _filteredBlacklistDomains = _blacklistDomains.where((i) => i.domain.contains(value)).toList();
      _filteredWhitelistDomains = _whitelistDomains.where((i) => i.domain.contains(value)).toList();
    }
    else {
      _filteredBlacklistDomains = _blacklistDomains;
      _filteredWhitelistDomains = _whitelistDomains;
    }

    notifyListeners();
  }

  Future fetchDomainsList(Server server) async {
    final result = await getDomainLists(server: server);
    if (result['result'] == 'success') {
      final List<Domain> whitelist = [
        ...result['data']['whitelist'],
        ...result['data']['whitelistRegex']
      ];
      _whitelistDomains = whitelist;
      _filteredWhitelistDomains = whitelist.where((i) => i.domain.contains(_searchTerm)).toList();

      final List<Domain> blacklist = [
        ...result['data']['blacklist'],
        ...result['data']['blacklistRegex']
      ];
      _blacklistDomains = blacklist;
      _filteredBlacklistDomains = blacklist.where((i) => i.domain.contains(_searchTerm)).toList();

      _loadingStatus = 1;
    }
    else {
      _loadingStatus = 2;
    }
    notifyListeners();
  }

  void removeDomainFromList(Domain domain) {
    if (domain.type == 0 || domain.type == 2) {
      _whitelistDomains = _whitelistDomains.where((item) => item.id != domain.id).toList();
      _filteredWhitelistDomains = _filteredWhitelistDomains.where((item) => item.id != domain.id).toList();
    }
    else if (domain.type == 1 || domain.type == 3) {
      _blacklistDomains = _blacklistDomains.where((item) => item.id != domain.id).toList();
      _filteredBlacklistDomains = _filteredBlacklistDomains.where((item) => item.id != domain.id).toList();
    }
    notifyListeners();
  }
}