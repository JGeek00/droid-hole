import 'package:droid_hole/functions/process_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/screens/home.dart';
import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/screens/settings.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';
import 'package:droid_hole/widgets/disable_modal.dart';
import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/app_screen.dart';
import 'package:droid_hole/models/fab.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int selectedScreen = 0;

  void _changeScreen(screeenIndex) {
    setState(() {
      selectedScreen = screeenIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

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

    List<AppScreen> appScreens = [
      AppScreen(
        screenIcon: const Icon(Icons.home), 
        screenName: "Home", 
        screenWidget: const Home(),
        screenFab: serversProvider.isServerConnected == true 
          && serversProvider.connectedServer != null
            ? serversProvider.connectedServer!.enabled == true 
              ? Fab(
                  icon: const Icon(Icons.verified_user_rounded), 
                  color: Colors.green, 
                  onTap: _openDisableBottomSheet
                ) 
              : Fab(
                  icon: const Icon(
                    Icons.gpp_bad_rounded,
                    size: 30,
                  ), 
                  color: Colors.red, 
                  onTap: _enableServer
                )
            : null
      ),
      AppScreen(
        screenIcon: const Icon(Icons.storage_rounded), 
        screenName: "Servers", 
        screenWidget: const Servers(),
        screenFab: Fab(
          icon: const Icon(Icons.add), 
          color: Theme.of(context).primaryColor, 
          onTap: _openAddServerBottomSheet
        )
      ),
      const AppScreen(
        screenIcon: Icon(Icons.settings), 
        screenName: "Settings", 
        screenWidget: Settings()
      ),
    ];

    return Scaffold(
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