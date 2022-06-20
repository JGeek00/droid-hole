import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/servers_list.dart';
import 'package:droid_hole/widgets/add_server_modal.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class ServersListModal extends StatefulWidget {
  const ServersListModal({Key? key}) : super(key: key);

  @override
  State<ServersListModal> createState() => _ServersListModalState();
}

class _ServersListModalState extends State<ServersListModal> {
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

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1,
                )
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => {
                        Navigator.pop(context)
                      }, 
                      icon: const Icon(Icons.close),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 5),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "PiHole servers",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _openAddServerBottomSheet(), 
                  icon: const Icon(Icons.add),
                  splashRadius: 20,
                )
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              ),
              child:  ServersList(
                context: context,
                controllers: expandableControllerList,
                onChange: _expandOrContract
              ),
            ),
          )
        ],
      )
    );    
  }
}