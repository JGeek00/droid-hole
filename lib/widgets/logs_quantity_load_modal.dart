import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/option_box.dart';

class LogsQuantityPerLoadModal extends StatefulWidget {
  final double? time;
  final void Function(double) onChange;

  const LogsQuantityPerLoadModal({
    Key? key,
    required this.time,
    required this.onChange,
  }) : super(key: key);

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

    return Padding(
      padding: mediaQueryData.viewInsets,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const  Padding(
              padding: EdgeInsets.only(top: 30),
              child: Icon(
                Icons.list_rounded,
                size: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                AppLocalizations.of(context)!.logsQuantityPerLoad,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
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
              child: Text(
                AppLocalizations.of(context)!.logsPerQueryLabel,
                textAlign: TextAlign.center,
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
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.logsPerQueryWarning,
                      ),
                    )
                  ],
                ),
              )
            ),
            SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1!.color
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
                          overlayColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor.withOpacity(0.1)
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            selectedOption != null
                              ? Theme.of(context).primaryColor
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