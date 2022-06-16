import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/qr_modal.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';

class AddServerModal extends StatefulWidget {
  final Server? server;

  const AddServerModal({
    Key? key,
    this.server,
  }) : super(key: key);

  @override
  State<AddServerModal> createState() => _AddServerModalState();
}

class _AddServerModalState extends State<AddServerModal> {

  TextEditingController ipFieldController = TextEditingController();
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController tokenFieldController = TextEditingController();
  bool defaultCheckbox = false;

  String? errorUrl;

  bool allDataValid = false;

  String status = 'form';
  double height = 406;
  String errorMessage = 'Failed';
  
  void _checkDataValid() {
    if (
      ipFieldController.text != '' &&
      tokenFieldController.text != ''
    ) {
      setState(() {
        allDataValid = true;
      });
    }
    else {
      allDataValid = false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      ipFieldController.text = widget.server!.address;
      aliasFieldController.text = widget.server!.alias!;
      tokenFieldController.text = widget.server!.token;
      setState(() {
        defaultCheckbox = widget.server!.defaultServer;
      });
      
      setState(() {
        allDataValid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void _onQrScanned(String value) {
      tokenFieldController.text = value;
    }

    void _openQrModal() {
      showDialog(
        context: context, 
        builder: (context) => QrModal(
          onQrScanned: _onQrScanned,
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    }

    void _connect() async {
      final exists = await serversProvider.checkUrlExists(ipFieldController.text);
      if (exists['result'] == 'success' && exists['exists'] == true) {
        setState(() {
          height = 428;
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
            height = 406;
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
          setState(() {
            height = 200;
            status = 'success';
          });
          await Future.delayed(const Duration(seconds: 3), (() {
            Navigator.pop(context);
            serversProvider.addServer(Server(
              address: serverObj.address,
              alias: serverObj.alias,
              token: serverObj.token,
              defaultServer: serverObj.defaultServer,
              enabled: result['status'] == 'enabled' ? true : false
            ));
          }));
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
              height = 406;
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

    void _save() async {
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
        setState(() {
          height = 200;
          status = 'success';
        });
        await Future.delayed(const Duration(seconds: 3), (() async {
          Navigator.pop(context);
          Server server = Server(
            address: widget.server!.address, 
            alias: aliasFieldController.text,
            token: tokenFieldController.text, 
            defaultServer: defaultCheckbox,
          );
          final result = await serversProvider.editServer(server);
          if (result == true) {
            setState(() {
              height = 200;
              status = 'success';
            });
          }
          else {
            setState(() {
              errorMessage = "Server data couldn't be saved";
              status = 'failed';
              height = 200;
            });
          }
        }));
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
            height = 406;
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
          return _form(
            widget.server != null ? _save : _connect,
            width,
            _openQrModal
          );
         
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

  Widget _form(Function done, double width, Function openQrModal) {
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
                    onChanged: (value) => _checkDataValid(),
                    controller: ipFieldController,
                    enabled: widget.server != null ? false : true,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: width - 118,
                      child: TextField(
                        controller: tokenFieldController,
                        onChanged: (value) => _checkDataValid(),
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
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => openQrModal(), 
                      icon: const Icon(Icons.qr_code)
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: defaultCheckbox,
                      onChanged: widget.server == null ? (value) => {
                        setState(() => {
                          defaultCheckbox = !defaultCheckbox
                        })
                      } : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.server == null ? (() => {
                        setState(() => {
                          defaultCheckbox = !defaultCheckbox
                        })
                      }) : null,
                      child: Text(
                        "Default server",
                        style: TextStyle(
                          color: widget.server != null 
                            ? Colors.grey
                            : null
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
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
                    onPressed: allDataValid == true 
                      ? () => done()
                      : null,
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(
                        Colors.green.withOpacity(0.1)
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        allDataValid == true 
                          ? Colors.green
                          : Colors.grey,
                      ),
                    ), 
                    label: Text(
                      widget.server != null ? "Save" : "Login"
                    ),
                    icon: Icon(
                      widget.server != null ? Icons.save : Icons.login
                    ),
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