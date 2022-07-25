// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/numeric_pad.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class PassCodeDialog extends StatefulWidget {
  const PassCodeDialog({Key? key}) : super(key: key);

  @override
  State<PassCodeDialog> createState() => _PassCodeDialogState();
}

class _PassCodeDialogState extends State<PassCodeDialog> {
  int _step = 0;
  String _code = "";
  String _repeatedCode = "";

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final height = MediaQuery.of(context).size.height;

    void _finish() async {
      if (_code == _repeatedCode) {
        final result = await appConfigProvider.setPassCode(_repeatedCode);
        if (result == true) {
          Navigator.pop(context);
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passCodeNotSaved),
              backgroundColor: Colors.red,
            )
          );
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passcodesDontMatch),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 0
            ? AppLocalizations.of(context)!.enterPasscode
            : AppLocalizations.of(context)!.repeatPasscode
        ),
        elevation: 5,
        actions: [
          TextButton(
            onPressed: _step == 0
              ? _code.length == 4
                ? () => setState(() => _step = 1)
                : null
              : _repeatedCode.length == 4
                ? _finish
                : null, 
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                _step == 0
                ? _code.length == 4
                  ? Theme.of(context).primaryColor
                  : Colors.grey
                : _repeatedCode.length == 4
                  ? Theme.of(context).primaryColor
                  : Colors.grey
              ),
            ),
            child: Text(
              _step == 0 
                ? AppLocalizations.of(context)!.next
                : AppLocalizations.of(context)!.finish
            )
          )
        ],
      ),
      body: SizedBox(
        height: height-60,
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NumericPad(
              onInput: (newCode) => _step == 0
                ? _code.length < 4
                  ? setState(() => _code = newCode)
                  : {}
                : _repeatedCode.length < 4
                  ? setState(() => _repeatedCode = newCode)
                  : {}, 
            )
          ],
        )
      ),
    );
  }
}