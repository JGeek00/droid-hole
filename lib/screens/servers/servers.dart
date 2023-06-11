// ignore_for_file: use_build_context_synchronously

import 'package:droid_hole/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/unlock.dart';

import 'package:droid_hole/screens/servers/add_server_fullscreen.dart';
import 'package:droid_hole/screens/servers/delete_modal.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/server.dart';

class ServersPage extends StatefulWidget {
  final bool? isFromBase;

  const ServersPage({
    Key? key,
    this.isFromBase,
  }) : super(key: key);

  @override
  State<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  late bool isVisible;
  final ScrollController scrollController = ScrollController();

  List<int> expandedCards = [];

  List<int> showButtons = [];

  List<ExpandableController> expandableControllerList = [];

  void expandOrContract(int index) async {
    expandableControllerList[index].expanded = !expandableControllerList[index].expanded;
  }

  @override
  void initState() {
    super.initState();

    isVisible = true;
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (mounted && isVisible == true) {
          setState(() => isVisible = false);
        }
      } 
      else {
        if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (mounted && isVisible == false) {
            setState(() => isVisible = true);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    for (var i = 0; i < serversProvider.getServersList.length; i++) {
      expandableControllerList.add(ExpandableController());
    }

    void openAddServer({Server? server}) async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        Navigator.push(context, MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => AddServerFullscreen(server: server)
        ))
      }));
    }

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

    void connectToServer(Server server) async {
      Future connectSuccess(result) async {
        serversProvider.setselectedServer(Server(
          address: server.address,
          alias: server.alias,
          token: server.token!,
          defaultServer: server.defaultServer,
          enabled: result['status'] == 'enabled' ? true : false
        ));
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

    void setDefaultServer(Server server) async {
      final result = await serversProvider.setDefaultServer(server);
      if (result == true) {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.connectionDefaultSuccessfully,
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          context: context, 
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
          Container(
            width: 48,
            margin: const EdgeInsets.only(right: 12),
            child: leadingIcon(serversProvider.getServersList[index]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serversProvider.getServersList[index].address,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      serversProvider.getServersList[index].alias,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () => expandOrContract(index),
            icon: const Icon(Icons.arrow_drop_down),
            splashRadius: 20,
          ),
        ],
      );
    }

    Widget bottomRow(Server server, int index) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
                    onTap: (() => openAddServer(server: server)), 
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
                  ? Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: statusProvider.isServerConnected == true
                        ? Colors.green
                        : Colors.orange,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusProvider.isServerConnected == true
                            ? Icons.check
                            : Icons.warning,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          statusProvider.isServerConnected == true
                            ? AppLocalizations.of(context)!.connected
                            : AppLocalizations.of(context)!.selectedDisconnected,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ],
                      ),
                  )
                  : Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: () => connectToServer(serversProvider.getServersList[index]),
                        child: Text(AppLocalizations.of(context)!.connect),
                      ),
                    ),
              )
            ],
          )
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (serversProvider.selectedServer == null) {
          appConfigProvider.setSelectedTab(0);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: systemUiOverlayStyleConfig(context),
          title: Text(
            widget.isFromBase == true
              ? AppLocalizations.of(context)!.connect
              : AppLocalizations.of(context)!.servers,
          ),
        ),
        body: serversProvider.getServersList.isNotEmpty ? 
          ListView.builder(
            controller: scrollController,
            itemCount: serversProvider.getServersList.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    width: 1
                  )
                )
              ),
              child: ExpandableNotifier(
                controller: expandableControllerList[index],
                child: Column(
                  children: [
                    Expandable(
                      collapsed: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => expandOrContract(index),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: topRow(serversProvider.getServersList[index], index),
                          ),
                        ),
                      ),
                      expanded: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => expandOrContract(index),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                topRow(serversProvider.getServersList[index], index),
                                bottomRow(serversProvider.getServersList[index], index)
                              ],
                            ),
                          ),
                        ),
                      )
                    ) 
                  ],
                ),
              ),
            )
        ) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.noConnections,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.beginAddConnection,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        floatingActionButton: appConfigProvider.showingSnackbar
          ? null
          : isVisible 
            ? FloatingActionButton(
                onPressed: openAddServer,
                child: const Icon(Icons.add),
              )
        : null
      ),
    );
  }
}