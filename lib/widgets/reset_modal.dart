import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetModal extends StatefulWidget {
  final void Function() onConfirm;

  const ResetModal({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ResetModal> createState() => _ResetModalState();
}

class _ResetModalState extends State<ResetModal> {
  late Timer _timer;
  int _timeRemaining = 5;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--)
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        height: 205,
        width: 500,
        padding: EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: Platform.isIOS ? 5 : 10
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.eraseAppData,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.eraseWarning
                    ),
                    const SizedBox(height: 20),
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
                        onPressed: () {
                          _timer.cancel();
                          Navigator.pop(context);
                        }, 
                        child: Text( AppLocalizations.of(context)!.cancel),
                      ), 
                      TextButton.icon(
                        onPressed: _timeRemaining == 0
                          ? widget.onConfirm
                          : null, 
                        icon: const Icon(Icons.delete), 
                        label: Text(
                          _timeRemaining > 0 
                            ? "${AppLocalizations.of(context)!.eraseAll} ($_timeRemaining)"
                            :  AppLocalizations.of(context)!.eraseAll
                        ),
                        style: ButtonStyle(
                          foregroundColor: _timeRemaining == 0 
                            ? MaterialStateProperty.all(Colors.red)
                            : MaterialStateProperty.all(Colors.grey),
                          overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1)),
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