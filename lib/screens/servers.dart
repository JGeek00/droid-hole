import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/servers_list.dart';

import 'package:droid_hole/models/server.dart';
import 'package:provider/provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class ServersPage extends StatefulWidget {
  const ServersPage({Key? key}) : super(key: key);

  @override
  State<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  List<int> expandedCards = [];

  List<int> showButtons = [];

  List<ExpandableController> expandableControllerList = [];

  void _expandOrContract(int index) async {
    expandableControllerList[index].expanded = !expandableControllerList[index].expanded;
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    for (var i = 0; i < serversProvider.getServersList.length; i++) {
      expandableControllerList.add(ExpandableController());
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

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.maxFinite, 80),
        child: Container(
          margin: const EdgeInsets.only(top: 25),
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 1
              )
            )

          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    splashRadius: 20,
                    onPressed: () => {
                      Navigator.pop(context)
                    }, 
                    icon: const Icon(Icons.arrow_back)
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Servers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  )
                ],
              ),
              IconButton(
                splashRadius: 20,
                onPressed: _openAddServerBottomSheet, 
                icon: const Icon(Icons.add)
              )
            ],
          ),
        )
      ),
      body: ServersList(
        context: context,
        controllers: expandableControllerList, 
        onChange: _expandOrContract
      ),
    );
  }
}