import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';

class AddServerModal extends StatefulWidget {
  const AddServerModal({Key? key}) : super(key: key);

  @override
  State<AddServerModal> createState() => _AddServerModalState();
}

class _AddServerModalState extends State<AddServerModal> {

  TextEditingController ipFieldController = TextEditingController();
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController tokenFieldController = TextEditingController();

  String? errorUrl = null;

  bool isIpFieldValid = false;
  bool isTokenFieldValid = false;

  String status = 'form';
  double height = 370;
  String errorMessage = 'Failed';

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

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    void _connect() async {
      final exists = await serversProvider.checkUrlExists(ipFieldController.text);
      if (exists['result'] == 'success' && exists['exists'] == true) {
        setState(() {
          height = 390;
        });
        await Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            errorUrl = "This URL already exists";
          });
        });
      }
      else if (exists['result'] == 'fail') {
        setState(() {
          errorUrl = null;
        });
        setState(() {
          errorMessage = "Cannot check if this URL is already saved.";
        });
        setState(() {
          status = 'failed';
          height = 200;
        });
        await Future.delayed(const Duration(seconds: 3), (() {
          setState(() {
            height = 368;
          });
        }));
        await Future.delayed(const Duration(milliseconds: 300), (() => {
          setState(() {
            status = 'form';
          })
        }));
      }
      else {
        setState(() {
          errorUrl = null;
        });
        setState(() {
          status = 'connecting';
        });
        final serverObj = Server(
          address: ipFieldController.text, 
          alias: aliasFieldController.text,
          token: tokenFieldController.text, 
          defaultServer: false,
        );
        final result = await login(serverObj);
        if (result['result'] == 'success') {
          final saved = await serversProvider.addServer(Server(
            address: serverObj.address,
            alias: serverObj.alias,
            token: serverObj.token,
            defaultServer: serverObj.defaultServer,
            enabled: result['status'] == 'enabled' ? true : false
          ));
          if (saved == true) {
            setState(() {
              height = 200;
              status = 'success';
            });
            await Future.delayed(const Duration(seconds: 3), (() async {
              Navigator.pop(context);
            }));
          }
          else {
            setState(() {
              errorMessage = "Server cannot be saved.";
              status = 'failed';
              height = 200;
            });
            await Future.delayed(const Duration(seconds: 3), (() async {
              Navigator.pop(context);
            }));
          }
        }
        else {
          if (result['result'] == 'no_connection') {
            setState(() {
              errorMessage = "Failed. Check address.";
            });
          }
          else if (result['result'] == 'token_invalid') {
            setState(() {
              errorMessage = "Failed. Check token.";
            });
          }
          else {
            errorMessage = "Failed. Unknown error.";
          }
          setState(() {
            status = 'failed';
            height = 200;
          });
          await Future.delayed(const Duration(seconds: 3), (() {
            setState(() {
              height = 368;
            });
          }));
          await Future.delayed(const Duration(milliseconds: 300), (() => {
            setState(() {
              status = 'form';
            })
          }));
        }
      }
    }
    
    final MediaQueryData mediaQueryData = MediaQuery.of(context);

    Widget _statusWidget() {
      switch (status) {
        case 'form':
          return _form(_connect);
         
        case 'connecting':
          return _connecting();
         
        case 'success':
          return _success();
         
        case 'failed':
          return _failed();
         
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: mediaQueryData.viewInsets,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: Platform.isIOS ? 20 : 0
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _statusWidget()
        ),
      ),
    );
  }

  Widget _connecting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        SizedBox(height: 40),
        Text(
          "Connecting...",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey
          ),
        )
      ],
    );
  }

  Widget _success() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 50,
        ),
        SizedBox(height: 40),
        Text(
          "Saved",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey
          ),
        )
      ],
    );
  }

  Widget _failed() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 50,
        ),
        const SizedBox(height: 40),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey
          ),
        )
      ],
    );
  }

  Widget _form(Function connect) {
    return Column(
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
                    onChanged: (value) {
                      setState(() {
                        if (value != '') {
                          isIpFieldValid = true;
                        }
                        else {
                          isIpFieldValid = false;
                        }
                      });
                    },
                    controller: ipFieldController,
                    decoration: InputDecoration(
                      errorText: errorUrl,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        )
                      ),
                      labelText: 'Server address',
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
                  TextButton.icon(
                    onPressed: (() => {
                      Navigator.pop(context)
                    }),
                    label: const Text("Cancel"),
                    icon: const Icon(Icons.cancel)
                  ),
                  TextButton.icon(
                    onPressed: _isDataValid() == true 
                      ? () => connect()
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
                    label: const Text("Connect"),
                    icon: const Icon(Icons.login),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}