// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/servers/add_server_fullscreen.dart';
import 'package:droid_hole/screens/servers/servers_list.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
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
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    for (var i = 0; i < serversProvider.getServersList.length; i++) {
      expandableControllerList.add(ExpandableController());
    }

    void openAddServer({Server? server}) async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        if (width > 900) {
          showDialog(
            context: context, 
            builder: (context) => AddServerFullscreen(
              server: server,
              window: true,
            ),
            barrierDismissible: false
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

    return WillPopScope(
      onWillPop: () async {
        if (serversProvider.selectedServer == null) {
          appConfigProvider.setSelectedTab(0);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.servers),
        ),
        body: Stack(
          children: [
            ServersList(
              context: context, 
              controllers: expandableControllerList, 
              onChange: expandOrContract,
              scrollController: scrollController,
              breakingWidth: 700,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              bottom: isVisible ?
                appConfigProvider.showingSnackbar
                  ? 70 : (Platform.isIOS ? 40 : 20)
                : -70,
              right: 20,
              child: FloatingActionButton(
                onPressed: openAddServer,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      )
    );
  }
}