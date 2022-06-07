import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

import 'package:droid_hole/providers/servers_provider.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    void _openWebPanel() {
      if (serversProvider.connectedServer != null) {
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
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: serversProvider.connectedServer!.enabled == true
                                  ? Colors.green
                                  : Colors.red
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              serversProvider.connectedServer!.enabled == true
                                ? "Enabled"
                                : "Disabled",
                              style: const TextStyle(
                                fontSize: 12
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
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
                    )
                  ],
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
              "No server is connected",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 24
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Go to Servers tab and connect to one",
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