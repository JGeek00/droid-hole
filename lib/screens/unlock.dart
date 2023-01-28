import 'package:droid_hole/widgets/fingerprint_unlock_modal.dart';
import 'package:droid_hole/widgets/shake_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/numeric_pad.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Unlock extends StatefulWidget {
  const Unlock({
    Key? key,
  }) : super(key: key);

  @override
  State<Unlock> createState() => _UnlockState();
}

class _UnlockState extends State<Unlock> {
  bool isLoading = false;
  String _code = "";
  
  bool firstLoad = true;

  final GlobalKey<ShakeAnimationState> _shakeKey = GlobalKey<ShakeAnimationState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final topBarHeight = MediaQuery.of(context).viewPadding.top;

    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void connectServer() async {
      if (serversProvider.selectedServer != null) {
        Server serverObj = serversProvider.selectedServer!;
        final result = await loginQuery(serverObj);
        if (result['result'] == 'success') {
          serverObj.enabled = result['status'] == 'enabled' ? true : false;
          serversProvider.setselectedServer(serverObj);
          serversProvider.setRefreshServerStatus(true);
          serversProvider.setIsServerConnected(true);
        }
        else {
          serversProvider.setIsServerConnected(false);
        }
      }
      appConfigProvider.setAppUnlocked(true);
    }

    void updateCode(String value) {
      setState(() => _code = value);
      if (_code.length == 4 && _code == appConfigProvider.passCode) {
        setState(() {
          isLoading = true;
        });
        connectServer();
      }
      else if (_code.length == 4 && _code != appConfigProvider.passCode) {
        _shakeKey.currentState!.shake();
        setState(() {
          _code = "";
        });
      }
    }

    if (firstLoad == true) {
      if (appConfigProvider.useBiometrics == true) {
        Future.delayed(const Duration(milliseconds: 0), () {
          showModalBottomSheet(
            context: context, 
            builder: (ctx)  => FingerprintUnlockModal(
              topBarHeight: topBarHeight,
              onSuccess: () async {
                setState(() {
                  isLoading = true;
                });
                Navigator.pop(ctx);
                connectServer();
              },
            ),
            isScrollControlled: true,
            backgroundColor: Colors.transparent
          );
        });
      }
      firstLoad = false;
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: height,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                height-180 >= 426 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Icon(
                            Icons.lock_open_rounded,
                            size: 30,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            AppLocalizations.of(context)!.enterCodeUnlock,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_open_rounded,
                          size: 30,
                        ),
                        const SizedBox(width: 30),
                        Text(
                          AppLocalizations.of(context)!.enterCodeUnlock,
                          style: const TextStyle(
                            fontSize: 22
                          ),
                        ),
                      ],
                    ),
                NumericPad(
                  shakeKey: _shakeKey,
                  code: _code,
                  onInput: (newCode) => _code.length < 4
                    ? updateCode(newCode)
                    : {}, 
                )
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: isLoading == true ? 1 : 0, 
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: isLoading == true ? false : true,
              child: Container(
                width: double.maxFinite,
                height: height,
                color: const Color.fromRGBO(0, 0, 0, 0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      AppLocalizations.of(context)!.connecting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 26
                      ),
                    )
                  ],
                ),
              ),
            )
          )
        ],
      )
    );
  }
}