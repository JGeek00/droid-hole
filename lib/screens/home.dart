import 'package:droid_hole/functions/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

import 'package:droid_hole/providers/servers_provider.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final height = MediaQuery.of(context).size.height;

    void _openWebPanel() {
      if (serversProvider.isServerConnected == true) {
        FlutterWebBrowser.openWebPage(
          url: '${serversProvider.connectedServer!.address}/admin/',
          customTabsOptions: const CustomTabsOptions(
            instantAppsEnabled: true,
            showTitle: true,
            urlBarHidingEnabled: false,
          ),
          safariVCOptions: const SafariViewControllerOptions(
            barCollapsingEnabled: true,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
            modalPresentationCapturesStatusBarAppearance: true,
          )
        );
      }
    }

    void _refresh() async {
      if (serversProvider.isServerConnected  == true) {
        await Future.delayed(const Duration(seconds: 0), () => {
          openProcessModal(context, "Refreshing data...")
        });
        final result = await status(serversProvider.connectedServer!);
        // ignore: use_build_context_synchronously
        closeProcessModal(context);
        if (result['result'] == "success") {
          serversProvider.updateConnectedServerStatus(
            result['data']['status'] == 'enabled' ? true : false
          );
        }
      }
    }

    Widget _serverStatus() {
      Color _dotColor() {
        if (serversProvider.isServerConnected == true) {
          if (serversProvider.connectedServer!.enabled == true) {
            return Colors.green;
          }
          else {
            return Colors.red;
          }
        }
        else {
          return Colors.grey;
        }
      }

      String _stringText() {
        if (serversProvider.isServerConnected == true) {
          if (serversProvider.connectedServer!.enabled == true) {
            return "Enabled";
          }
          else {
            return "Disabled";
          }
        }
        else {
          return "Disconnected";
        }
      }

      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _dotColor()
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _stringText(),
            style: const TextStyle(
              fontSize: 12
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: const PreferredSize(
            preferredSize: Size(double.maxFinite, 84),
            child: TopBar(),
          ),
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
              children: const [
                Icon(
                  Icons.link_off,
                  size: 70,
                  color: Colors.grey,
                ),
                SizedBox(height: 50),
                Text(
                  "No server is selected",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Go to Servers tab and select a connection",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18
                  ),
                )
              ],
            ),
          )
    );
  }
}