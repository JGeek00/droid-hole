// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/servers/add_server_fullscreen.dart';
import 'package:droid_hole/screens/servers/delete_modal.dart';

import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

class ServersTileItem extends StatefulWidget {
  final Server server;
  final int index;
  final void Function(int) onChange;
  final double breakingWidth;

  const ServersTileItem({
    Key? key,
    required this.server,
    required this.index,
    required this.onChange,
    required this.breakingWidth
  }) : super(key: key);

  @override
  State<ServersTileItem> createState() => _ServersTileItemState();
}

class _ServersTileItemState extends State<ServersTileItem> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void showDeleteModal(Server server) async {
      await Future.delayed(const Duration(seconds: 0), () => {
        showDialog(
          context: context, 
          builder: (context) => DeleteModal(
            serverToDelete: server,
          ),
          barrierDismissible: false
        )
      });
    }

    void openAddServerBottomSheet({Server? server}) async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        if (width > 700) {
          showDialog(
            context: context, 
            barrierDismissible: false,
            builder: (context) => AddServerFullscreen(
              server: server,
              window: true,
            ),
          )
        }
        else {
          Navigator.push(context, MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) => AddServerFullscreen(
              server: server,
              window: false,
            )
          ))
        }
      }));
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
          ),
          toHomeTab: true
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
        appConfigProvider.setSelectedTab(0);
      }

      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.connecting);

      final result = await loginQuery(server);
      process.close();
      if (result['result'] == 'success') {
        await connectSuccess(result);
      }
      else if (mounted) {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotConnect,
          color: Colors.red
        );
      }
    }

    void setDefaultServer(Server server) async {
      final result = await serversProvider.setDefaultServer(server);
      if (result == true) {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.connectionDefaultSuccessfully,
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.connectionDefaultFailed,
          color: Colors.red
        );
      }
    }

    Widget leadingIcon(Server server) {
      if (server.defaultServer == true) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.storage_rounded,
              color: serversProvider.selectedServer != null && serversProvider.selectedServer?.address == server.address
                ? statusProvider.isServerConnected == true 
                  ? Colors.green
                  : Colors.orange
                : null,
            ),
            SizedBox(
              width: 25,
              height: 25,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 10,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }
      else {
        return Icon(
          Icons.storage_rounded,
          color: serversProvider.selectedServer != null && serversProvider.selectedServer?.address == server.address
            ? statusProvider.isServerConnected == true 
              ? Colors.green
              : Colors.orange
            : null,
        );
      }
    }

    Widget topRow(Server server, int index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: leadingIcon(server),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.address,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 3),
                          Text(
                            server.alias,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget bottomRow(Server server, int index) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: server.defaultServer == false 
                      ? true
                      : false,
                    onTap: server.defaultServer == false 
                      ? (() => setDefaultServer(server))
                      : null, 
                    child: SizedBox(
                      child: Row(
                        children: [
                          const Icon(Icons.star),
                          const SizedBox(width: 15),
                          Text(
                            server.defaultServer == true 
                              ? AppLocalizations.of(context)!.defaultConnection
                              : AppLocalizations.of(context)!.setDefault,
                          )
                        ],
                      ),
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => openAddServerBottomSheet(server: server)), 
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.edit)
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => showDeleteModal(server)), 
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.delete)
                      ],
                    )
                  ),
                ]
              ),
              SizedBox(
                child: serversProvider.selectedServer != null && serversProvider.selectedServer?.address == serversProvider.getServersList[index].address
                    ? Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                            children: [
                              Icon(
                                statusProvider.isServerConnected == true
                                  ? Icons.check
                                  : Icons.warning,
                                color: statusProvider.isServerConnected == true
                                  ? Colors.green
                                  : Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                statusProvider.isServerConnected == true
                                  ? AppLocalizations.of(context)!.connected
                                  : AppLocalizations.of(context)!.selectedDisconnected,
                                style: TextStyle(
                                  color: statusProvider.isServerConnected == true
                                    ? Colors.green
                                    : Colors.orange,
                                  fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: FilledButton.icon(
                          icon: const Icon(Icons.login),
                          onPressed: () => connectToServer(server),
                          label: Text(AppLocalizations.of(context)!.connect),
                        ),
                      ),
              )
            ],
          )
        ],
      );
    }

    EdgeInsets generateMargins(int index) {
      if (index == 0) {
        return const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 8);
      }
      if (index == 1) {
        return const EdgeInsets.only(top: 16, left: 8, right: 16, bottom: 8);
      }
      else if (index == serversProvider.getServersList.length-1 && (index+1)%2 == 0) {
        return const EdgeInsets.only(top: 8, left: 8, right: 16, bottom: 16);
      }
      else if (index == serversProvider.getServersList.length-1 && (index+1)%2 == 1) {
        return const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 16);
      }
      else {
        if ((index+1)%2 == 0) {
          return const EdgeInsets.only(top: 8, left: 8, right: 16, bottom: 8);
        }
        else {
          return const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);
        }
      }
    }

    return FractionallySizedBox(
      widthFactor: width > widget.breakingWidth ? 0.5 : 1,
      child: Card(
        margin:  width > widget.breakingWidth
          ? generateMargins(widget.index)
          : const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: topRow(widget.server, widget.index),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8, right: 8, bottom: 16
              ),
              child: bottomRow(widget.server, widget.index),
            )
          ],
        ),
      ),
    );
  }
}