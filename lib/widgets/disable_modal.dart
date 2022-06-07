import 'package:droid_hole/providers/servers_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:droid_hole/widgets/option_box.dart';
import 'package:provider/provider.dart';

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: selectedOption == 5 ? 418 : 315,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              "Disable",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
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
                                    : Colors.black87
                                ),
                                child: const Text("30 seconds"),
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
                                    : Colors.black87
                                ),
                                child: const Text("1 minute"),
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
                                    : Colors.black87
                                ),
                                child: const Text("2 minutes"),
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
                                    : Colors.black87
                                ),
                                child: const Text("5 minutes"),
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
                                    : Colors.black87
                                ),
                                child: const Text("Indefinitely"),
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
                                    : Colors.black87
                                ),
                                child: const Text("Custom"),
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
                                ? "Value not valid" 
                                : null,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                                )
                              ),
                              labelText: 'Custom minutes',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Row(
                          children: const [
                            Icon(Icons.cancel),
                            SizedBox(width: 10),
                            Text("Cancel")
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
                          children: const [
                            Icon(Icons.gpp_bad_rounded),
                            SizedBox(width: 10),
                            Text("Disable")
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}