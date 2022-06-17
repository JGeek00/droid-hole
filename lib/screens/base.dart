import 'dart:async';

import 'package:droid_hole/screens/lists.dart';
import 'package:droid_hole/screens/statistics.dart';
import 'package:droid_hole/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/screens/settings.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/functions/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/models/app_screen.dart';
import 'package:droid_hole/models/fab.dart';

class Base extends StatefulWidget {
  final int refreshTime;
  const Base({
    Key? key,
    required this.refreshTime
  }) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int selectedScreen = 0;

  Timer? timer;

  void _changeScreen(screeenIndex) {
    setState(() {
      selectedScreen = screeenIndex;
    });
  }

  int? previousRefreshTime;
  void update(ServersProvider serversProvider, int refreshTime) {
    // Sets previousRefreshTime when is not initialized
    previousRefreshTime ??= widget.refreshTime;

    bool isRunning = false; // Prevents async request from being executed when last one is not completed yet
    timer = Timer.periodic(Duration(seconds: widget.refreshTime), (timer) async {
      // Restarts the timer when time changes
      if (widget.refreshTime != previousRefreshTime) {
        timer.cancel();
        previousRefreshTime = widget.refreshTime;
        update(serversProvider, widget.refreshTime);
      }

      if (isRunning == false) {
        isRunning = true;
        if (serversProvider.connectedServer != null) {
          final statusResult = await status(serversProvider.connectedServer!);
          if (statusResult['result'] == 'success') {
            serversProvider.updateConnectedServerStatus(
              statusResult['data']['status'] == 'enabled' ? true : false
            );
          }
          isRunning = false;
        }
        else {
          timer.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    if (serversProvider.isServerConnected == true && timer == null) {
      update(serversProvider, appConfigProvider.getAutoRefreshTime!);
    }
    else if (serversProvider.isServerConnected == true && timer != null && timer!.isActive == false) {
      update(serversProvider, appConfigProvider.getAutoRefreshTime!);
    }
    else if (serversProvider.isServerConnected == false && timer != null) {
      timer!.cancel();
    }

    void _disableServer(int time) async {
      openProcessModal(context, 'Disabling server...');
      final result = await disableServer(serversProvider.connectedServer!, time);
      // ignore: use_build_context_synchronously
      closeProcessModal(context);
      if (result['result'] == 'success') {
        serversProvider.updateConnectedServerStatus(false);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server disabled successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't disable server."),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _openDisableBottomSheet() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => DisableModal(
          onDisable: _disableServer 
        ),
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
      );
    }

    void _openAddServerBottomSheet() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => const AddServerModal(),
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
      );
    }

    void _enableServer() async {
      openProcessModal(context, 'Enabling server...');
      final result = await enableServer(serversProvider.connectedServer!);
      // ignore: use_build_context_synchronously
      closeProcessModal(context);
      if (result['result'] == 'success') {
        serversProvider.updateConnectedServerStatus(true);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Server enabled successfully."),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't enable server."),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _enableDisableServer() {
      if (
        serversProvider.isServerConnected == true &&
        serversProvider.connectedServer != null
      ) {
        if (serversProvider.connectedServer?.enabled == true) {
          _openDisableBottomSheet();
        }
        else {
          _enableServer();
        }
      }
    }

    List<AppScreen> appScreens = [
      AppScreen(
        screenIcon: const Icon(Icons.home), 
        screenName: "Home", 
        screenWidget: const Home(),
        hasAppBar: true,
        screenFab: serversProvider.isServerConnected == true 
          && serversProvider.connectedServer != null
            ? Fab(
                icon: const Icon(Icons.shield_rounded), 
                color: Theme.of(context).primaryColor,
                onTap: _enableDisableServer
              ) 
            : null
      ),
      const AppScreen(
        screenIcon: Icon(Icons.analytics_rounded), 
        screenName: "Statistics", 
        screenWidget: Statistics(),
        hasAppBar: true
      ),
      const AppScreen(
        screenIcon: Icon(Icons.list_alt_rounded), 
        screenName: "Lists", 
        screenWidget: Lists(),
        hasAppBar: true
      ),
      const AppScreen(
        screenIcon: Icon(Icons.settings), 
        screenName: "Settings", 
        screenWidget: Settings(),
        hasAppBar: false
      ),
    ];

    return Scaffold(
      appBar: appScreens[selectedScreen].hasAppBar == true &&
        serversProvider.connectedServer != null
        ? const PreferredSize(
            preferredSize: Size(double.maxFinite, 84),
            child: TopBar(),
          )
        : null,
      bottomNavigationBar: BottomNavBar(
        screens: appScreens,
        selectedScreen: selectedScreen,
        onChange: _changeScreen,
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,      
        child: SafeArea(child: appScreens[selectedScreen].screenWidget),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: appScreens[selectedScreen].screenFab != null 
        ? FloatingActionButton(
            onPressed: appScreens[selectedScreen].screenFab?.onTap,
            backgroundColor: appScreens[selectedScreen].screenFab?.color,
            child: appScreens[selectedScreen].screenFab?.icon,
          )
        : null,
    );
  }
}