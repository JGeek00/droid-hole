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

  bool isIpFieldValid = false;
  bool isTokenFieldValid = false;

  String status = 'form';
  double height = 368;
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
      if (result == 'success') {
        setState(() {
          height = 200;
          status = 'success';
        });
        await Future.delayed(const Duration(seconds: 3), (() {
          Navigator.pop(context);
          serversProvider.addServer(serverObj);
        }));
      }
      else {
        if (result == 'no_connection') {
          setState(() {
            errorMessage = "Failed. Check address.";
          });
        }
        else if (result == 'token_invalid') {
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
          "Success",
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
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