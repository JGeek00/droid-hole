import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/widgets/bottom_nav_bar.dart';
import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/top_bar.dart';
import 'package:droid_hole/widgets/servers_list_modal.dart';

import 'package:droid_hole/providers/servers_provider.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final height = MediaQuery.of(context).size.height;

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

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.maxFinite, 84),
        child: TopBar(),
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
        ? SingleChildScrollView(
            child: Column(
              children: [
                serversProvider.isServerConnected == true 
                  ? const SizedBox()
                  : SizedBox(
                      height: height-130,
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
                    )
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