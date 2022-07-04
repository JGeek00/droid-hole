// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/servers_list_modal.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final width = MediaQuery.of(context).size.width;

    void _openWebPanel() {
      if (serversProvider.isServerConnected == true) {
        FlutterWebBrowser.openWebPage(
          url: '${serversProvider.selectedServer!.address}/admin/',
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
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.refreshingData);
      final result = await realtimeStatus(
        serversProvider.selectedServer!,
        serversProvider.selectedServerToken!['phpSessId']
      );
      process.close();
      if (result['result'] == "success") {
        serversProvider.updateselectedServerStatus(
          result['data'].status == 'enabled' ? true : false
        );
        serversProvider.setIsServerConnected(true);
        serversProvider.setRealtimeStatus(result['data']);
      }
      else {
        serversProvider.setIsServerConnected(false);
        if (serversProvider.getStatusLoading == 0) {
          serversProvider.setStatusLoading(2);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notConnectServer),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _changeServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        showModalBottomSheet(
          context: context, 
          builder: (context) => const ServersListModal(),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true
        )
      });
    }

    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: serversProvider.selectedServer != null 
                ? [
                    Icon(
                      serversProvider.isServerConnected == true 
                        ? serversProvider.selectedServer!.enabled == true 
                          ? Icons.verified_user_rounded
                          : Icons.gpp_bad_rounded
                        : Icons.shield_rounded,
                      size: 30,
                      color: serversProvider.isServerConnected == true 
                        ? serversProvider.selectedServer!.enabled == true
                          ? Colors.green
                          : Colors.red
                        : Colors.grey
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serversProvider.selectedServer!.alias,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22
                          ),
                        ),
                        Text(
                          serversProvider.selectedServer!.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey
                          )
                        )
                      ],
                    ),
                  ]
                : [
                  const Icon(
                    Icons.shield,
                    color: Colors.grey,
                    size: 30,
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: width - 128,
                    child: Text(
                      AppLocalizations.of(context)!.noServerSelected,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22
                      ),
                    ),
                  ),
                ]
            ),
          ),
          PopupMenuButton(
            splashRadius: 20,
            itemBuilder: (context) => 
              serversProvider.selectedServer != null 
                ? serversProvider.isServerConnected == true 
                  ? [
                      PopupMenuItem(
                        onTap: _refresh,
                        child: Row(
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.refresh)
                          ],
                        )
                      ),
                      PopupMenuItem(
                        onTap: _openWebPanel,
                        child: Row(
                          children: [
                            const Icon(Icons.web),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.openWebPanel)
                          ],
                        )
                      ),
                      PopupMenuItem(
                        onTap: _changeServer,
                        child: Row(
                          children: [
                            const Icon(Icons.storage_rounded),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.changeServer)
                          ],
                        )
                      ),
                    ]
                  : [
                    PopupMenuItem(
                      onTap: _refresh,
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.tryReconnect)
                        ],
                      )
                    ),
                    PopupMenuItem(
                      onTap: _changeServer,
                      child: Row(
                        children: [
                          const Icon(Icons.storage_rounded),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.changeServer)
                        ],
                      )
                    ),
                  ]
                : [
                  PopupMenuItem(
                    onTap: _changeServer,
                    child: Row(
                      children: [
                        const Icon(Icons.storage_rounded),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.selectServer)
                      ],
                    )
                  ),
                ]
          )
        ],
      ),
    );
  }
}