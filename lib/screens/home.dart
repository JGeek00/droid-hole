import 'package:droid_hole/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/bar_chart.dart';
import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/servers_list_modal.dart';

import 'package:droid_hole/functions/bar_chart_format.dart';
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
      final result = await disableServer(serversProvider.connectedServer!, time);
      process.close();
      if (result['result'] == 'success') {
        serversProvider.updateConnectedServerStatus(false);
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
      final result = await enableServer(serversProvider.connectedServer!);
      process.close();
      if (result['result'] == 'success') {
        serversProvider.updateConnectedServerStatus(true);
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
        serversProvider.connectedServer != null
      ) {
        if (serversProvider.connectedServer?.enabled == true) {
          _openDisableBottomSheet();
        }
        else {
          _enableServer();
        }
      }
    }

    double _calculateGridHeight() {
      if (serversProvider.getOvertimeData!.clients.length % 2 == 1) {
        return (serversProvider.getOvertimeData!.clients.length/2)*40;
      }
      else {
        int count = serversProvider.getOvertimeData!.clients.length + 1;
        return (count/2)*38;
      }
    } 

    Widget _tile({
      required IconData icon, 
      required Color iconColor, 
      required Color color, 
      required String label, 
      required String value,
      required EdgeInsets margin,
    }) {
      return Container(
        margin: margin,
        padding: const EdgeInsets.all(10),
        width: (width-60)/2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 90,
                  color: iconColor,
                ),
              ],
            ),
            Container(
              width: (width-80)/2,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
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
            children: [
              Row(
                children: [
                  _tile(
                    icon: Icons.public, 
                    iconColor: const Color.fromARGB(255, 64, 146, 66), 
                    color: Colors.green, 
                    label: "Total queries", 
                    value: intFormat(serversProvider.getRealtimeStatus!.dnsQueriesToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 10,
                      bottom: 10
                    )
                  ),
                  _tile(
                    icon: Icons.block, 
                    iconColor: const Color.fromARGB(255, 28, 127, 208), 
                    color: Colors.blue, 
                    label: "Queries blocked", 
                    value: intFormat(serversProvider.getRealtimeStatus!.adsBlockedToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 10,
                      right: 20,
                      bottom: 10
                    )
                  ),
                ],
              ),
              Row(
                children: [
                  _tile(
                    icon: Icons.pie_chart, 
                    iconColor: const Color.fromARGB(255, 219, 131, 0), 
                    color: Colors.orange, 
                    label: "Percentage blocked", 
                    value: "${formatPercentage(serversProvider.getRealtimeStatus!.adsPercentageToday)}%",
                    margin: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 10,
                      bottom: 20
                    )
                  ),
                  _tile(
                    icon: Icons.list, 
                    iconColor: const Color.fromARGB(255, 211, 58, 47), 
                    color: Colors.red, 
                    label: "Domains on Adlists", 
                    value: intFormat(serversProvider.getRealtimeStatus!.domainsBeingBlocked, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 10,
                      left: 10,
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
                      height: _calculateGridHeight(),
                      width: double.maxFinite,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 8,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 10
                        ),
                        itemCount: serversProvider.getOvertimeData!.clients.length,
                        itemBuilder: (context, index) => SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: colors[index]
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(serversProvider.getOvertimeData!.clients[index].ip)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    )
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
        preferredSize: Size(double.maxFinite, 90),
        child: TopBar()
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: serversProvider.connectedServer != null
        && serversProvider.isServerConnected == true
          ? FloatingActionButton(
              onPressed: _enableDisableServer,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.shield_rounded),
            )
          : null,
      body: serversProvider.connectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? SingleChildScrollView(
              child: Column(
                children: [
                  _tiles(),
                  _charts(),
                ],
              )
          )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: height-180,
                      child: const Center(
                        child: Text(
                          "Selected server is disconnected",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.link_off,
                  size: 70,
                  color: Colors.grey,
                ),
                const SizedBox(height: 50),
                const Text(
                  "No server is selected",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                const SizedBox(height: 50),
                OutlinedButton.icon(
                  onPressed: _selectServer, 
                  label: const Text("Select a connection"),
                  icon: const Icon(Icons.storage_rounded),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1.0, 
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }
}