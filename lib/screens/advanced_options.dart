// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/reset_modal.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class AdvancedOptions extends StatelessWidget {
  const AdvancedOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    return AdvancedOptionsWidget(
      checkSslStatus: appConfigProvider.overrideSslCheck,
      oneColumnLegend: appConfigProvider.oneColumnLegend,
    );
  }
}

class AdvancedOptionsWidget extends StatefulWidget {
  final bool checkSslStatus;
  final bool oneColumnLegend;

  const AdvancedOptionsWidget({
    Key? key,
    required this.checkSslStatus,
    required this.oneColumnLegend
  }) : super(key: key);

  @override
  State<AdvancedOptionsWidget> createState() => _AdvancedOptionsState();
}

class _AdvancedOptionsState extends State<AdvancedOptionsWidget> {
  bool overrideSslCheck = false;
  bool oneColumnLegend = false;

  @override
  void initState() {
    setState(() {
      overrideSslCheck = widget.checkSslStatus;
      oneColumnLegend = widget.oneColumnLegend;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    void _updateSslCheck(bool newStatus) async {
      final result = await appConfigProvider.setOverrideSslCheck(newStatus);
      if (result == true) {
        setState(() => overrideSslCheck = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.restartAppTakeEffect),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotUpdateSettings),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _updateOneColumnLegend(bool newStatus) async {
      final result = await appConfigProvider.setOneColumnLegend(newStatus);
      if (result == true) {
        setState(() => oneColumnLegend = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsUpdatedSuccessfully),
            backgroundColor: Colors.green,
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotUpdateSettings),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    void _deleteApplicationData() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.deleting);
      await serversProvider.deleteDbData();
      await appConfigProvider.restoreAppConfig();
      process.close();
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

    return Scaffold(
      appBar: PreferredSize( 
        preferredSize: const Size(double.maxFinite, 60),
        child: Container(
          margin: EdgeInsets.only(top: statusBarHeight),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
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
                      Navigator.of(context).pop()
                    }, 
                    icon: const Icon(Icons.arrow_back)
                  ),
                  const SizedBox(width: 20),
                  Text(
                    AppLocalizations.of(context)!.advancedSetup,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  )
                ],
              )
            ],
          )
        ),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  AppLocalizations.of(context)!.security,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
          CustomListTile(
            leadingIcon: Icons.lock,
            label: AppLocalizations.of(context)!.dontCheckCertificate,
            description: AppLocalizations.of(context)!.dontCheckCertificateDescription,
            trailing: Switch(
              value: overrideSslCheck, 
              onChanged: (value) => _updateSslCheck
            ),
            onTap: () => _updateSslCheck(!overrideSslCheck),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 10
            )
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor
                )
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  AppLocalizations.of(context)!.charts,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
          CustomListTile(
            leadingIcon: Icons.list,
            label: AppLocalizations.of(context)!.oneColumnLegend,
            description: AppLocalizations.of(context)!.oneColumnLegendDescription,
            onTap: () => _updateOneColumnLegend(!oneColumnLegend),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 10
            ),
            trailing: Switch(
              value: oneColumnLegend, 
              onChanged: (value) => _updateOneColumnLegend
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor
                )
              )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  AppLocalizations.of(context)!.others,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
          CustomListTile(
            leadingIcon: Icons.delete,
            label: AppLocalizations.of(context)!.resetApplication, 
            description: AppLocalizations.of(context)!.erasesAppData,
            color: Colors.red,
            onTap: _openResetModal,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 10
            )
          )
        ],
      ),
    );
  }
}