import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/option_box.dart';

class LogsQuantityPerLoadModal extends StatefulWidget {
  final double? time;
  final void Function(double) onChange;

  const LogsQuantityPerLoadModal({
    super.key,
    required this.time,
    required this.onChange,
  });

  @override
  State<LogsQuantityPerLoadModal> createState() => _LogsQuantityPerLoadModalState();
}

class _LogsQuantityPerLoadModalState extends State<LogsQuantityPerLoadModal> {
  int? selectedOption;

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

    return Container(
      height: mediaQueryData.size.height > (Platform.isIOS ? 675 : 655) 
        ? (Platform.isIOS ? 675 : 655) 
        : mediaQueryData.size.height-mediaQueryData.viewPadding.top-25,
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Icon(
                Icons.list_rounded,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                AppLocalizations.of(context)!.logsQuantityPerLoad,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              height: 70,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 20,
                left: 20, 
                right: 20
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.logsPerQueryLabel,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
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
            Padding(
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.minutes30),
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.hour1),
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.hours2),
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
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.hours4),
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
                          itemValue: 4,
                          onTap: _updateRadioValue,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: selectedOption == 4
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.hours6),
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
                          itemValue: 5,
                          onTap: _updateRadioValue,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: selectedOption == 5
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                              child: Text(AppLocalizations.of(context)!.hours8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                        onPressed: selectedOption != null
                          ? () {
                            Navigator.pop(context);
                            widget.onChange(_getTime());
                          }
                          : null,
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            selectedOption != null
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
    );
  }
}