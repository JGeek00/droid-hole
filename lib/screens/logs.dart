import 'package:droid_hole/widgets/log_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/log_details_modal.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/custom_radio.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';

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

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    if (serversProvider.connectedServer != null && serversProvider.isServerConnected == true) {
      return LogsList(server: serversProvider.connectedServer!); 
    }
    else if (serversProvider.connectedServer != null && serversProvider.isServerConnected == false) {
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
    else if (serversProvider.connectedServer == null) {
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

  const LogsList({
    Key? key,
    required this.server
  }) : super(key: key);

  @override
  State<LogsList> createState() => _LogsListState();
}

class _LogsListState extends State<LogsList> {
  int loadStatus = 0;
  List<Log> logsList = [];
  List<Log> logsListDisplay = [];
  int sortStatus = 0;

  Future loadLogs() async {
    final result = await fetchLogs(widget.server);
    if (result['result'] == 'success') {
      List<Log> items = [];
      result['data'].forEach((item) => items.add(Log.fromJson(item)));
      setState(() {
        loadStatus = 1;
        logsList = items.reversed.toList();
        logsListDisplay = items.reversed.toList();
      });
    }
    else {
      setState(() => loadStatus = 2);
    }
  }

  @override
  void initState() {
    loadLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    void _showLogDetails(Log log) {
      showModalBottomSheet(
        context: context, 
        builder: (context) => LogDetailsModal(
          log: log,
          statusBarHeight: statusBarHeight
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true, 
        enableDrag: true,
        isScrollControlled: true,
      );
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
            child: ListView.builder(
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
            ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
              )
            )
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
                    onPressed: () => {}, 
                    icon: const Icon(Icons.search_rounded),
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () => {}, 
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
            ],
          ),
        )
      ),
      body: _status()
    );
  }
}