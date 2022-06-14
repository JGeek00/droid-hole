import 'package:droid_hole/functions/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
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

    if (serversProvider.connectedServer != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Material(
              elevation: 5.0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          serversProvider.connectedServer!.alias 
                            ?? serversProvider.connectedServer!.address,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _serverStatus()
                      ],
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => 
                        serversProvider.isServerConnected == true 
                          ? [
                              PopupMenuItem(
                                onTap: _refresh,
                                child: Row(
                                  children: const [
                                    Icon(Icons.refresh),
                                    SizedBox(width: 15),
                                    Text("Refresh")
                                  ],
                                )
                              ),
                              PopupMenuItem(
                                onTap: _openWebPanel,
                                child: Row(
                                  children: const [
                                    Icon(Icons.web),
                                    SizedBox(width: 15),
                                    Text("Open web panel")
                                  ],
                                )
                              ),
                            ]
                          : [
                            PopupMenuItem(
                              onTap: () => {},
                              child: Row(
                                children: const [
                                  Icon(Icons.refresh_rounded),
                                  SizedBox(width: 15),
                                  Text("Try reconnect")
                                ],
                              )
                            ),
                          ]
                    )
                  ],
                ),
              ),
            ),
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
      );
    }
    else {
      return Center(
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
      );
    }
  }
}