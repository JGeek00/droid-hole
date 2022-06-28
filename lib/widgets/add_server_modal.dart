import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  TextEditingController passwordFieldController = TextEditingController();
  bool defaultCheckbox = false;

  String? errorUrl;

  bool allDataValid = false;

  String status = 'form';
  double height = 406;
  String errorMessage = 'Failed';
  
  void _checkDataValid(String field, String value) {
    if (
      ipFieldController.text != '' &&
      aliasFieldController.text != '' &&
      passwordFieldController.text != '' &&
      value != ''
    ) {
      setState(() {
        allDataValid = true;
      });
    }
    else {
      setState(() {
        allDataValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      ipFieldController.text = widget.server!.address;
      aliasFieldController.text = widget.server!.alias;
      passwordFieldController.text = widget.server!.password;
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
          password: passwordFieldController.text, 
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
              password: serverObj.password,
              defaultServer: defaultCheckbox,
              enabled: result['status'] == 'enabled' ? true : false
            ));
          }));
        }
        else {
          if (result['result'] == 'socket') {
            setState(() {
              errorMessage = "Failed. Check address.";
            });
          }
          if (result['result'] == 'timeout') {
            setState(() {
              errorMessage = "Failed. Connection timeout.";
            });
          }
          else if (result['result'] == 'token_invalid') {
            setState(() {
              errorMessage = "Failed. Password not valid.";
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
        password: passwordFieldController.text, 
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
            password: passwordFieldController.text, 
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
              errorMessage = "Connection data couldn't be saved";
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
            width
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
        child: SizedBox(
          child: SingleChildScrollView(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: height,
              width: mediaQueryData.size.width > 400 ? 400 : null,
              curve: Curves.easeInOut,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _statusWidget()
            ),
          ),
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

  Widget _form(Function done, double width) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            widget.server != null 
              ? "Edit server connection" 
              : "Add server connection",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      onChanged: (value) => _checkDataValid('address', value),
                      controller: ipFieldController,
                      enabled: widget.server != null ? false : true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.http_outlined),
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
                      onChanged: (value) => _checkDataValid('alias', value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined),
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
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordFieldController,
                      onChanged: (value) => _checkDataValid('password', value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10)
                          )
                        ),
                        labelText: 'Password',
                      ),
                    ),
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
                          "Default connection",
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
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10
                ),
                child: Row(
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
                        widget.server != null ? "Save" : "Connect"
                      ),
                      icon: Icon(
                        widget.server != null ? Icons.save : Icons.login
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}