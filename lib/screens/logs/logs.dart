// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/logs/log_tile.dart';
import 'package:droid_hole/screens/logs/no_logs_message.dart';
import 'package:droid_hole/screens/logs/log_details_screen.dart';
import 'package:droid_hole/screens/logs/logs_filters_modal.dart';
import 'package:droid_hole/widgets/custom_radio.dart';

import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/constants/log_status.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/models/log.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  Log? selectedLog;

  DateTime? _lastTimestamp;
  bool _isLoadingMore = false;

  late ScrollController _scrollController;

  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  int loadStatus = 0;
  List<Log> logsList = [];
  int sortStatus = 0;

  DateTime? masterStartTime;
  DateTime? masterEndTime;

  Future loadLogs({
    List<int>? statusSelected,
    DateTime? inStartTime,
    DateTime? inEndTime, 
    required bool replaceOldLogs,
  }) async {
    final logsPerQuery = Provider.of<AppConfigProvider>(context, listen: false).logsPerQuery;

    DateTime? startTime = masterStartTime ?? inStartTime;
    DateTime? endTime = masterEndTime ?? inEndTime;
    late DateTime? timestamp;
    late DateTime? minusHoursTimestamp;
    if (replaceOldLogs == true) {
      _lastTimestamp = null;
    }
    else {
      setState(() => _isLoadingMore = true);
    }
    if (_lastTimestamp == null || replaceOldLogs == true) {
      final now = DateTime.now();
      timestamp = endTime ?? now;
      DateTime newOldTimestamp = logsPerQuery == 0.5 
        ? DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour, timestamp.minute-30, timestamp.second)
        : DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour-logsPerQuery.toInt(), timestamp.minute, timestamp.second);
      if (startTime != null) {
        minusHoursTimestamp = newOldTimestamp.isAfter(startTime) ? newOldTimestamp : startTime;
      }
      else {
        minusHoursTimestamp = newOldTimestamp;
      }
    }
    else {
      timestamp = _lastTimestamp!;
      DateTime newOldTimestamp = logsPerQuery == 0.5 
        ? DateTime(_lastTimestamp!.year, _lastTimestamp!.month, _lastTimestamp!.day, _lastTimestamp!.hour, _lastTimestamp!.minute-30, _lastTimestamp!.second)
        : DateTime(_lastTimestamp!.year, _lastTimestamp!.month, _lastTimestamp!.day, _lastTimestamp!.hour-logsPerQuery.toInt(), _lastTimestamp!.minute, _lastTimestamp!.second);
      if (startTime != null) {
        minusHoursTimestamp = newOldTimestamp.isAfter(startTime) ? newOldTimestamp : startTime;
      }
      else {
        minusHoursTimestamp = newOldTimestamp;
      }
    }
    if (startTime != null && minusHoursTimestamp.isBefore(startTime)) {
      setState(() {
        _isLoadingMore = false;
        loadStatus = 1;
      });
    }
    else {
      final result = await fetchLogs(
        server: Provider.of<ServersProvider>(context, listen: false).selectedServer!,
        from:  minusHoursTimestamp,
        until: timestamp
      );
      if (mounted) {
        setState(() => _isLoadingMore = false);
        if (result['result'] == 'success') {
          List<Log> items = [];
          result['data'].forEach((item) => items.add(Log.fromJson(item)));
          if (replaceOldLogs == true) {
            setState(() {
              loadStatus = 1;
              logsList = items.reversed.toList();
              _lastTimestamp = minusHoursTimestamp;
            });
          }
          else {
            setState(() {
              loadStatus = 1;
              logsList = logsList+items.reversed.toList();
              _lastTimestamp = minusHoursTimestamp;
            });
          }
        }
        else {
          setState(() => loadStatus = 2);
        }
      }
    }
  }

  List<Log> filterLogs({
    List<Log>? logs,
    required List<int> statusSelected,
    required List<String> devicesSelected,
    required String? selectedDomain,
  }) {
    List<Log> tempLogs = logs != null ? [...logs] : [...logsList];

    tempLogs = tempLogs.where((log) {
      if (statusSelected.contains(int.parse(log.status))) {
        return true;
      }
      else {
        return false;
      }
    }).toList();

    if (devicesSelected.isNotEmpty) {
      tempLogs = tempLogs.where((log) {
        if (devicesSelected.contains(log.device)) {
          return true;
        }
        else {
          return false;
        }
      }).toList();
    }

    if (selectedDomain != null) {
      tempLogs = tempLogs.where((log) => log.url == selectedDomain).toList();
    }

    if (_searchController.text != '') {
      tempLogs = tempLogs.where((log) {
        if (log.url.contains(_searchController.text)) {
          return true;
        }
        else {
          return false;
        }
      }).toList();
    }

    if (sortStatus == 1) {
      tempLogs.sort((a,b) => a.dateTime.compareTo(b.dateTime));
    }
    else {
      tempLogs.sort((a,b) => a.dateTime.compareTo(b.dateTime));
      tempLogs = tempLogs.reversed.toList();
    }

    return tempLogs;
  } 


  void _scrollListener() {
    if (_scrollController.position.extentAfter < 500 && _isLoadingMore == false) {
      loadLogs(replaceOldLogs: false);
    }
  }


  @override
  void initState() {
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadLogs(replaceOldLogs: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final filtersProvider = Provider.of<FiltersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;   
    final bottomNavBarHeight = MediaQuery.of(context).viewPadding.bottom;   

    List<Log> logsListDisplay = filterLogs(
      statusSelected: filtersProvider.statusSelected, 
      devicesSelected: filtersProvider.selectedClients,
      selectedDomain: filtersProvider.selectedDomain
    );

    void updateSortStatus(value) {
      if (sortStatus != value) {
        _scrollController.animateTo(
          0, 
          duration: const Duration(milliseconds: 250), 
          curve: Curves.easeInOut
        );
        setState(() {
          sortStatus = value;
          logsListDisplay = logsListDisplay.reversed.toList();
        });
      }
    }

    void whiteBlackList(String list, Log log) async {
      final loading = ProcessModal(context: context);
      loading.open(
        list == 'white' 
          ? AppLocalizations.of(context)!.addingWhitelist
          : AppLocalizations.of(context)!.addingBlacklist,
      );
      final result = await setWhiteBlacklist(
        server: serversProvider.selectedServer!, 
        domain: log.url, 
        list: list
      );
      loading.close();
      if (result['result'] == 'success') {
        if (result['data']['message'].toString().contains('Added')) {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: list == 'white'
              ? AppLocalizations.of(context)!.addedWhitelist
              : AppLocalizations.of(context)!.addedBlacklist,
            color: Colors.green
          );
        }
        else {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: list == 'white'
              ? AppLocalizations.of(context)!.alreadyWhitelist
              : AppLocalizations.of(context)!.alreadyBlacklist,
            color: Colors.green
          );
        }
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: list == 'white'
            ? AppLocalizations.of(context)!.couldntAddWhitelist
            : AppLocalizations.of(context)!.couldntAddBlacklist,
          color: Colors.red
        );
      }
    }

    void showLogDetails(Log log) {
      setState(() => selectedLog = log);
      if (width <= 1000) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => LogDetailsScreen(
            log: log, 
            whiteBlackList: whiteBlackList,
          )
        ));
      }
    }

    void showFiltersModal() {
      if (width > 900) {
        showDialog(
          context: context, 
          builder: (context) => LogsFiltersModal(
            statusBarHeight: statusBarHeight,
            bottomNavBarHeight: bottomNavBarHeight,
            filterLogs: () {
              setState(() {
                masterStartTime = filtersProvider.startTime;
                masterEndTime = filtersProvider.endTime;
                loadStatus = 0;
              });
              loadLogs(
                replaceOldLogs: true,
                inStartTime: filtersProvider.startTime,
                inEndTime: filtersProvider.endTime
              );
            },
            window: true,
          ),
        );
      }
      else {
        showModalBottomSheet(
          context: context, 
          builder: (context) => LogsFiltersModal(
            statusBarHeight: statusBarHeight,
            bottomNavBarHeight: bottomNavBarHeight,
            filterLogs: () {
              setState(() {
                masterStartTime = filtersProvider.startTime;
                masterEndTime = filtersProvider.endTime;
                loadStatus = 0;
              });
              loadLogs(
                replaceOldLogs: true,
                inStartTime: filtersProvider.startTime,
                inEndTime: filtersProvider.endTime
              );
            },
            window: false,
          ),
          backgroundColor: Colors.transparent,
          isDismissible: true, 
          enableDrag: true,
          isScrollControlled: true,
        );
      }
    }

    void searchLogs(String value) {
      List<Log> searched = logsList.where((log) => 
        log.url.toLowerCase().contains(value.toLowerCase())
      ).toList();
      setState(() {
        logsListDisplay = searched;
      });
      filtersProvider.resetFilters();
    }

    Widget status() {
      switch (loadStatus) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.loadingLogs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              ],
            ),
          );
        case 1:
          return RefreshIndicator(
            onRefresh: (() async {
              _lastTimestamp = DateTime.now();
              await loadLogs(replaceOldLogs: true);
            }),
            child: logsListDisplay.isNotEmpty
              ? ListView.builder(
                  controller: _scrollController,
                  itemCount: _isLoadingMore == true 
                    ? logsListDisplay.length+1
                    : logsListDisplay.length,
                  itemBuilder: (context, index) {
                    if (_isLoadingMore == true && index == logsListDisplay.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    else {
                      return LogTile(
                        log: logsListDisplay[index], 
                        showLogDetails: showLogDetails,
                        isLogSelected: logsListDisplay[index] == selectedLog
                      );
                    }
                  }
                )
              : NoLogsMessage(logsPerQuery: appConfigProvider.logsPerQuery)
          );

        case 2:
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.couldntLoadLogs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              ],
            ),
          );
          
        default:
          return const SizedBox();
      }
    }

    Widget buildChip(String label, Icon icon, Function() onDeleted) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Chip(
          label: Text(label),
          avatar: icon,
          onDeleted: onDeleted,
        ),
      );
    }

    bool areFiltersApplied() {
      if (
        filtersProvider.statusSelected.length < 13 ||
        filtersProvider.startTime != null ||
        filtersProvider.endTime != null ||
        filtersProvider.selectedClients.length < filtersProvider.totalClients.length ||
        filtersProvider.selectedDomain != null
      ) {
        return true;
      }
      else {
        return false;
      }
    }

    void scrollToTop() {
      if (logsListDisplay.isNotEmpty) {
        _scrollController.animateTo(
          0, 
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut
        );
      }
    }

    Widget scaffold() {
      return Scaffold(
        appBar: _showSearchBar == true
          ? AppBar(
              toolbarHeight: 60,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    _showSearchBar = false;
                    _searchController.text = "";
                  });
                  _scrollController.animateTo(
                    0, 
                    duration: const Duration(milliseconds: 250), 
                    curve: Curves.easeInOut
                  );
                },
                icon: const Icon(Icons.arrow_back),
                splashRadius: 20,
              ),
              actions: [
                IconButton(     
                  onPressed: () {
                    setState(() => _searchController.text = "");
                    _scrollController.animateTo(
                      0, 
                      duration: const Duration(milliseconds: 250), 
                      curve: Curves.easeInOut
                    );
                  }, 
                  icon: const Icon(Icons.clear_rounded),
                  splashRadius: 20,
                )
              ],
              title: Container(
                width: width-136,
                height: 60,
                margin: const EdgeInsets.only(bottom: 5),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    onChanged: searchLogs,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context)!.searchUrl,
                      hintStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                ),
              )
            )
          : AppBar(
              systemOverlayStyle: systemUiOverlayStyleConfig(context),
              title: Text(AppLocalizations.of(context)!.queryLogs),
              toolbarHeight: 60,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearchBar = true;
                    });
                  }, 
                  icon: const Icon(Icons.search_rounded),
                  splashRadius: 20,
                ),
                IconButton(
                  onPressed: showFiltersModal, 
                  icon: const Icon(Icons.filter_list_rounded),
                  splashRadius: 20,
                ),
                PopupMenuButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.sort_rounded),
                  onSelected: (value) => updateSortStatus(value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded),
                              const SizedBox(width: 15),
                              Text(AppLocalizations.of(context)!.fromLatestToOldest),
                            ],
                          ),
                          CustomRadio(
                            value: 0, 
                            groupValue: sortStatus, 
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          )
                        ],
                      )
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward_rounded),
                              const SizedBox(width: 15),
                              Text(AppLocalizations.of(context)!.fromOldestToLatest),
                            ],
                          ),
                          CustomRadio(
                            value: 1, 
                            groupValue: sortStatus, 
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          )
                        ],
                      )
                    ),
                  ]
                )
              ],
              bottom: areFiltersApplied() == true
                ? PreferredSize(
                    preferredSize: const Size(double.maxFinite, 50),
                    child: Container(
                      width: double.maxFinite,
                      height: 50,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SizedBox(width: 5),
                          if (filtersProvider.startTime != null || filtersProvider.endTime != null) buildChip(
                            AppLocalizations.of(context)!.time, 
                            const Icon(Icons.access_time_rounded),
                            () {
                              filtersProvider.resetTime();
                              setState(() {
                                loadStatus = 0;
                              });
                              loadLogs(replaceOldLogs: true);
                            }
                          ),
                          if (filtersProvider.statusSelected.length < 13) buildChip(
                            filtersProvider.statusSelected.length == 1
                              ? logStatusString[filtersProvider.statusSelected[0]-1]
                              : "${filtersProvider.statusSelected.length} ${AppLocalizations.of(context)!.statusSelected}",
                            const Icon(Icons.shield),
                            () {
                              scrollToTop();
                              filtersProvider.resetStatus();
                            },
                          ),
                          if (filtersProvider.selectedClients.isNotEmpty && filtersProvider.selectedClients.length < filtersProvider.totalClients.length) buildChip(
                            filtersProvider.selectedClients.length == 1
                              ? filtersProvider.selectedClients[0]
                              : "${filtersProvider.selectedClients.length} ${AppLocalizations.of(context)!.clientsSelected}",
                            const Icon(Icons.devices),
                            () {
                              scrollToTop();
                              filtersProvider.resetClients();
                            },
                          ),
                          if (filtersProvider.selectedDomain != null) buildChip(
                            filtersProvider.selectedDomain!,
                            const Icon(Icons.http_rounded),
                            () {
                              scrollToTop();
                              filtersProvider.setSelectedDomain(null);
                            },
                          ),
                          const SizedBox(width: 5),
                        ],
                      )
                    ),
                  )
              : const PreferredSize(
                  preferredSize: Size(0, 0),
                  child: SizedBox(),
                )
            ),
        body: status()
      );
    }

    if (width > 1000) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: scaffold()
          ),
          Expanded(
            flex: 4,
            child: selectedLog != null ? LogDetailsScreen(
                log: selectedLog!, 
                whiteBlackList: whiteBlackList
              ) : const SizedBox()
          )
        ],
      );
    }
    else {
      return scaffold();
    }
  }
}