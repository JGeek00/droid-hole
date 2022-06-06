import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';

import 'package:droid_hole/widgets/connecting_modal.dart';
import 'package:droid_hole/widgets/delete_modal.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Servers extends StatefulWidget {
  const Servers({Key? key}) : super(key: key);

  @override
  State<Servers> createState() => _ServersState();
}

class _ServersState extends State<Servers> {
  List<int> expandedCards = [];
  List<int> showButtons = [];

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    List<Server> servers = serversProvider.getServersList;

    List<ExpandableController> expandableControllerList = [];
    for (var i = 0; i < servers.length; i++) {
      expandableControllerList.add(ExpandableController());
    }

    void _expandOrContract(int index) async {
      expandableControllerList[index].expanded = !expandableControllerList[index].expanded;
    }

    final width = MediaQuery.of(context).size.width;

    void _showDeleteModal(Server server) {
      showDialog(
        context: context, 
        builder: (context) => DeleteModal(
          serverToDelete: server,
        ),
        barrierDismissible: false
      );
    }

    void _connectToServer(Server server) async {
      showDialog(
        context: context, 
        builder: (context) => const ConnectingModal(),
        barrierDismissible: false
      );
      final result = await login(server);
      if (result == 'success') {
        serversProvider.setConnectedServer(server);
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
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }

    Widget _topRow(Server server, int index) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            margin: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.storage_rounded,
              color: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == servers[index].address
                ? Colors.green : null,
            ),
          ),
          SizedBox(
            width: width-156,
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
            onPressed: () => _expandOrContract(index),
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
              Row(
                children: [
                  IconButton(
                    onPressed: (() => _showDeleteModal(server)), 
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    splashColor: Colors.red.withOpacity(0.1),
                    highlightColor: Colors.red.withOpacity(0.1),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: (() => {}), 
                    icon: const Icon(Icons.edit),
                    color: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    splashRadius: 20,
                  ),
                ],
              ),
              SizedBox(
                child: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == servers[index].address
                  ? Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Connected",
                          style: TextStyle(
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

    return Column(
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 15
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 1
              )
            )
          ),
          child: const Text(
            "PiHole servers",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(
          child: servers.isNotEmpty ? 
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
                  controller: expandableControllerList[index],
                  child: Column(
                    children: [
                      Expandable(
                        collapsed: Material(
                          child: InkWell(
                            onTap: () => _expandOrContract(index),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: _topRow(servers[index], index),
                            ),
                          ),
                        ),
                        expanded: Material(
                          child: InkWell(
                            onTap: () => _expandOrContract(index),
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
                    "No saved servers",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
        )
      ]
    );
  }
}