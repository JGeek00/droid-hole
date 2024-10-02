// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_radio_list_tile.dart';

import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class AutoRefreshTimeScreen extends StatefulWidget {
  const AutoRefreshTimeScreen({super.key});

  @override
  State<AutoRefreshTimeScreen> createState() => _AutoRefreshTimeScreenState();
}

class _AutoRefreshTimeScreenState extends State<AutoRefreshTimeScreen> {
  int selectedOption = 1;
  TextEditingController customTimeController = TextEditingController();
  bool showCustomDurationInput = false;
  bool customTimeIsValid = false;

  void _updateRadioValue(value) {
    setState(() {
      selectedOption = value;
      if (selectedOption != 5) {
        customTimeController.text = "";
        showCustomDurationInput = false;
      }
      else {
        setState(() {
          showCustomDurationInput = true;
        });
      }
    });
  }

  void _validateCustomTime(value) {
    if (int.tryParse(value) != null) {
      setState(() {
        customTimeIsValid = true;
      });
    }
    else {
      setState(() {
        customTimeIsValid = false;
      });
    }
  }

  bool _selectionIsValid() {
    if (selectedOption != 5) {
      return true;
    }
    else if (selectedOption == 5 && customTimeIsValid == true) {
      return true;
    }
    else {
      return false;
    }
  }

  int _getTime() {
    switch (selectedOption) {
      case 0:
        return 1;

      case 1:
        return 2;

      case 2:
        return 5;

      case 3:
        return 10;

      case 4:
        return 30;

      case 5:
        return int.parse(customTimeController.text);

      default:
        return 0;
    }
  }

  int _setTime(int time) {
    switch (time) {
      case 1:
        return 0;

      case 2:
        return 1;

      case 5:
        return 2;

      case 10:
        return 3;

      case 30:
        return 4;

      default:
        setState(() {
          customTimeController.text = time.toString();
          _validateCustomTime(time.toString());
          showCustomDurationInput = true;
        });
        return 5;
    }
  }

  void onSave() async {
    final result = await Provider.of<AppConfigProvider>(context, listen: false).setAutoRefreshTime(_getTime());
    if (result == true) {
      showSnackBar(
        appConfigProvider: Provider.of<AppConfigProvider>(context, listen: false),
        label: AppLocalizations.of(context)!.updateTimeChanged,
        color: Colors.green
      );
    }
    else {
      showSnackBar(
        appConfigProvider: Provider.of<AppConfigProvider>(context, listen: false),
        label: AppLocalizations.of(context)!.cannotChangeUpdateTime,
        color: Colors.red
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedOption = _setTime(Provider.of<AppConfigProvider>(context, listen: false).getAutoRefreshTime ?? 0);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.autoRefreshTime),
        actions: [
          IconButton(
            onPressed:  _selectionIsValid() == true 
              ? () => onSave()
              : null, 
            icon: const Icon(Icons.save_rounded),
            tooltip: AppLocalizations.of(context)!.save,
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: ListView(
        children: [
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 0, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.second1, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 1, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.seconds2, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 2, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.seconds5, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 3, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.seconds10, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 4, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.seconds30, 
            onChanged: _updateRadioValue
          ),
          CustomRadioListTile(
            groupValue: selectedOption, 
            value: 5, 
            radioBackgroundColor: Theme.of(context).colorScheme.surface, 
            title: AppLocalizations.of(context)!.custom, 
            onChanged: _updateRadioValue
          ),
          if (showCustomDurationInput == true) Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _validateCustomTime,
              controller: customTimeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false
              ),
              decoration: InputDecoration(
                errorText: !customTimeIsValid && customTimeController.text != ''
                  ? AppLocalizations.of(context)!.valueNotValid 
                  : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10)
                  )
                ),
                labelText: AppLocalizations.of(context)!.customSeconds,
              ),
            ),
          ),
        ],
      ),
    );
  }
}