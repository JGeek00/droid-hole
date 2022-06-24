import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/logs_filters_modal.dart';
import 'package:droid_hole/widgets/log_status.dart';
import 'package:droid_hole/widgets/log_details_modal.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/custom_radio.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';

import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/log.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/server.dart';

class Logs extends StatelessWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    if (serversProvider.selectedServer != null && serversProvider.isServerConnected == true) {
      return LogsList(
        server: serversProvider.selectedServer!, 
        token: serversProvider.selectedServerToken!['phpSessId'],
        selectedStatus: filtersProvider.statusSelected,
        startTime: filtersProvider.startTime,
        endTime: filtersProvider.endTime,
      ); 
    }
    else if (serversProvider.selectedServer != null && serversProvider.isServerConnected == false) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.maxFinite, 70),
          child: Container(
            margin: EdgeInsets.only(top: statusBarHeight),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12
                )
              )
            ),
            child: const Text(
              "Query logs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          )
        ),
        body: const Center(
          child: SelectedServerDisconnected()
        ),
      );
    }
    else if (serversProvider.selectedServer == null) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.maxFinite, 90),
          child: TopBar()
        ),
        body: Center(
          child: NoServerSelected()
        ),
      );
    }
    else {
      return const SizedBox();
    }
  }
}

class LogsList extends StatefulWidget {
  final Server server;
  final String token;
  final List<int> selectedStatus;
  final DateTime? startTime;
  final DateTime? endTime;

  const LogsList({
    Key? key,
    required this.server,
    required this.token,
    required this.selectedStatus,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  State<LogsList> createState() => _LogsListState();
}

class _LogsListState extends State<LogsList> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  int loadStatus = 0;
  List<Log> logsList = [];
  List<Log> logsListDisplay = [];
  int sortStatus = 0;

  Future loadLogs({
    List<int>? statusSelected,
    DateTime? startTime,
    DateTime? endTime, 
  }) async {
    setState(() {
      _showSearchBar = false;
      _searchController.text = "";
    });
    final result = await fetchLogs(
      widget.server,
      widget.token
    );
    if (result['result'] == 'success') {
      List<Log> items = [];
      result['data'].forEach((item) => items.add(Log.fromJson(item)));
      List<Log> filtered = filterLogs(
        logs: items.reversed.toList(),
        statusSelected: statusSelected ?? widget.selectedStatus,
        startTime: startTime ?? widget.startTime,
        endTime: endTime ?? widget.endTime,
      );
      setState(() {
        loadStatus = 1;
        logsList = items.reversed.toList();
        logsListDisplay = filtered;
      });
    }
    else {
      setState(() => loadStatus = 2);
    }
  }

  List<Log> filterLogs({
    List<Log>? logs,
    required List<int> statusSelected,
    required DateTime? startTime,
    required DateTime? endTime, 
  }) {
    List<Log> tempLogs = logs != null ? [...logs] : [...logsList];

    if (startTime != null) {
      tempLogs = tempLogs.where((log) => log.dateTime.isAfter(startTime)).toList();
    }
    if (endTime != null) {
      tempLogs = tempLogs.where((log) => log.dateTime.isBefore(endTime)).toList();
    }

    tempLogs = tempLogs.where((log) {
      if (statusSelected.contains(int.parse(log.status))) {
        return true;
      }
      else {
        return false;
      }
    }).toList();

    return tempLogs;
  } 

  @override
  void initState() {
    loadLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;   

    void _updateSortStatus(value) {
      if (sortStatus != value) {
        setState(() {
          sortStatus = value;
          logsListDisplay = logsListDisplay.reversed.toList();
        });
      }
    }

    void _whiteBlackList(String list, Log log) async {
      final loading = ProcessModal(context: context);
      loading.open(
        list == 'white' 
          ? "Adding to whitelist..." 
          : "adding to blacklist..."
      );
      final result = await setWhiteBlacklist(
        server: serversProvider.selectedServer!, 
        domain: log.url, 
        list: list, 
        token: serversProvider.selectedServerToken!['token'], 
        phpSessId: serversProvider.selectedServerToken!['phpSessId']
      );
      loading.close();
      if (result['result'] == 'success') {
        if (result['data']['message'].toString().contains('Added')) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                list == 'white'
                  ? "Domain added to whitelist."
                  : "Domain added to blacklist."
              ),
              backgroundColor: Colors.green,
            )
          );
        }
        else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                list == 'white'
                  ? "Domain is already on whitelist."
                  : "Domain is already on blacklist."
              ),
              backgroundColor: Colors.grey,
            )
          );
        }
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              list == 'white'
                ? "Could not add domain to whitelist."
                : "Could not add domain to blacklist."
            ),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _showLogDetails(Log log) {
      showModalBottomSheet(
        context: context, 
        builder: (context) => LogDetailsModal(
          log: log,
          statusBarHeight: statusBarHeight,
          whiteBlackList: _whiteBlackList,
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true, 
        enableDrag: true,
        isScrollControlled: true,
      );
    }

    void _showFiltersModal() {
      showModalBottomSheet(
        context: context, 
        builder: (context) => LogsFiltersModal(
          statusBarHeight: statusBarHeight,
          filterLogs: () {
            setState(() {
              logsListDisplay = filterLogs(
                statusSelected: filtersProvider.statusSelected,
                startTime: filtersProvider.startTime,
                endTime: filtersProvider.endTime
              );
            });
          },
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true, 
        enableDrag: true,
        isScrollControlled: true,
      );
    }

    void _searchLogs(String value) {
      List<Log> searched = logsList.where((log) => 
        log.url.toLowerCase().contains(value.toLowerCase())
      ).toList();
      setState(() {
        logsListDisplay = searched;
      });
      filtersProvider.resetFilters();
    }

    Widget _status() {
      switch (loadStatus) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 50),
                Text(
                  "Loading logs...",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          );
        case 1:
          return RefreshIndicator(
            onRefresh: (() async {
              await loadLogs();
            }),
            child: logsListDisplay.isNotEmpty
              ? ListView.builder(
                  itemCount: logsListDisplay.length,
                  itemBuilder: (context, index) => Material(
                    child: InkWell(
                      onTap: () => _showLogDetails(logsListDisplay[index]),
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: index < logsListDisplay.length
                            ? const Border(
                                bottom: BorderSide(
                                  color: Colors.black12
                                )
                              )
                            : null
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LogStatus(status: logsListDisplay[index].status, showIcon: true),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: width-100,
                                  child: Text(
                                    logsListDisplay[index].url,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  logsListDisplay[index].device,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13
                                  ),
                                )
                              ],
                            ),
                            Text(
                              formatTimestamp(logsListDisplay[index].dateTime, 'HH:mm:ss')
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [ 
                      Text(
                        "No logs to display here.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
              )
          );

        case 2:
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 50),
                Text(
                  "Logs couldn't be loaded",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          );
          
        default:
          return const SizedBox();
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.maxFinite, 70),
        child: Container(
          margin: EdgeInsets.only(top: statusBarHeight),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
              )
            )
          ),
          child: _showSearchBar == false
            ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Query logs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showSearchBar = true;
                          });
                        }, 
                        icon: const Icon(Icons.search_rounded),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        onPressed: _showFiltersModal, 
                        icon: const Icon(Icons.filter_list_rounded),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 5),
                      PopupMenuButton(
                        splashRadius: 20,
                        icon: const Icon(Icons.sort_rounded),
                        onSelected: (value) => _updateSortStatus(value),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.arrow_downward_rounded),
                                    SizedBox(width: 10),
                                    Text("From latest to oldest"),
                                  ],
                                ),
                                CustomRadio(
                                  value: 0, 
                                  groupValue: sortStatus, 
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
                                  children: const [
                                    Icon(Icons.arrow_upward_rounded),
                                    SizedBox(width: 10),
                                    Text("From oldest to latest"),
                                  ],
                                ),
                                CustomRadio(
                                  value: 1, 
                                  groupValue: sortStatus, 
                                )
                              ],
                            )
                          ),
                        ]
                      )
                    ],
                  )
                ]
              ),
            )
          : SizedBox(
            height: 63,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _showSearchBar = false;
                    _searchController.text = "";
                    logsListDisplay = logsList;
                    sortStatus = 0;
                  }),
                  icon: const Icon(Icons.arrow_back),
                  splashRadius: 20,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: width-116,
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchLogs,
                    style: const TextStyle(
                      fontSize: 18
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search by URL...",
                      hintStyle: TextStyle(
                        fontSize: 18
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => setState(() => _searchController.text = ""), 
                  icon: const Icon(Icons.clear_rounded),
                  splashRadius: 20,
                  color: Colors.black,
                )
              ],
            ),
          )
        )
      ),
      body: _status()
    );
  }
}