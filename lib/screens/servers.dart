import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void _expandOrContract(int index) async {
    if (expandedCards.contains(index) && showButtons.contains(index)) {
      setState(() {
        showButtons.removeWhere((i) => i == index);
        expandedCards.removeWhere((i) => i == index);
      });
    }
    else if (!expandedCards.contains(index) && !showButtons.contains(index)) {
      setState(() => {
        expandedCards.add(index)
      });
      await Future.delayed(const Duration(milliseconds: 250), (() => {
        setState(() => {
          showButtons.add(index)
        })
      }));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    List<Server> servers = serversProvider.getServersList;

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

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 15
          ),
          child: Text(
            "PiHole servers",
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
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5
                ),
                child: SizedBox(
                  width: width-20,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _expandOrContract(index),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        height: expandedCards.contains(index) ? 136 : 68,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 48,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.storage_rounded,
                                      color: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == servers[index].address
                                        ? Colors.green : Colors.red,
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
                                    icon: const Icon(Icons.arrow_drop_down)
                                  ),
                                ],
                              ),
                              if (showButtons.contains(index)) Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showDeleteModal(servers[index]), 
                                        icon: const Icon(Icons.delete), 
                                        label: const Text("Remove"),
                                        style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all(Colors.red),
                                          overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: const BorderSide(
                                                color: Colors.red,
                                                width: 1
                                              )
                                            )
                                          )
                                        ),
                                      ),
                                      SizedBox(
                                        child: serversProvider.connectedServer != null && serversProvider.connectedServer?.address == servers[index].address
                                          ? Row(
                                            children: const [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                "Connected",
                                                style: TextStyle(
                                                  color: Colors.green
                                                ),
                                              )
                                            ],
                                            )
                                          : TextButton.icon(
                                              onPressed: () => _connectToServer(servers[index]), 
                                              icon: const Icon(Icons.login), 
                                              label: const Text("Connect"),
                                              style: ButtonStyle(
                                                foregroundColor: MaterialStateProperty.all(Colors.green),
                                                overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1)),
                                                shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: const BorderSide(
                                                      color: Colors.green,
                                                      width: 1
                                                    )
                                                  )
                                                )
                                              ),
                                            ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            )
            : const SizedBox(
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
        ),
      ],
    );
  }
}