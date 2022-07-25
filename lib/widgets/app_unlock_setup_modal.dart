import 'package:droid_hole/widgets/remove_passcode_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/pass_code_dialog.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class AppUnlockSetupModal extends StatelessWidget {
  const AppUnlockSetupModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void _openPassCodeDialog() {
      Navigator.push(context, MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const PassCodeDialog()
      ));
    }

    void _openRemovePasscode() {
      showDialog(
        context: context, 
        builder: (context) => const RemovePasscodeModal(),
        barrierDismissible: false
      );
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 30
              ),
              child: Icon(
                Icons.password_rounded,
                size: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                appConfigProvider.passCode != null
                  ? AppLocalizations.of(context)!.appUnlockEnabled
                  : AppLocalizations.of(context)!.appUnlockDisabled,
                style: const TextStyle(
                  fontSize: 22
                ),
              ),
            ),
            appConfigProvider.passCode != null 
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, 
                    vertical: 20
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openPassCodeDialog,
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(Colors.transparent)
                        ), 
                        icon: const Icon(Icons.update),
                        label: Text(AppLocalizations.of(context)!.updatePasscode),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openRemovePasscode,
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(Colors.transparent)
                        ), 
                        icon: const Icon(Icons.delete),
                        label: Text(AppLocalizations.of(context)!.removePasscode),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(30),
                  child: ElevatedButton.icon(
                    onPressed: _openPassCodeDialog,
                    style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(Colors.transparent)
                    ), 
                    icon: const Icon(Icons.pin_outlined),
                    label: Text(AppLocalizations.of(context)!.setPassCode),
                  ),
                ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(AppLocalizations.of(context)!.close)
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}