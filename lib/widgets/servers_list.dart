import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/delete_modal.dart';

import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

class ServersList extends StatelessWidget {
  final BuildContext context;
  final List<ExpandableController> controllers;
  final Function(int) onChange;

  const ServersList({
    Key? key,
    required this.context,
    required this.controllers,
    required this.onChange
  }) : super(key: key);

  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    List<Server> servers = serversProvider.getServersList;

    final width = MediaQuery.of(context).size.width;

    void _showDeleteModal(Server server) async {
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

    void _openAddServerBottomSheet({Server? server}) async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        showModalBottomSheet(
          context: context, 
          isScrollControlled: true,
          builder: (context) => AddServerModal(server: server),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
        )
      }));
    }

    void _connectToServer(Server server) async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.connecting);
      final result = await login(server);
      process.close();
      if (result['result'] == 'success') {
        serversProvider.setselectedServer(Server(
          address: server.address,
          alias: server.alias,
          password: server.password,
          defaultServer: server.defaultServer,
          enabled: result['status'] == 'enabled' ? true : false
        ));
        serversProvider.setselectedServerToken('phpSessId', result['phpSessId']);
        serversProvider.setselectedServerToken('token', result['token']);
        serversProvider.setIsServerConnected(true);
        serversProvider.setRefreshServerStatus(true);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ignore: use_build_context_synchronously
            content: Text(AppLocalizations.of(context)!.connectedSuccessfully),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        serversProvider.setIsServerConnected(false);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cannot connect to server."),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _setDefaultServer(Server server) async {
      final result = await serversProvider.setDefaultServer(server);
      if (result == true) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ignore: use_build_context_synchronously
            content: Text(AppLocalizations.of(context)!.connectionDefaultSuccessfully),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ignore: use_build_context_synchronously
            content: Text(AppLocalizations.of(context)!.connectionDefaultFailed),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    Widget _leadingIcon(Server server) {
      if (server.defaultServer == true) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.storage_rounded,
              color: serversProvider.selectedServer != null && serversProvider.selectedServer?.address == server.address
                ? serversProvider.isServerConnected == true 
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
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
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
            ? serversProvider.isServerConnected == true 
              ? Colors.green
              : Colors.orange
            : null,
        );
      }
    }

    Widget _topRow(Server server, int index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            margin: const EdgeInsets.only(right: 12),
            child: _leadingIcon(servers[index]),
          ),
          SizedBox(
            width: width-168,
            child: Column(
              children: [
                Text(
                  servers[index].address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      servers[index].alias,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () => onChange(index),
            icon: const Icon(Icons.arrow_drop_down),
            splashRadius: 20,
          ),
        ],
      );
    }

    Widget _bottomRow(Server server, int index) {
      return Column(
        children: [
          const SizedBox(height: 20),
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
                      ? (() => _setDefaultServer(server))
                      : null, 
                    child: Row(
                      children: [
                        const Icon(Icons.star),
                        const SizedBox(width: 15),
                        Text(
                          server.defaultServer == true 
                            ? AppLocalizations.of(context)!.defaultConnection
                            : AppLocalizations.of(context)!.setDefault
                        )
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => _openAddServerBottomSheet(server: server)), 
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.edit)
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => _showDeleteModal(server)), 
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
                child: serversProvider.selectedServer != null && serversProvider.selectedServer?.address == servers[index].address
                  ? Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: serversProvider.isServerConnected == true
                        ? Colors.green
                        : Colors.orange,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: [
                        Icon(
                          serversProvider.isServerConnected == true
                            ? Icons.check
                            : Icons.warning,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          serversProvider.isServerConnected == true
                            ? AppLocalizations.of(context)!.connected
                            : AppLocalizations.of(context)!.selectedDisconnected,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                      ),
                  )
                  : Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: TextButton.icon(
                        onPressed: () => _connectToServer(servers[index]), 
                        icon: const Icon(Icons.login), 
                        label: Text(AppLocalizations.of(context)!.connect),
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.green),
                          overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)),
                        ),
                      ),
                    ),
              )
            ],
          )
        ],
      );
    }

    return servers.isNotEmpty ? 
      ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1
              )
            )
          ),
          child: ExpandableNotifier(
            controller: controllers[index],
            child: Column(
              children: [
                Expandable(
                  collapsed: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onChange(index),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: _topRow(servers[index], index),
                      ),
                    ),
                  ),
                  expanded: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onChange(index),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _topRow(servers[index], index),
                            _bottomRow(servers[index], index)
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
    ) : SizedBox(
          height: double.maxFinite,
          width: width-40,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noSavedConnections,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
  }
}