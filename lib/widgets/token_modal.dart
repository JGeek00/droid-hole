// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';

class TokenModal extends StatefulWidget {
  final Server server;
  final void Function() onCancel;
  final void Function(String) onConfirm;

  const TokenModal({
    Key? key,
    required this.server,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<TokenModal> createState() => _TokenModalState();
}

class _TokenModalState extends State<TokenModal> {
  final tokenTextController = TextEditingController();
  double height = 430;
  bool textToken = false;
  bool checkingToken = false;
  bool tokenNotValid = false;
  bool scanQr = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;
  Barcode? result;
  bool? flashEnabled = false;
  int permission = 0;

  Future managePermission() async {
    if (await Permission.camera.isGranted) {
      setState(() {
        permission = 1;
      });
    }
    else {
      final PermissionStatus status = await Permission.camera.request();
      if (status.isGranted == false) {
        setState(() {
          permission = 2;
        });
      }
      else {
        setState(() {
          permission = 1;
        });
      }
    }
  } 

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrViewController!.pauseCamera();
    } else if (Platform.isIOS) {
      qrViewController!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    void _confirm({String? token}) async {
      final String checkToken = token ?? tokenTextController.text;
      setState(() {
        checkingToken = true;
        height = 200;
      });
      final result = await testHash(widget.server, checkToken);
      if (result['result'] == 'success') {
        Navigator.pop(context);
        widget.onConfirm(checkToken);
      }
      else if (result['result'] == 'hash_not_valid') {
        setState(() {
          height = 300;
        });
        await Future.delayed(const Duration(milliseconds: 260), (() {
          setState(() {
            tokenNotValid = true;
            checkingToken = false;
          });
        }));
      }
    }

    void _onQrViewCreated(QRViewController controller) async {
      setState(() {
        qrViewController = controller;
      });

      qrViewController?.resumeCamera();

      controller.scannedDataStream.listen((scanData) {
        qrViewController!.dispose();
        if (scanData.code != null) {
          _confirm(token: scanData.code!);
        }
      });
    }

    Widget _form() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Icon(
              Icons.key_rounded,
              size: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              AppLocalizations.of(context)!.tokenNeeded,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.tokenInstructions,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: width-185,
                        child: TextFormField(
                          onChanged: (value) => setState(() {
                            if (value != '') {
                              textToken = true;
                            }
                            else {
                              textToken = false;
                            }
                          }),
                          controller: tokenTextController,
                          enabled: checkingToken == false ? true : false,
                          decoration: InputDecoration(
                            label: Text(AppLocalizations.of(context)!.apiToken),
                            border: const OutlineInputBorder(),
                            errorText: tokenNotValid == true  
                              ? AppLocalizations.of(context)!.tokenNotValid
                              : null
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () async {
                            await managePermission();
                            setState(() {
                              height = 670;
                            });
                            await Future.delayed(const Duration(milliseconds: 250), () {
                              setState(() => scanQr = true);
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.qr_code_scanner_rounded),
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                  label: Text(AppLocalizations.of(context)!.cancel),
                  icon: const Icon(Icons.cancel),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: textToken == true && checkingToken == false
                    ? _confirm
                    : null,
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.green.withOpacity(0.1)
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      textToken == true && checkingToken == false
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    ),
                  ), 
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            ),
          )
        ],
      );
    }

    Widget _checkingToken() {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 50),
            SizedBox(
              width: width-40,
              child: Text(
                AppLocalizations.of(context)!.checkingToken,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget _getPermissionStatus() {
      switch (permission) {
        case 0:
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.gettingPermission,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
              )
            ],
          );

        case 1:
          return SizedBox(
            child: QRView(
              key: qrKey, 
              onQRViewCreated: _onQrViewCreated,
              formatsAllowed: const [
                BarcodeFormat.qrcode
              ],
            ),
          );

        case 2: 
          return Container(
            width: double.maxFinite,
            height: 300,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_photography,
                  size: 50,
                  color: Colors.grey,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.cameraPermission,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          );

        default:
          return const SizedBox();
      }
    }

    Widget _qr() {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Icon(
              Icons.key_rounded,
              size: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              AppLocalizations.of(context)!.tokenNeeded,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.scanQrCode,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 300,
                      child: _getPermissionStatus()
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: textToken == true && checkingToken == false
                    ? _confirm
                    : null,
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.green.withOpacity(0.1)
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      textToken == true && checkingToken == false
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    ),
                  ), 
                  child: Text(AppLocalizations.of(context)!.confirm),
                ),
              ],
            ),
          )
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: SizedBox(
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: height,
              child: checkingToken == true 
                ? _checkingToken()
                : scanQr == true 
                  ? _qr()
                  : _form()
            ),
          ),
        ),
      ),
    );
  }
}