// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';

import 'package:droid_hole/widgets/shake_animation.dart';

class FingerprintUnlockModal extends StatefulWidget {
  final void Function() onSuccess;

  const FingerprintUnlockModal({
    Key? key,
    required this.onSuccess
  }) : super(key: key);

  @override
  State<FingerprintUnlockModal> createState() => _FingerprintUnlockModalState();
}

class _FingerprintUnlockModalState extends State<FingerprintUnlockModal> {
  final GlobalKey<ShakeAnimationState> _shakeKey = GlobalKey<ShakeAnimationState>();
  Timer? timer;

  bool isCancelled = false;

  void authenticate() async {
    bool didAuthenticate = await LocalAuthentication.authenticate(
      biometricOnly: true,
      localizedReason: 'Unlock the app',
      useErrorDialogs: false,
      stickyAuth: true
    );
    if (isCancelled == false) {
      // didAuthenticate = false either when fingerprint is wrong or when stopAuthentication()
      if (didAuthenticate == true) {
        widget.onSuccess();
      }
      else {
        if (_shakeKey.currentState != null) {
          _shakeKey.currentState!.shake();
        }
        await Future.delayed(const Duration(milliseconds: 300), () {});
        if (isCancelled == false) {
          authenticate();
        }
        else {
          LocalAuthentication.stopAuthentication();
        }
      }
    }
  }

  void cancelAuth() {
    if (_shakeKey.currentState != null) {
      _shakeKey.currentState!.stop();
    }
    isCancelled = true;
    LocalAuthentication.stopAuthentication();
  } 

  @override
  void initState() {
    authenticate();
    super.initState();
  }

  @override
  void deactivate() {
    cancelAuth();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Theme.of(context).dialogBackgroundColor
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              AppLocalizations.of(context)!.unlockFingerprint,
              style: const TextStyle(
                fontSize: 22
              ),
            ),
          ),
          ShakeAnimation(
            key: _shakeKey,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Icon(
                Icons.fingerprint,
                size: 100,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}