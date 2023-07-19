// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/numeric_pad.dart';
import 'package:droid_hole/widgets/shake_animation.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class EnterPasscodeModal extends StatefulWidget {
  final void Function() onConfirm;
  final bool window;

  const EnterPasscodeModal({
    Key? key,
    required this.onConfirm,
    required this.window,
  }) : super(key: key);

  @override
  State<EnterPasscodeModal> createState() => _EnterPasscodeModalState();
}

class _EnterPasscodeModalState extends State<EnterPasscodeModal> {
  String _code = "";

  final GlobalKey<ShakeAnimationState> _shakeKey = GlobalKey<ShakeAnimationState>();

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final height = MediaQuery.of(context).size.height;

    void _finish() async {
      if (appConfigProvider.passCode == _code) {
        Navigator.pop(context);
        widget.onConfirm();
      }
      else {
        _shakeKey.currentState!.shake();
        setState(() {
          _code = "";
        });
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
                          AppLocalizations.of(context)!.enterPasscode,
                          style: const TextStyle(
                            fontSize: 22
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _code.length == 4 ? _finish : null, 
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          _code.length == 4
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirm
                      )
                    )
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.all(16)),
              NumericPad(
                shakeKey: _shakeKey,
                code: _code,
                onInput: (newCode) => setState(() => _code = newCode), 
                window: widget.window
              )
            ],
          ),
        )
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.enterPasscode
          ),
          elevation: 5,
          actions: [
            TextButton(
              onPressed: _code.length == 4 ? _finish : null, 
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  _code.length == 4
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.confirm
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
                shakeKey: _shakeKey,
                code: _code,
                onInput: (newCode) => setState(() => _code = newCode), 
                window: widget.window
              )
            ],
          )
        )
      );
    }
  }
}