// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/numeric_pad.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';

class CreatePassCodeModal extends StatefulWidget {
  final bool window;

  const CreatePassCodeModal({
    Key? key,
    required this.window
  }) : super(key: key);

  @override
  State<CreatePassCodeModal> createState() => _CreatePassCodeModalState();
}

class _CreatePassCodeModalState extends State<CreatePassCodeModal> {
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
          showSnackBar(
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.passCodeNotSaved,
            color: Colors.red
          );
        }
      }
      else {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.passcodesDontMatch,
          color: Colors.red
        );
      }
    }

    if (widget.window == true) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context), 
                          icon: const Icon(Icons.clear_rounded)
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _step == 0
                            ? AppLocalizations.of(context)!.enterPasscode
                            : AppLocalizations.of(context)!.repeatPasscode,
                          style: const TextStyle(
                            fontSize: 22
                          ),
                        ),
                      ],
                    ),
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
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey
                          : _repeatedCode.length == 4
                            ? Theme.of(context).colorScheme.primary
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
              ),
              const Padding(padding: EdgeInsets.all(16)),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NumericPad(
                    code: _step == 0 ? _code : _repeatedCode,
                    onInput: (newCode) => _step == 0
                      ? setState(() => _code = newCode)
                      : setState(() => _repeatedCode = newCode), 
                    window: widget.window
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }
    else {
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
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey
                  : _repeatedCode.length == 4
                    ? Theme.of(context).colorScheme.primary
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
                code: _step == 0 ? _code : _repeatedCode,
                onInput: (newCode) => _step == 0
                  ? setState(() => _code = newCode)
                  : setState(() => _repeatedCode = newCode), 
                window: widget.window
              )
            ],
          )
        ),
      );
    }
  }
}