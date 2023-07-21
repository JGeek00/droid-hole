// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/home/switch_server_modal.dart';
import 'package:droid_hole/screens/servers/servers.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/functions/open_url.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool innerBoxIsScrolled;

  const HomeAppBar({
    Key? key,
    required this.innerBoxIsScrolled
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void refresh() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.refreshingData);
      final result = await realtimeStatus(
        serversProvider.selectedServer!
      );
      process.close();
      if (result['result'] == "success") {
        serversProvider.updateselectedServerStatus(
          result['data'].status == 'enabled' ? true : false
        );
        statusProvider.setIsServerConnected(true);
        statusProvider.setRealtimeStatus(result['data']);
      }
      else {
        statusProvider.setIsServerConnected(false);
        if (statusProvider.getStatusLoading == LoadStatus.loading) {
          statusProvider.setStatusLoading(LoadStatus.error);
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

    void connectToServer(Server server) async {
      Future connectSuccess(result) async {
        serversProvider.setselectedServer(
          server: Server(
            address: server.address,
            alias: server.alias,
            token: server.token!,
            defaultServer: server.defaultServer,
            enabled: result['status'] == 'enabled' ? true : false
          )
        );
        final statusResult = await realtimeStatus(server);
        if (statusResult['result'] == 'success') {
          statusProvider.setRealtimeStatus(statusResult['data']);
        }
        final overtimeDataResult = await fetchOverTimeData(server);
        if (overtimeDataResult['result'] == 'success') {
          statusProvider.setOvertimeData(overtimeDataResult['data']);
          statusProvider.setOvertimeDataLoadingStatus(1);
        }
        else {
          statusProvider.setOvertimeDataLoadingStatus(2);
        }
        statusProvider.setIsServerConnected(true);
        statusProvider.setRefreshServerStatus(true);
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

    return SliverAppBar.large(
      systemOverlayStyle: systemUiOverlayStyleConfig(context),
      pinned: true,
      floating: true,
      centerTitle: false,
      forceElevated: innerBoxIsScrolled,
      leading: Icon(
        statusProvider.isServerConnected == true 
          ? serversProvider.selectedServer!.enabled == true 
            ? Icons.verified_user_rounded
            : Icons.gpp_bad_rounded
          : Icons.shield_rounded,
        size: 30,
        color: statusProvider.isServerConnected == true 
          ? serversProvider.selectedServer!.enabled == true
            ? Colors.green
            : Colors.red
          : Colors.grey
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: openSwitchServerModal,
            child: serversProvider.selectedServer != null 
              ? Column(
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
                      style: TextStyle(
                        color: Theme.of(context).listTileTheme.textColor,
                        fontSize: 14
                      )
                    )
                  ],
                )
              : SizedBox(
                  width: width - 128,
                  child: Text(
                    AppLocalizations.of(context)!.noServerSelected,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          )
        ],
      ),
      actions: [
        PopupMenuButton(
          splashRadius: 20,
          itemBuilder: (context) => 
            serversProvider.selectedServer != null 
              ? statusProvider.isServerConnected == true 
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
                      onTap: () => openUrl('${serversProvider.selectedServer!.address}/admin/'),
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