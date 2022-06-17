import 'package:droid_hole/screens/servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/reset_modal.dart';
import 'package:droid_hole/widgets/auto_refresh_time_modal.dart';

import 'package:droid_hole/functions/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context, listen: false);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    Widget _listItem({
      IconData? leadingIcon, 
      required String label, 
      String? description,
      Color? color,
      void Function()? onTap
    }) {
      return Material(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 25
            ),
            width: double.maxFinite,
            child: Row(
              children: [
                if (leadingIcon != null) Row(
                  children: [
                    Icon(
                      leadingIcon,
                      color: color,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: color
                      ),
                    ),
                    if (description != null) Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: TextStyle(
                            color: color ?? Colors.black54
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _deleteApplicationData() async {
      openProcessModal(context, "Deleting...");
      await serversProvider.deleteDbData();
      // ignore: use_build_context_synchronously
      closeProcessModal(context);
      // ignore: use_build_context_synchronously
      Phoenix.rebirth(context);
    }

    void _openResetModal() {
      showDialog(
        context: context, 
        builder: (context) => ResetModal(
          onConfirm: _deleteApplicationData,
        ),
        useSafeArea: true
      );
    }

    void _openAutoRefreshTimeModal() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => AutoRefreshTimeModal(
          time: appConfigProvider.getAutoRefreshTime,
          onChange: (time) async {
            final result = await appConfigProvider.setAutoRefreshTime(time);
            if (result == true) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Update time changed successfully."),
                  backgroundColor: Colors.green,
                )
              );
            }
            else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cannot change update time"),
                  backgroundColor: Colors.red,
                )
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black12,
                width: 1
              )
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/icon512.png',
                width: 100,
              ),
              const SizedBox(width: 40),
              const Text(
                "DroidHole",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12
                      )
                    )
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              "Settings",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ),
                        ],
                      ),
                      _listItem(
                        leadingIcon: Icons.storage_rounded,
                        label: "Servers", 
                        description: serversProvider.connectedServer != null 
                          ? serversProvider.isServerConnected == true
                            ? serversProvider.connectedServer!.alias != null
                              ? "Connected to ${serversProvider.connectedServer!.alias}"
                              : "Connected to ${serversProvider.connectedServer!.address}"
                            : "Not connected"
                          : "Not selected",
                        onTap: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ServersPage()
                            )
                          )
                        }
                      ),
                      _listItem(
                        leadingIcon: Icons.update,
                        label: "Auto refresh time", 
                        description: "${appConfigProvider.getAutoRefreshTime.toString()} seconds",
                        onTap: _openAutoRefreshTimeModal
                      ),
                      _listItem(
                        leadingIcon: Icons.delete,
                        label: "Reset application", 
                        description: "Deletes all application data",
                        color: Colors.red,
                        onTap: _openResetModal
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12
                      )
                    )
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              "About",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (appConfigProvider.getAppInfo != null) 
                        _listItem(
                          label: "App version", 
                          description: appConfigProvider.getAppInfo!.version
                        ),
                        _listItem(
                          label: "Created by", 
                          description: "JGeek00"
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}