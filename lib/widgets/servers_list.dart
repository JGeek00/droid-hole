import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';

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
      process.open("Connecting...");
      final result = await login(server);
      process.close();
      if (result['result'] == 'success') {
        serversProvider.setConnectedServer(Server(
          address: server.address,
          alias: server.alias,
          token: server.token,
          defaultServer: server.defaultServer,
          enabled: result['status'] == 'enabled' ? true : false
        ));
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connected to server successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
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
          const SnackBar(
            content: Text("Connection set as default successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connection could not be set as default."),
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
              color: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == server.address
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
          color: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == server.address
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
                if (servers[index].alias != null) Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      servers[index].alias!,
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
                            ? "Default connection"
                            : "Set as default connection"
                        )
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => _openAddServerBottomSheet(server: server)), 
                    child: Row(
                      children: const [
                        Icon(Icons.edit),
                        SizedBox(width: 15),
                        Text("Edit")
                      ],
                    )
                  ),
                  PopupMenuItem(
                    onTap: (() => _showDeleteModal(server)), 
                    child: Row(
                      children: const [
                        Icon(Icons.delete),
                        SizedBox(width: 15),
                        Text("Delete")
                      ],
                    )
                  ),
                ]
              ),
              SizedBox(
                child: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == servers[index].address
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
                            ? "Connected"
                            : "Selected but disconnected",
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
                        label: const Text("Connect"),
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
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
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
    ) : const SizedBox(
          height: double.maxFinite,
          child: Center(
            child: Text(
              "No saved connections",
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
  }
}