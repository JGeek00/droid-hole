// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/token_modal.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/functions/hash.dart';
import 'package:droid_hole/models/server.dart';

class AddServerFullscreen extends StatefulWidget {
  final Server? server;

  const AddServerFullscreen({
    Key? key,
    this.server
  }) : super(key: key);

  @override
  State<AddServerFullscreen> createState() => _AddServerFullscreenState();
}

class _AddServerFullscreenState extends State<AddServerFullscreen> {
  TextEditingController addressFieldController = TextEditingController();
  String? addressFieldError;
  TextEditingController portFieldController = TextEditingController();
  String? portFieldError;
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  String selectedHttp = 'http';
  bool defaultCheckbox = false;

  String? errorUrl;
  bool allDataValid = false;

  String errorMessage = 'Failed';

  bool isTokenModalOpen = false;

  bool isConnecting = false;

  void _checkDataValid() {
    if (
      addressFieldController.text != '' &&
      addressFieldError == null &&
      portFieldError == null &&
      aliasFieldController.text != '' &&
      passwordFieldController.text != ''
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

  void _validateAddress(String? value) {
    if (value != null && value != '') {
      RegExp ipAddress = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$');
      RegExp domain = RegExp(r'^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$');
      if (ipAddress.hasMatch(value) == true || domain.hasMatch(value) == true) {
        setState(() {
          addressFieldError = null;
        });
      }
      else {
        setState(() {
          addressFieldError = AppLocalizations.of(context)!.invalidAddress;
        });
      }
    }
    else {
      setState(() {
        addressFieldError = AppLocalizations.of(context)!.ipCannotEmpty;
      });
    }
    _checkDataValid();
  }

  void _validatePort(String? value) {
    if (value != null && value != '') {
      if (int.tryParse(value) != null && int.parse(value) <= 65535) {
        setState(() {
          portFieldError = null;
        });
      }
      else {
        setState(() {
          portFieldError = AppLocalizations.of(context)!.invalidPort;
        });
      }
    }
    else {
      setState(() {
        portFieldError = null;
      });
    }
    _checkDataValid();
  }

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      final List<String> splitted = widget.server!.address.split(':');
      addressFieldController.text = splitted[1].split('/')[2];
      portFieldController.text = splitted.length == 3 ? splitted[2] : '';
      aliasFieldController.text = widget.server!.alias;
      passwordFieldController.text = widget.server!.password;
      setState(() {
        selectedHttp = widget.server!.address.split(':')[0];
        defaultCheckbox = widget.server!.defaultServer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    void _connect() async {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        isConnecting = true;
      });
      final String url = "$selectedHttp://${addressFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}";
      final exists = await serversProvider.checkUrlExists(url);
      if (exists['result'] == 'success' && exists['exists'] == true) {
        setState(() {
          errorUrl = AppLocalizations.of(context)!.connectionAlreadyExists;
          isConnecting = false;
        });
      }
      else if (exists['result'] == 'fail') {
        setState(() {
          errorUrl = null;
          isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotCheckUrlSaved),
            backgroundColor: Colors.red,
          )
        );
      }
      else {
        setState(() {
          errorUrl = null;
        });
        final serverObj = Server(
          address: url, 
          alias: aliasFieldController.text,
          password: passwordFieldController.text, 
          defaultServer: false,
        );
        final result = await login(serverObj);
        if (result['result'] == 'success') {
          final hash = hashPassword(serverObj.password);
          final isHashValid = await testHash(serverObj, hash);
          if (isHashValid['result'] == 'success') {
            Navigator.pop(context);
            serversProvider.addServer(Server(
              address: serverObj.address,
              alias: serverObj.alias,
              password: serverObj.password,
              pwHash: hash,
              defaultServer: defaultCheckbox,
              enabled: result['status'] == 'enabled' ? true : false
            ));
          }
          else if (isHashValid['result'] == 'hash_not_valid') {
            setState(() => isTokenModalOpen = true);
            showDialog(
              context: context, 
              builder: (ctx) => TokenModal(
                server: serverObj,
                onCancel: () {
                  setState(() {
                    isTokenModalOpen = false;
                    isConnecting = false;
                  });
                  Navigator.pop(context);
                },
                onConfirm: (value) async {
                  setState(() => isTokenModalOpen = false);
                  Navigator.pop(context);
                  serversProvider.addServer(Server(
                    address: serverObj.address,
                    alias: serverObj.alias,
                    password: serverObj.password,
                    pwHash: value,
                    defaultServer: defaultCheckbox,
                    enabled: result['status'] == 'enabled' ? true : false
                  ));
                },
              ),
              useSafeArea: true,
              barrierDismissible: false
            );
          }
          else {
            setState(() {
              isConnecting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.noConnection),
                backgroundColor: Colors.red,
              )
            );
          }
        }
        else {
          setState(() {
            isConnecting = false;
          });
          if (result['result'] == 'socket') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.checkAddress),
                backgroundColor: Colors.red,
              )
            );
          }
          else if (result['result'] == 'timeout') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.connectionTimeout),
                backgroundColor: Colors.red,
              )
            );
          }
          else if (result['result'] == 'no_connection') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.cantReaachServer),
                backgroundColor: Colors.red,
              )
            );
          }
          else if (result['result'] == 'token_invalid') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.passwordNotValid),
                backgroundColor: Colors.red,
              )
            );
          }
          else if (result['result'] == 'ssl_error') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.sslErrorLong),
                backgroundColor: Colors.red,
              )
            );
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.unknownError),
                backgroundColor: Colors.red,
              )
            );
          }
        }
      }
    }

    void _save() async {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        errorUrl = null;
        isConnecting = true;
      });
      final serverObj = Server(
        address: widget.server!.address, 
        alias: aliasFieldController.text,
        password: passwordFieldController.text, 
        defaultServer: false,
      );
      final result = await login(serverObj);
      if (result['result'] == 'success') {
        final hash = hashPassword(serverObj.password);
        final isHashValid = await testHash(serverObj, hash);
        if (isHashValid['result'] == 'success') {
          Server server = Server(
            address: widget.server!.address, 
            alias: aliasFieldController.text,
            password: passwordFieldController.text, 
            pwHash: hash,
            defaultServer: defaultCheckbox,
          );
          final result = await serversProvider.editServer(server);
          if (result == true) {
            Navigator.pop(context);
          }
          else {
            setState(() {
              isConnecting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.cantSaveConnectionData),
                backgroundColor: Colors.red,
              )
            );
          }
        }
        else if (isHashValid['result'] == 'hash_not_valid') {
          setState(() => isTokenModalOpen = true);
          showDialog(
            useSafeArea: true,
            barrierDismissible: false,
            context: context, 
            builder: (ctx) => TokenModal(
              server: serverObj,
              onCancel: () {
                setState(() {
                  isTokenModalOpen = false;
                  isConnecting = false;
                });
                Navigator.pop(context);
              },
              onConfirm: (value) async {
                setState(() => isTokenModalOpen = false);
                Server server = Server(
                  address: widget.server!.address, 
                  alias: aliasFieldController.text,
                  password: passwordFieldController.text, 
                  pwHash: hash,
                  defaultServer: defaultCheckbox,
                );
                final result = await serversProvider.editServer(server);
                if (result == true) {
                  Navigator.pop(context);
                }
                else {
                  setState(() {
                    isConnecting = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.cantSaveConnectionData),
                      backgroundColor: Colors.red,
                    )
                  );
                }
              },
            ),
          );
        }
        else {
          setState(() {
            isConnecting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noConnection),
              backgroundColor: Colors.red,
            )
          );
        }
      }
      else {
        setState(() {
          isConnecting = false;
        });
        if (result['result'] == 'socket') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.checkAddress),
              backgroundColor: Colors.red,
            )
          );
        }
        else if (result['result'] == 'timeout') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.connectionTimeout),
              backgroundColor: Colors.red,
            )
          );
        }
        else if (result['result'] == 'no_connection') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.cantReaachServer),
              backgroundColor: Colors.red,
            )
          );
        }
        else if (result['result'] == 'token_invalid') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordNotValid),
              backgroundColor: Colors.red,
            )
          );
        }
        else if (result['result'] == 'ssl_error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.sslErrorLong),
              backgroundColor: Colors.red,
            )
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unknownError),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            systemOverlayStyle: systemUiOverlayStyleConfig(context),
            title: Text(
              widget.server != null 
                ? AppLocalizations.of(context)!.editServer
                : AppLocalizations.of(context)!.addServer,
            ),
            elevation: 5,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: widget.server != null ? _save : _connect,
                  child: Text(AppLocalizations.of(context)!.save )
                ),
              )
            ],
            toolbarHeight: 70,
          ),
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height: mediaQuery.size.height-110,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextFormField(
                                  onChanged: (value) => _validateAddress(value),
                                  controller: addressFieldController,
                                  enabled: widget.server != null ? false : true,
                                  decoration: InputDecoration(
                                    errorText: addressFieldError,
                                    prefixIcon: const Icon(Icons.link),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    labelText: AppLocalizations.of(context)!.address,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: TextFormField(
                                  onChanged: (value) => _validatePort(value),
                                  controller: portFieldController,
                                  enabled: widget.server != null ? false : true,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    errorText: portFieldError,
                                    prefixIcon: const Icon(Icons.numbers),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    labelText: AppLocalizations.of(context)!.port,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => selectedHttp = 'http'),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Radio(
                                            value: 'http', 
                                            groupValue: selectedHttp,
                                            activeColor: Theme.of(context).primaryColor,
                                            onChanged: (value) => setState(() => selectedHttp = value.toString())
                                          ),
                                          const SizedBox(width: 5),
                                          const Text("HTTP")
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => selectedHttp = 'https'),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Radio(
                                            value: 'https', 
                                            groupValue: selectedHttp,
                                            activeColor: Theme.of(context).primaryColor,
                                            onChanged: (value) => setState(() => selectedHttp = value.toString())
                                          ),
                                          const SizedBox(width: 5),
                                          const Text("HTTPS")
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: TextField(
                                  controller: aliasFieldController,
                                  onChanged: (value) => _checkDataValid(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.badge_outlined),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    labelText: AppLocalizations.of(context)!.alias,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: TextField(
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordFieldController,
                                  onChanged: (value) => _checkDataValid(),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                      )
                                    ),
                                    labelText: AppLocalizations.of(context)!.password,
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
                                      AppLocalizations.of(context)!.defaultConnection,
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
                    if (errorUrl != null) Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorUrl!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: isConnecting == true ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: isConnecting == true ? false : true,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                width: mediaQuery.size.width,
                height: mediaQuery.size.height,
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
            ),
          ),
        )
      ],
    );
  }
}