// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final width = MediaQuery.of(context).size.width;

    Widget _numberButton({
      required String number
    }) {
      return SizedBox(
        width: (width-160)/3,
        height: height-180 < 426
          ? null
          : (width-160)/3,
        child: ElevatedButton(
          onPressed: () => _step == 0
            ? _code.length < 4
                ? setState(() => _code = "$_code$number")
                : {}
            : _repeatedCode.length < 4
                ? setState(() => _repeatedCode = "$_repeatedCode$number")
                : {}, 
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent)
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: height-180 < 426 ? 20 : 40
            ),
          )
        ),
      );
    }

    Widget _backButton() {
      return SizedBox(
        width: (width-160)/3,
        height: height-180 < 426
          ? null
          : (width-160)/3,
        child: ElevatedButton(
          onPressed: () => _step == 0
            ? _code.isNotEmpty
                ? setState(() => _code = _code.substring(0, _code.length - 1))
                : {}
            : _repeatedCode.isNotEmpty
                ? setState(() => _repeatedCode = _repeatedCode.substring(0, _repeatedCode.length - 1))
                : {}, 
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent)
          ),
          child: Icon(
            Icons.backspace,
            size: height-180 < 426 ? 10 : 30
          )
        ),
      );
    }

    Widget _number(String? value) {
      return SizedBox(
        width: 40,
        height: 40,
        child: value != null
          ? Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          : Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
            ),
      );
    }

    Widget _stuff() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: height-180 < 426 ? 0 : 20
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _number(
                  _step == 0 
                    ? _code.isNotEmpty ? _code[0] : null
                    : _repeatedCode.isNotEmpty ? _repeatedCode[0] : null
                ),
                const SizedBox(width: 20),
                _number(
                  _step == 0 
                    ? _code.length >= 2 ? _code[1] : null
                    : _repeatedCode.length >= 2 ? _repeatedCode[1] : null
                ),
                const SizedBox(width: 20),
                _number(_step == 0 
                    ? _code.length >= 3 ? _code[2] : null
                    : _repeatedCode.length >= 3 ? _repeatedCode[2] : null),
                const SizedBox(width: 20),
                _number(_step == 0 
                    ? _code.length >= 4 ? _code[3] : null
                    : _repeatedCode.length >= 4 ? _repeatedCode[3] : null),
              ],
            ),
          ),
          SizedBox(
            height: height-180 < 426
              ? height-160
              : 426,
            width: width-100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "1"),
                    const SizedBox(width: 30),
                    _numberButton(number: "2"),
                    const SizedBox(width: 30),
                    _numberButton(number: "3"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "4"),
                    const SizedBox(width: 30),
                    _numberButton(number: "5"),
                    const SizedBox(width: 30),
                    _numberButton(number: "6"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "7"),
                    const SizedBox(width: 30),
                    _numberButton(number: "8"),
                    const SizedBox(width: 30),
                    _numberButton(number: "9"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: (width-160)/3),
                    const SizedBox(width: 30),
                    _numberButton(number: "0"),
                    const SizedBox(width: 30),
                    _backButton()
                  ],
                )
              ],
            )
          )
        ],
      );
    } 

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
        child: _stuff()
      ),
    );
  }
}