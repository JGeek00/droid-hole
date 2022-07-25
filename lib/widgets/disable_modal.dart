import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/option_box.dart';

class DisableModal extends StatefulWidget {
  final void Function(int) onDisable;

  const DisableModal({
    Key? key,
    required this.onDisable
  }) : super(key: key);

  @override
  State<DisableModal> createState() => _DisableModalState();
}

class _DisableModalState extends State<DisableModal> {
  int? selectedOption;
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
        Timer(const Duration(milliseconds: 250), () {
          setState(() {
            showCustomDurationInput = true;
          });
        });
      }
    });
  }

  void _validateCustomMinutes(value) {
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
        return 30;

      case 1:
        return 60;

      case 2:
        return 120;

      case 3:
        return 300;

      case 4:
        return 0;

      case 5:
        return int.parse(customTimeController.text)*60;

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);   

    return Padding(
      padding: mediaQueryData.viewInsets,
      child: SingleChildScrollView(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: selectedOption == 5 
            ? mediaQueryData.size.height > (Platform.isIOS ? 500 : 480) 
              ? (Platform.isIOS ? 500 : 480) 
              : mediaQueryData.size.height-25
            : mediaQueryData.size.height > (Platform.isIOS ? 411 : 391)
              ? (Platform.isIOS ? 411 : 391)
              : mediaQueryData.size.height-25,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30)
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 20
                    ),
                    child: Icon(
                      Icons.gpp_bad_rounded,
                      size: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      AppLocalizations.of(context)!.disable,
                      style: const TextStyle(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
                                      ),
                                      child: Text(AppLocalizations.of(context)!.seconds30),
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
                                      ),
                                      child: Text(AppLocalizations.of(context)!.minute1),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
                                      ),
                                      child: Text(AppLocalizations.of(context)!.minutes2),
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
                                      ),
                                      child: Text(AppLocalizations.of(context)!.minutes5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
                                      ),
                                      child: Text(AppLocalizations.of(context)!.indefinitely),
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
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).textTheme.bodyText1!.color
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
                                  onChanged: _validateCustomMinutes,
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
                                    labelText: AppLocalizations.of(context)!.customMinutes,
                                  ),
                                ),
                              ],
                            ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15
                            ),
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
                                        widget.onDisable(_getTime());
                                      }
                                    : null,
                                  style: ButtonStyle(
                                    foregroundColor: _selectionIsValid() == true 
                                      ? MaterialStateProperty.all(Theme.of(context).primaryColor)
                                      : MaterialStateProperty.all(Colors.grey)
                                  ),
                                  child: Text(AppLocalizations.of(context)!.accept),
                                )
                              ]
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}