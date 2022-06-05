import 'package:flutter/material.dart';

import 'package:droid_hole/models/server.dart';

class AddServerModal extends StatefulWidget {
  final void Function() onCancel;
  final void Function(Server) onConfirm;

  const AddServerModal({
    Key? key,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<AddServerModal> createState() => _AddServerModalState();
}

class _AddServerModalState extends State<AddServerModal> {
  TextEditingController ipFieldController = TextEditingController();
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController tokenFieldController = TextEditingController();

  bool isIpFieldValid = false;
  bool isTokenFieldValid = false;

  bool _isDataValid() {
    if (
      ipFieldController.text != '' &&
      isTokenFieldValid == true &&
      isIpFieldValid == true
    ) {
      return true;
    }
    else {
      return false;
    }
  }

  void _validateIpField(value) {
    RegExp regex = RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    if (regex.hasMatch(value)) {
      setState(() {
        isIpFieldValid = true;
      });
    }
    else {
      setState(() {
        isIpFieldValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Padding(
      padding: mediaQueryData.viewInsets,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 390,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              "Add server",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        onChanged: _validateIpField,
                        controller: ipFieldController,
                        decoration: InputDecoration(
                          errorText: !isIpFieldValid && ipFieldController.text != ''
                            ? "IP address is not valid" 
                            : null,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10)
                            )
                          ),
                          labelText: 'IP address',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: aliasFieldController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10)
                            )
                          ),
                          labelText: 'Alias',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextField(
                        controller: tokenFieldController,
                        onChanged: (value) {
                          setState(() {
                            if (value != '') {
                              isTokenFieldValid = true;
                            }
                            else {
                              isTokenFieldValid = false;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10)
                            )
                          ),
                          labelText: 'Token',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onCancel, 
                        child: Row(
                          children: const [
                            Icon(Icons.cancel),
                            SizedBox(width: 10),
                            Text("Cancel")
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isDataValid() == true 
                          ? () => widget.onConfirm(
                            Server(
                              ipAddress: ipFieldController.text,
                              alias: aliasFieldController.text,
                              token: tokenFieldController.text,
                            ),
                          )
                          : null,
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Colors.green.withOpacity(0.1)
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            _isDataValid() == true 
                              ? Colors.green
                              : Colors.grey,
                          ),
                        ), 
                        child: Row(
                          children: const [
                            Icon(Icons.check),
                            SizedBox(width: 10),
                            Text("Add")
                          ],
                        ),
                      ),
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