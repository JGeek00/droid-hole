import 'package:flutter/material.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsListProvider with ChangeNotifier {
  int _loadingStatus = 0;
  List<Domain> _whitelistDomains = [];
  List<Domain> _blacklistDomains = [];

  int? _selectedTab;

  int get loadingStatus {
    return _loadingStatus;
  }

  List<Domain> get whitelistDomains {
    return _whitelistDomains;
  }

  List<Domain> get blacklistDomains {
    return _blacklistDomains;
  }

  int? get selectedTab {
    return _selectedTab;
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

  Future fetchDomainsList(Server server) async {
    final result = await getDomainLists(server: server);
    if (result['result'] == 'success') {
      setWhitelistDomains([
        ...result['data']['whitelist'],
        ...result['data']['whitelistRegex']
      ]);
      setBlacklistDomains([
        ...result['data']['blacklist'],
        ...result['data']['blacklistRegex']
      ]);
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
    }
    else if (domain.type == 1 || domain.type == 3) {
      _blacklistDomains = _blacklistDomains.where((item) => item.id != domain.id).toList();
    }
    notifyListeners();
  }
}