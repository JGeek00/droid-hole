import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/servers_list.dart';
import 'package:droid_hole/widgets/add_server_fullscreen.dart';

import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Connect extends StatefulWidget {
  const Connect({Key? key}) : super(key: key);

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  List<int> expandedCards = [];
  List<int> showButtons = [];

  List<ExpandableController> expandableControllerList = [];

  void _expandOrContract(int index) async {
    expandableControllerList[index].expanded = !expandableControllerList[index].expanded;
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    for (var i = 0; i < serversProvider.getServersList.length; i++) {
      expandableControllerList.add(ExpandableController());
    }

    void _addServerModal() async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        Navigator.push(context, MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => const AddServerFullscreen()
        ))
      }));
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: systemUiOverlayStyleConfig(context),
        title: Text(AppLocalizations.of(context)!.connectToServer),
        centerTitle: true,
      ),
      body: serversProvider.getServersList.isNotEmpty
        ? SizedBox(
            width: mediaQuery.size.width,
            height: mediaQuery.size.height-174,
            child: ServersList(
              context: context, 
              controllers: expandableControllerList, 
              onChange: _expandOrContract
            ),
          )
        : Padding(
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
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey
                    ),
                  ),
                  const SizedBox(height: 30),
                  OutlinedButton.icon(
                    onPressed: _addServerModal, 
                    label: Text(AppLocalizations.of(context)!.createConnection),
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ),
          )
    );
  }
}