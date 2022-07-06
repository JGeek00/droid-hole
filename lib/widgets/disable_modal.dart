import 'dart:io';
import 'dart:async';

import 'package:droid_hole/widgets/expandable_bottom_sheet.dart';
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

  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  void _updateRadioValue(value) {
    setState(() {
      selectedOption = value;
      if (selectedOption != 5) {
        customTimeController.text = "";
        FocusManager.instance.primaryFocus?.unfocus();
        showCustomDurationInput = false;
        Future.delayed(const Duration(milliseconds: 140), (() => {
          key.currentState!.contract()
        }));
      }
      else {
        key.currentState!.expand();
        showCustomDurationInput = true;
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

    // mediaQueryData.viewInsets.bottom = 0 when keyboard is closed
    if (mediaQueryData.viewInsets.bottom > 0 && key.currentState != null) {
      if (showCustomDurationInput == true) {
        Future.delayed(const Duration(milliseconds: 0), () => {
          key.currentState!.expand()
        });
      }
      else {
        Future.delayed(const Duration(milliseconds: 0), () => {
          key.currentState!.contract()
        });
      }
    }
    return Padding(
      padding: mediaQueryData.viewInsets,
      child: Container(
        padding: EdgeInsets.only(
          bottom: Platform.isIOS ? 20 : 0
        ),
        child: ExpandableBottomSheet(
          key: key,
          color: Theme.of(context).dialogBackgroundColor,
          marginContent: const EdgeInsets.symmetric(horizontal: 10),
          marginHeader: const EdgeInsets.symmetric(horizontal: 10),
          marginFooter: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 10
          ),
          radiusHeader: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          radiusFooter: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          persistentHeader: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 17
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.disable,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          persistentFooter: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Row(
                          children: [
                            const Icon(Icons.cancel),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.cancel)
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _selectionIsValid() == true 
                          ? () {
                            Navigator.pop(context);
                            widget.onDisable(_getTime());
                          }
                          : null,
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.red.withOpacity(0.1)
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            _selectionIsValid() == true 
                              ? Colors.red
                              : Colors.grey,
                          ),
                        ), 
                        child: Row(
                          children: [
                            const Icon(Icons.gpp_bad_rounded),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.disable)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          expandableContent: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Opacity(
                  opacity: showCustomDurationInput == true ? 1 : 0,
                  child: TextField(
                    onChanged: _validateCustomMinutes,
                    controller: customTimeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false
                    ),
                    enabled: showCustomDurationInput == true ? true : false,
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
                ),
              ],
            ),
          ),
          background: Container(),
        )
      ),
    );
  }
}