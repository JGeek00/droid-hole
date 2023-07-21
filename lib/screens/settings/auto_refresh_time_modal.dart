import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/option_box.dart';

class AutoRefreshTimeModal extends StatefulWidget {
  final int? time;
  final void Function(int) onChange;

  const AutoRefreshTimeModal({
    Key? key,
    required this.time,
    required this.onChange,
  }) : super(key: key);

  @override
  State<AutoRefreshTimeModal> createState() => _AutoRefreshTimeModalState();
}

class _AutoRefreshTimeModalState extends State<AutoRefreshTimeModal> {
  int? selectedOption;
  TextEditingController customTimeController = TextEditingController();
  bool showCustomDurationInput = false;
  bool customTimeIsValid = false;
  double height = 423;

  void _updateRadioValue(value) {
    setState(() {
      selectedOption = value;
      if (selectedOption != 5) {
        customTimeController.text = "";
        showCustomDurationInput = false;
      }
      else {
        Timer(const Duration(milliseconds: 250), () {
          setState(() {
            showCustomDurationInput = true;
          });
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
    if (selectedOption != null && selectedOption != 5) {
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

  @override
  void initState() {
    super.initState();
    if (widget.time != null) {
      selectedOption = _setTime(widget.time!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);   

    return Padding(
      padding: mediaQueryData.viewInsets,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: selectedOption == 5 
          ? mediaQueryData.size.height > (Platform.isIOS ? 480 : 500) 
            ? (Platform.isIOS ? 480 : 500) 
            : mediaQueryData.size.height-25
          : mediaQueryData.size.height > (Platform.isIOS ? 296 : 410)
            ? (Platform.isIOS ? 396 : 410)
            : mediaQueryData.size.height-25,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Icon(
                  Icons.update_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                width: double.maxFinite,
                child: Text(
                  AppLocalizations.of(context)!.autoRefreshTime,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 10,
                              right: 5,
                              bottom: 5
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 0,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 0
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.second1),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 10,
                              left: 5,
                              bottom: 5
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 1,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 1
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.seconds2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 5,
                              right: 5,
                              bottom: 5
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 2,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 2
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.seconds5),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 5,
                              left: 5,
                              bottom: 5
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 3,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 3
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.seconds10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 5,
                              right: 5,
                              bottom: 10
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 4,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 4
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.seconds30),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: (mediaQueryData.size.width-70)/2,
                            margin: const EdgeInsets.only(
                              top: 5,
                              left: 5,
                              bottom: 10
                            ),
                            child: OptionBox(
                              optionsValue: selectedOption,
                              itemValue: 5,
                              onTap: _updateRadioValue,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: selectedOption == 5
                                      ? Theme.of(context).colorScheme.onSecondaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  child: Text(AppLocalizations.of(context)!.custom),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showCustomDurationInput == true) 
                        Column(
                          children: [
                            const SizedBox(height: 25),
                            TextField(
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
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), 
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: _selectionIsValid() == true 
                            ? () {
                              Navigator.pop(context);
                              widget.onChange(_getTime());
                            }
                            : null,
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              _selectionIsValid() == true 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            ),
                          ), 
                          child: Text(AppLocalizations.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}