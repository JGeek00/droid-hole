// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  double height = 300;
  bool textToken = false;
  bool checkingToken = false;
  bool tokenNotValid = false;

  void _confirm() async {
    setState(() {
      checkingToken = true;
      height = 120;
    });
    final result = await testHash(widget.server, tokenTextController.text);
    if (result['result'] == 'success') {
      Navigator.pop(context);
      widget.onConfirm(tokenTextController.text);
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

  @override
  Widget build(BuildContext context) {
    Widget _form() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              AppLocalizations.of(context)!.tokenNeeded,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
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
                    AppLocalizations.of(context)!.tokenInstructions,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
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
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onCancel();
                  },
                  label: Text(AppLocalizations.of(context)!.cancel),
                  icon: const Icon(Icons.cancel),
                ),
                TextButton.icon(
                  onPressed: textToken == true && checkingToken == false
                    ? _confirm
                    : null,
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.green.withOpacity(0.1)
                    ),
                    foregroundColor: MaterialStateProperty.all(
                      textToken == true && checkingToken == false
                        ? Colors.green
                        : Colors.grey,
                    ),
                  ), 
                  label: Text(AppLocalizations.of(context)!.confirm),
                  icon: const Icon(Icons.check)
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 30),
            Text(
              "Checking token...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            )
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: height,
        child: checkingToken == true 
          ? _checkingToken()
          : _form()
      ),
    );
  }
}