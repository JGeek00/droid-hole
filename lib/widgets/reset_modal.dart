import 'dart:async';

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
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(Icons.delete_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppLocalizations.of(context)!.eraseAppData,
                  style: const TextStyle(
                    fontSize: 24
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context)!.eraseWarning
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 10,
                  right: 20,
                  left: 20
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _timer.cancel();
                        Navigator.pop(context);
                      }, 
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ), 
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: _timeRemaining == 0
                        ? widget.onConfirm
                        : null,
                      style: ButtonStyle(
                        foregroundColor: _timeRemaining == 0 
                          ? MaterialStateProperty.all(Colors.red)
                          : MaterialStateProperty.all(Colors.grey),
                        overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.1)),
                      ), 
                      child: Text(
                        _timeRemaining > 0 
                          ? "${AppLocalizations.of(context)!.eraseAll} ($_timeRemaining)"
                          :  AppLocalizations.of(context)!.eraseAll,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}