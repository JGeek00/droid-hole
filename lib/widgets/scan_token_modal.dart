import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanTokenModal extends StatefulWidget {
  final void Function(String) qrScanned;
    
  const ScanTokenModal({
    super.key,
    required this.qrScanned
  });

  @override
  State<ScanTokenModal> createState() => _ScanTokenModalState();
}

class _ScanTokenModalState extends State<ScanTokenModal> {
  bool scanQr = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int permission = 0;

  Future managePermission() async {
    if (await Permission.camera.isGranted) {
      setState(() {
        permission = 1;
      });
    }
    else {
      final PermissionStatus status = await Permission.camera.request();
      if (mounted) {
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
  } 

  @override
  void initState() {
    managePermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    void handleBarcode(BarcodeCapture codes) {
      if (codes.barcodes.isNotEmpty && codes.barcodes[0].rawValue != null) {
        widget.qrScanned(codes.barcodes[0].rawValue!);
        Navigator.pop(context);
      }
    }

    Widget getPermissionStatus() {
      switch (permission) {
        case 0:
          return SizedBox(
            height: 170,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 30),
                Text(
                  AppLocalizations.of(context)!.gettingPermission,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          );

        case 1:
          return SizedBox(
            width: width,
            height: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: MobileScanner(
                onDetect: handleBarcode,
              ),
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.no_photography,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 25),
                Text(
                  AppLocalizations.of(context)!.cameraPermission,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Column(
        children: [
          const Icon(
            Icons.qr_code_rounded,
            size: 26,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.qrScanner,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content: getPermissionStatus(),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text(AppLocalizations.of(context)!.cancel)
        )
      ],
    );
  }
}