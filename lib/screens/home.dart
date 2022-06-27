import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';
import 'package:droid_hole/widgets/bar_chart.dart';
import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/servers_list_modal.dart';

import 'package:droid_hole/functions/bar_chart_format.dart';
import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/constants/colors.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    void _selectServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        showModalBottomSheet(
          context: context, 
          builder: (context) => const ServersListModal(),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false
        )
      });
    }

    void _disableServer(int time) async {
      final ProcessModal process = ProcessModal(context: context);
      process.open('Disabling server...');
      final result = await disableServer(
        serversProvider.selectedServer!, 
        serversProvider.selectedServerToken!['token'],
        serversProvider.selectedServerToken!['phpSessId'],
        time
      );
      process.close();
      if (result['result'] == 'success') {
        serversProvider.updateselectedServerStatus(false);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server disabled successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't disable server."),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _enableServer() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open('Enabling server...');
      final result = await enableServer(
        serversProvider.selectedServer!,
        serversProvider.selectedServerToken!['token'],
        serversProvider.selectedServerToken!['phpSessId']
      );
      process.close();
      if (result['result'] == 'success') {
        serversProvider.updateselectedServerStatus(true);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server enabled successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't enable server."),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _openDisableBottomSheet() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => DisableModal(
          onDisable: _disableServer 
        ),
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
      );
    }

    void _enableDisableServer() {
      if (
        serversProvider.isServerConnected == true &&
        serversProvider.selectedServer != null
      ) {
        if (serversProvider.selectedServer?.enabled == true) {
          _openDisableBottomSheet();
        }
        else {
          _enableServer();
        }
      }
    }

    Widget _tile({
      required double mainWidth,
      required double innerWidth,
      required IconData icon, 
      required Color iconColor, 
      required Color color, 
      required String label, 
      required String value,
      required EdgeInsets margin,
    }) {
      return Container(
        margin: margin,
        width: mainWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color
        ),
        child: Stack(
          children: [
            Container(
              height: 78,
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 50,
                    color: iconColor,
                  ),
                ],
              ),
            ),
            Container(
              width: innerWidth,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            )
          ] 
        )
      );
    }

    Widget _tiles() {
      switch (serversProvider.getStatusLoading) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 50),
                Text(
                  "Loading stats...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return Column(
            children: !(orientation == Orientation.landscape && height < 1000) 
              ? [
                Row(
                  children: [
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.public, 
                      iconColor: const Color.fromARGB(255, 64, 146, 66), 
                      color: Colors.green, 
                      label: "Total queries", 
                      value: intFormat(serversProvider.getRealtimeStatus!.dnsQueriesToday, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 8,
                        bottom: 8
                      )
                    ),
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.block, 
                      iconColor: const Color.fromARGB(255, 28, 127, 208), 
                      color: Colors.blue, 
                      label: "Queries blocked", 
                      value: intFormat(serversProvider.getRealtimeStatus!.adsBlockedToday, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 8,
                        right: 20,
                        bottom: 8
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.pie_chart, 
                      iconColor: const Color.fromARGB(255, 219, 131, 0), 
                      color: Colors.orange, 
                      label: "Percentage blocked", 
                      value: "${formatPercentage(serversProvider.getRealtimeStatus!.adsPercentageToday)}%",
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 20,
                        right: 8,
                        bottom: 20
                      )
                    ),
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.list, 
                      iconColor: const Color.fromARGB(255, 211, 58, 47), 
                      color: Colors.red, 
                      label: "Domains on Adlists", 
                      value: intFormat(serversProvider.getRealtimeStatus!.domainsBeingBlocked, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 20,
                        bottom: 20
                      )
                    ),
                  ],
                )
              ]
            : [
              Row(
                children: [
                  _tile(
                    mainWidth: (width-88)/4,
                      innerWidth: (width-80)/4,
                    icon: Icons.public, 
                    iconColor: const Color.fromARGB(255, 64, 146, 66), 
                    color: Colors.green, 
                    label: "Total queries", 
                    value: intFormat(serversProvider.getRealtimeStatus!.dnsQueriesToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.block, 
                    iconColor: const Color.fromARGB(255, 28, 127, 208), 
                    color: Colors.blue, 
                    label: "Queries blocked", 
                    value: intFormat(serversProvider.getRealtimeStatus!.adsBlockedToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.pie_chart, 
                    iconColor: const Color.fromARGB(255, 219, 131, 0), 
                    color: Colors.orange, 
                    label: "Percentage blocked", 
                    value: "${formatPercentage(serversProvider.getRealtimeStatus!.adsPercentageToday)}%",
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.list, 
                    iconColor: const Color.fromARGB(255, 211, 58, 47), 
                    color: Colors.red, 
                    label: "Domains on Adlists", 
                    value: intFormat(serversProvider.getRealtimeStatus!.domainsBeingBlocked, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 20,
                      bottom: 20
                    )
                  ),
                ],
              )
            ],
          );

        case 2: 
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 50),
                Text(
                  "Stats could not be loaded",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        default:
          return const SizedBox();
      }
    }

    List<Widget> _generateLegend(List values) {
      List<Widget> _generateRow(int length) {
        Widget _generateItem(int i) {
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: serversProvider.getOvertimeData!.clients[i].color
                  ),
                ),
                const SizedBox(width: 10),
                Text(serversProvider.getOvertimeData!.clients[i].ip)
              ],
            ),
          );
        }

        List<Widget> widgets = [];
        if (!(orientation == Orientation.landscape && height < 1000)) {
          for (var i = 0; i < length; i+=2) {
            widgets.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _generateItem(i),
                      i+1 < length ? _generateItem(i+1) : const SizedBox(),
                    ],
                  ),
                ],
              )
            );
          }
        }
        else {
          for (var i = 0; i < length; i+=4) {
            widgets.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _generateItem(i),
                      i+1 < length ? _generateItem(i+1) : const SizedBox(),
                      i+2 < length ? _generateItem(i+2) : const SizedBox(),
                      i+3 < length ? _generateItem(i+3) : const SizedBox(),
                    ],
                  ),
                ],
              )
            );
          }
        }
        return widgets;
      }

      if (values.length % 2 == 0) {
        return _generateRow(values.length);
      }
      else {
        return _generateRow(values.length);
      }
    }

    Widget _charts() {
      switch (serversProvider.getOvertimeDataLoadStatus) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 50),
                Text(
                  "Loading charts...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Total queries last 24 hours",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: BarChart(
                        seriesList: formatQueriesChart(serversProvider.getOvertimeDataJson!)
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text("Blocked")
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text("Not blocked")
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Client activity last 24 hours",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: BarChart(
                        seriesList: formatClientsChart(serversProvider.getOvertimeDataJson!)
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _generateLegend(serversProvider.getOvertimeData!.clients),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              )
            ],
          );

        case 2: 
          return SizedBox(
            width: double.maxFinite,
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 50),
                Text(
                  "Charts could not be loaded",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
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
      appBar: const PreferredSize(
        preferredSize: Size(double.maxFinite, 70),
        child: TopBar()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: serversProvider.selectedServer != null
        && serversProvider.isServerConnected == true
          ? FloatingActionButton(
              onPressed: _enableDisableServer,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.shield_rounded),
            )
          : null,
      body: serversProvider.selectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? RefreshIndicator(
              onRefresh: () async {
                await refreshServerStatus(context, serversProvider);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _tiles(),
                    _charts(),
                  ],
                )
              ),
            )
          : const Center(
              child: SelectedServerDisconnected()
            )
        : const NoServerSelected()
    );
  }
}