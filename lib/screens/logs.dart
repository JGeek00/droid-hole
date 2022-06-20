import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/custom_radio.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/server.dart';

class Logs extends StatelessWidget {
  const Logs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    if (serversProvider.connectedServer != null && serversProvider.isServerConnected == true) {
      return LogsList(server: serversProvider.connectedServer!); 
    }
    else if (serversProvider.connectedServer != null && serversProvider.isServerConnected == false) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.maxFinite, 90),
          child: TopBar()
        ),
        body: Center(
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
  List<dynamic> logsList = [];
  List<dynamic> logsListDisplay = [];
  int sortStatus = 0;

  Future loadLogs() async {
    final result = await fetchLogs(widget.server);
    if (result['result'] == 'success') {
      setState(() {
        loadStatus = 1;
        logsList = result['data'].reversed.toList();
        logsListDisplay = result['data'].reversed.toList();
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

    Widget _logStatusWidget({
      required IconData icon, 
      required Color color, 
      required String text
    }) {
      return Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),  
          )
        ],
      );
    }

    Widget _logStatus(String status) {
      switch (status) {
        case "1":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (gravity)"
          );

        case "2":
        case "3":
          return _logStatusWidget(
            icon: Icons.verified_user_rounded, 
            color: Colors.green, 
            text: "OK"
          );

        case "4":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (regex blacklist)"
          );

        case "5":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (exact blacklist)"
          );

        case "6":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (exact blacklist)"
          );

        default:
          return _logStatusWidget(
            icon: Icons.shield_rounded, 
            color: Colors.grey, 
            text: "Unknown"
          );
      }
    }

    String _formatTimestamp(int timestamp) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp*1000);
      DateFormat f = DateFormat('HH:mm:ss');
      return f.format(dateTime);
    }

    void _updateSortStatus(value) {
      if (sortStatus != value) {
        setState(() {
          sortStatus = value;
          logsListDisplay = logsListDisplay.reversed.toList();
        });
      }
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
                  onTap: () => {},
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
                            _logStatus(logsListDisplay[index][4]),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: width-100,
                              child: Text(
                                logsListDisplay[index][2],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              logsListDisplay[index][3],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13
                              ),
                            )
                          ],
                        ),
                        Text(
                          _formatTimestamp(int.parse(logsListDisplay[index][0]))
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