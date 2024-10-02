// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_radio_list_tile.dart';

import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class LogsQuantityLoadScreen extends StatefulWidget {
  const LogsQuantityLoadScreen({super.key});

  @override
  State<LogsQuantityLoadScreen> createState() => _LogsQuantityLoadScreenState();
}

class _LogsQuantityLoadScreenState extends State<LogsQuantityLoadScreen> {
  int selectedOption = 1;

  void _updateRadioValue(value) {
    setState(() {
      selectedOption = value;
    });
  }

  double _getTime() {
    switch (selectedOption) {
      case 0:
        return 0.5;

      case 1:
        return 1;

      case 2:
        return 2;

      case 3:
        return 4;

      case 4:
        return 6;

      case 5:
        return 8;

      default:
        return 0;
    }
  }

  int _setTime(double time) {
    switch (time.toString()) {
      case '0.5':
        return 0;

      case '1.0':
        return 1;

      case '2.0':
        return 2;

      case '4.0':
        return 3;

      case '6.0':
        return 4;

      default:
        return 5;
    }
  }

  void onSave() async {
    final result = await Provider.of<AppConfigProvider>(context, listen: false).setLogsPerQuery(_getTime());
    if (result == true) {
        showSnackBar(
        appConfigProvider: Provider.of<AppConfigProvider>(context, listen: false),
        label: AppLocalizations.of(context)!.logsPerQueryUpdated,
        color: Colors.green
      );
    }
    else {
      showSnackBar(
        appConfigProvider: Provider.of<AppConfigProvider>(context, listen: false),
        label: AppLocalizations.of(context)!.cantUpdateLogsPerQuery,
        color: Colors.green
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedOption = _setTime(Provider.of<AppConfigProvider>(context, listen: false).logsPerQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logsQuantityPerLoad),
        actions: [
          IconButton(
            onPressed: onSave, 
            icon: const Icon(Icons.save_rounded),
            tooltip: AppLocalizations.of(context)!.save,
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 20,
              left: 20, 
              right: 20
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(30)
              ),
              height: 100,
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.logsPerQueryWarning,
                      style: const TextStyle(
                        color: Colors.black
                      ),
                    ),
                  )
                ],
              ),
            )
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 0, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.minutes30, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 1, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.hour1, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 2, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.hours2, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 3, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.hours4, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 4, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.hours6, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 5, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.hours8, 
            onChanged: _updateRadioValue
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              bottom: 10,
              right: 20
            ),
            child: Text(
              "${AppLocalizations.of(context)!.logsWillBeRequested} ${_getTime() == 0.5 ? '30' : _getTime().toInt()} ${_getTime() == 0.5 ? AppLocalizations.of(context)!.minutes : AppLocalizations.of(context)!.hours}",
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }
}