import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/functions/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

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

    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: 20
      ),
      margin: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                serversProvider.connectedServer!.enabled == true 
                  ? Icons.verified_user_rounded
                  : Icons.gpp_bad_rounded,
                size: 35,
                color: serversProvider.connectedServer!.enabled == true
                  ? Colors.green
                  : Colors.red,
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serversProvider.connectedServer!.alias!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ),
                  Text(
                    serversProvider.connectedServer!.address,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey
                    ),
                  )
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: PopupMenuButton(
              splashRadius: 20,
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
            ),
          )
        ],
      ),
    );
  }
}