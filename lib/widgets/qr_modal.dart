import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrModal extends StatefulWidget {
  final void Function(String) onQrScanned;

  const QrModal({
    Key? key,
    required this.onQrScanned
  }) : super(key: key);

  @override
  State<QrModal> createState() => _QrModalState();
}

class _QrModalState extends State<QrModal> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;
  Barcode? result;
  bool? flashEnabled = false;
  int permission = 0;

  void _onQrViewCreated(QRViewController controller) async {
    setState(() {
      qrViewController = controller;
    });

    bool? flash = await _getFlashStatus(qrViewController!);
    setState(() {
      flashEnabled = flash;
    });

    qrViewController?.resumeCamera();

    controller.scannedDataStream.listen((scanData) {
      qrViewController!.dispose();
      if (scanData.code != null) {
        widget.onQrScanned(scanData.code!);
      }
      Navigator.pop(context);
    });
  }

  Future<bool?> _getFlashStatus(QRViewController controller) async {
    return await controller.getFlashStatus();
  }

  void _closeModal() {
    if (qrViewController != null) {
      qrViewController!.dispose();
    }
    Navigator.pop(context);
  }

  Future _toggleFlash() async {
    if (qrViewController != null) {
      await qrViewController!.toggleFlash();
      bool? flash = await _getFlashStatus(qrViewController!);
      setState(() {
        flashEnabled = flash;
      });
    }
  }

  void managePermission() async {
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
  void initState() {
    managePermission();
    super.initState();
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
    Widget _getPermissionStatus() {
      switch (permission) {
        case 0:
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 50),
              Text(
                "Getting permission...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          );

        case 1:
          return QRView(
            key: qrKey, 
            onQRViewCreated: _onQrViewCreated,
            formatsAllowed: const [
              BarcodeFormat.qrcode
            ],
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
              children: const [
                Icon(
                  Icons.no_photography,
                  size: 50,
                  color: Colors.grey,
                ),
                SizedBox(height: 50),
                Text(
                  "DroidHole does not have permission to access the camera.\n\nGo to settings and grant the permission.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
      
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 320,
        width: 400,
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 10
        ),
        child: Column(
          children: [
            const Text(
              "Read QR code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 178,
                child: _getPermissionStatus()
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: qrViewController != null ? _toggleFlash : null, 
                        splashRadius: 20,
                        icon: Icon(
                          qrViewController != null ? (
                            flashEnabled == true
                              ? Icons.flash_on
                              : Icons.flash_off
                          ) : Icons.flash_off
                        )
                      ),
                      TextButton.icon(
                        onPressed: _closeModal, 
                        icon: const Icon(Icons.close),
                        label: const Text("Cancel"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}