// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/fingerprint_unlock_modal.dart';
import 'package:droid_hole/widgets/remove_passcode_modal.dart';
import 'package:droid_hole/widgets/create_pass_code_modal.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class AppUnlockSetupModal extends StatefulWidget {
  final bool useBiometrics;

  const AppUnlockSetupModal({
    Key? key,
    required this.useBiometrics,
  }) : super(key: key);

  @override
  State<AppUnlockSetupModal> createState() => _AppUnlockSetupModalState();
}

class _AppUnlockSetupModalState extends State<AppUnlockSetupModal> {
  List<BiometricType> availableBiometrics = [];
  bool validVibrator = false;

  void checkAvailableBiometrics() async {
    final List<BiometricType> biometrics = await LocalAuthentication.getAvailableBiometrics();
    setState(() => availableBiometrics = biometrics);
  }

  @override
  void initState() {
    checkAvailableBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void _openPassCodeDialog() {
      Navigator.push(context, MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const CreatePassCodeModal()
      ));
    }

    void _openRemovePasscode() {
      showDialog(
        context: context, 
        builder: (context) => const RemovePasscodeModal(),
        barrierDismissible: false
      );
    }

    void _enableDisableBiometricsUnlock(bool status) async {
      if (status == true) {
        if (availableBiometrics.contains(BiometricType.fingerprint)) {
          showModalBottomSheet(
            context: context, 
            builder: (ctx)  => FingerprintUnlockModal(
              onSuccess: () async {
                final result = await appConfigProvider.setUseBiometrics(true);
                if (result == true) {
                  Navigator.pop(ctx);
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.biometicUnlockNotActivated),
                      backgroundColor: Colors.red,
                    )
                  );
                }
              },
            ),
            backgroundColor: Colors.transparent
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noAvailableBiometrics),
              backgroundColor: Colors.grey,
            )
          );
        }
      }
      else {
        final result = await appConfigProvider.setUseBiometrics(false);
        if (result == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometicUnlockNotDisabled),
              backgroundColor: Colors.red,
            )
          );
        }
      }
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
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton.icon(
                    onPressed: _openPassCodeDialog,
                    style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(Colors.transparent)
                    ), 
                    icon: const Icon(Icons.pin_outlined),
                    label: Text(AppLocalizations.of(context)!.setPassCode),
                  ),
                ),
            if (appConfigProvider.biometricsSupport == true) Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: appConfigProvider.passCode != null
                  ? () => _enableDisableBiometricsUnlock(!appConfigProvider.useBiometrics)
                  : null,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 30,
                    right: 20
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: appConfigProvider.passCode != null 
                              ? null
                              : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.useFingerprint,
                            style: TextStyle(
                              fontSize: 16,
                              color: appConfigProvider.passCode != null
                                ? null
                                : Colors.grey
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: appConfigProvider.useBiometrics, 
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: appConfigProvider.passCode != null
                          ? (value) => _enableDisableBiometricsUnlock(value)
                          : null
                      )
                    ],
                  ),
                ),
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