// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/switch_server_modal.dart';
import 'package:droid_hole/screens/servers.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class HomeAppBar extends StatelessWidget with PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  PreferredSizeWidget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void refresh() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.refreshingData);
      final result = await realtimeStatus(
        serversProvider.selectedServer!,
        serversProvider.phpSessId!
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
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.notConnectServer, 
          color: Colors.red
        );
      }
    }

    void changeServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const ServersPage()
        ))
      });
    }

    void openWebPanel() {
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

    void connectToServer(Server server) async {
      Future connectSuccess(result) async {
        serversProvider.setselectedServer(Server(
          address: server.address,
          alias: server.alias,
          token: server.token!,
          defaultServer: server.defaultServer,
          enabled: result['status'] == 'enabled' ? true : false
        ));
        serversProvider.setPhpSessId(result['phpSessId']);
        final statusResult = await realtimeStatus(server, result['phpSessId']);
        if (statusResult['result'] == 'success') {
          serversProvider.setRealtimeStatus(statusResult['data']);
        }
        final overtimeDataResult = await fetchOverTimeData(server, result['phpSessId']);
        if (overtimeDataResult['result'] == 'success') {
          serversProvider.setOvertimeData(overtimeDataResult['data']);
          serversProvider.setOvertimeDataLoadingStatus(1);
        }
        else {
          serversProvider.setOvertimeDataLoadingStatus(2);
        }
        serversProvider.setIsServerConnected(true);
        serversProvider.setRefreshServerStatus(true);
      }

      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.connecting);

      final result = await loginQuery(server);
      process.close();
      if (result['result'] == 'success') {
        await connectSuccess(result);
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotConnect,
          color: Colors.red
        );
      }
    }

    void openSwitchServerModal() {
      showDialog(
        context: context, 
        builder: (context) => SwitchServerModal(
          onServerSelect: connectToServer,
        )
      );
    }

    return AppBar(
      systemOverlayStyle: systemUiOverlayStyleConfig(context),
      toolbarHeight: 70,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: openSwitchServerModal,
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
                            fontSize: 20
                          ),
                        ),
                        Text(
                          serversProvider.selectedServer!.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14
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
                      ),
                    ),
                  ),
                ]
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton(
          splashRadius: 20,
          color: Theme.of(context).dialogBackgroundColor,
          itemBuilder: (context) => 
            serversProvider.selectedServer != null 
              ? serversProvider.isServerConnected == true 
                ? [
                    PopupMenuItem(
                      onTap: refresh,
                      child: Row(
                        children: [
                          const Icon(Icons.refresh),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.refresh)
                        ],
                      )
                    ),
                    PopupMenuItem(
                      onTap: openWebPanel,
                      child: Row(
                        children: [
                          const Icon(Icons.web),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.openWebPanel)
                        ],
                      )
                    ),
                    PopupMenuItem(
                      onTap: changeServer,
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
                    onTap: refresh,
                    child: Row(
                      children: [
                        const Icon(Icons.refresh_rounded),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.tryReconnect)
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: changeServer,
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
                  onTap: changeServer,
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
    );
  }
    
  @override
  Size get preferredSize => const Size.fromHeight(70);
}