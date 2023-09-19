// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/settings/advanced_settings/app_lock/remove_passcode_modal.dart';
import 'package:droid_hole/screens/settings/advanced_settings/app_lock/create_pass_code_modal.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';

class AppUnlockSetupModal extends StatefulWidget {
  final double topBarHeight;
  final bool useBiometrics;
  final bool window;

  const AppUnlockSetupModal({
    Key? key,
    required this.topBarHeight,
    required this.useBiometrics,
    required this.window
  }) : super(key: key);

  @override
  State<AppUnlockSetupModal> createState() => _AppUnlockSetupModalState();
}

class _AppUnlockSetupModalState extends State<AppUnlockSetupModal> {
  List<BiometricType> availableBiometrics = [];
  bool validVibrator = false;

  void checkAvailableBiometrics() async {
    try {
      final auth = LocalAuthentication();
      final List<BiometricType> biometrics = await auth.getAvailableBiometrics();
      setState(() => availableBiometrics = biometrics);
    } catch (_) {
      // NO BIOMETRICS //
    }
  }

  @override
  void initState() {
    checkAvailableBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    void openPassCodeDialog() {
      Navigator.push(context, MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => const CreatePassCodeModal()
      ));
    }

    void openRemovePasscode() {
      showDialog(
        context: context, 
        builder: (context) => const RemovePasscodeModal(),
        barrierDismissible: false
      );
    }

    void enableDisableBiometricsUnlock(bool status) async {
      if (status == true) {
        final auth = LocalAuthentication();
        final biometrics = await auth.getAvailableBiometrics();
        if (biometrics.isNotEmpty) {
          auth.stopAuthentication();
          try {
            final bool didAuthenticate = await auth.authenticate(
              localizedReason: 'Unlock the app',
              options: const AuthenticationOptions(
                biometricOnly: true,
                stickyAuth: true,
              ),
            );
            if (didAuthenticate == true) {
              final result = await appConfigProvider.setUseBiometrics(true);
              if (result == false) {
                showSnackBar(
                  appConfigProvider: appConfigProvider,
                  label: AppLocalizations.of(context)!.biometricUnlockNotActivated,
                  color: Colors.red
                );
              }
            }
          } catch (e) {
            if (e.toString().contains('LockedOut')) {
              showSnackBar(
                appConfigProvider: appConfigProvider, 
                label: AppLocalizations.of(context)!.fingerprintAuthUnavailableAttempts, 
                color: Colors.red
              );
            }
            else {
              showSnackBar(
                appConfigProvider: appConfigProvider, 
                label: AppLocalizations.of(context)!.fingerprintAuthUnavailable, 
                color: Colors.red
              );
            }
          }
        }
        else {
          showSnackBar(
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.noAvailableBiometrics,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
        }
      }
      else {
        final result = await appConfigProvider.setUseBiometrics(false);
        if (result == false) {
          showSnackBar(
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.biometricUnlockNotDisabled,
            color: Colors.red
          );
        }
      }
    }

    List<Widget> content() {
      return [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 24
              ),
              child: Icon(
                Icons.password_rounded,
                size: 26,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context)!.appUnlock,
                style: const TextStyle(
                  fontSize: 24
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 24,
            top: 10
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: appConfigProvider.passCode != null
                ? Colors.green
                : Colors.red
            ),
            borderRadius: BorderRadius.circular(30)
          ),
          child: appConfigProvider.passCode != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    AppLocalizations.of(context)!.statusEnabled,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    AppLocalizations.of(context)!.statusDisabled,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  )
              ],
            )
        ),
        appConfigProvider.passCode != null 
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, 
                vertical: 20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: openPassCodeDialog,
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(Colors.transparent)
                        ), 
                        child: Row(
                          children: [
                            if (mediaQuery.size.width > 380) const Icon(Icons.update),
                            if (mediaQuery.size.width > 380) const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.updatePasscode)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: openRemovePasscode,
                        style: ButtonStyle(
                          shadowColor: MaterialStateProperty.all(Colors.transparent)
                        ), 
                        child: Row(
                          children: [
                            if (mediaQuery.size.width > 380) const Icon(Icons.delete),
                            if (mediaQuery.size.width > 380) const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.removePasscode)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: openPassCodeDialog,
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
              ? () => enableDisableBiometricsUnlock(!appConfigProvider.useBiometrics)
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
                    onChanged: appConfigProvider.passCode != null
                      ? (value) => enableDisableBiometricsUnlock(value)
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
      ];
    }

    if (widget.window == true) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400
          ),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: content(),
            ),
          ),
        ),
      );
    }
    else {
      return Container(
        height: (mediaQuery.size.height-widget.topBarHeight) > 460
          ? 460
          : mediaQuery.size.height-widget.topBarHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          ),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: content()
          ),
        ),
      );
    }
  }
}