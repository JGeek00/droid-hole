import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import 'package:droid_hole/widgets/servers_top_bar.dart';
import 'package:droid_hole/widgets/servers_list.dart';

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

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size(double.maxFinite, 60),
        child: ServersTopBar()
      ),
      body: ServersList(
        context: context,
        controllers: expandableControllerList, 
        onChange: _expandOrContract
      ),
    );
  }
}