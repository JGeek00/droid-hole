// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:droid_hole/widgets/token_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/functions/hash.dart';
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
  String? ipFieldError;
  TextEditingController portFieldController = TextEditingController();
  String? portFieldError;
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  String selectedHttp = 'http';
  bool defaultCheckbox = false;

  String? errorUrl;
  bool allDataValid = false;

  String status = 'form';
  double height = 476;
  String errorMessage = 'Failed';

  bool isTokenModalOpen = false;
  
  void _checkDataValid() {
    if (
      ipFieldController.text != '' &&
      ipFieldError == null &&
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

  void _validateIpAddress(String? value) {
    if (value != null && value != '') {
      RegExp ipAddress = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$');
      if (ipAddress.hasMatch(value) == true) {
        setState(() {
          ipFieldError = null;
        });
      }
      else {
        setState(() {
          ipFieldError = AppLocalizations.of(context)!.invalidIp;
        });
      }
    }
    else {
      setState(() {
        ipFieldError = AppLocalizations.of(context)!.ipCannotEmpty;
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
      ipFieldController.text = splitted[1].split('/')[2];
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

    final width = MediaQuery.of(context).size.width;

    void _connect() async {
      final String url = "$selectedHttp://${ipFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}";
      final exists = await serversProvider.checkUrlExists(url);
      if (exists['result'] == 'success' && exists['exists'] == true) {
        setState(() {
          height = 476;
        });
        await Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            errorUrl = AppLocalizations.of(context)!.connectionAlreadyExists;
          });
        });
      }
      else if (exists['result'] == 'fail') {
        setState(() {
          errorUrl = null;
        });
        setState(() {
          errorMessage = AppLocalizations.of(context)!.cannotCheckUrlSaved;
        });
        setState(() {
          status = 'failed';
          height = 200;
        });
        await Future.delayed(const Duration(seconds: 3), (() {
          setState(() {
            height = 476;
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
                pwHash: hash,
                defaultServer: defaultCheckbox,
                enabled: result['status'] == 'enabled' ? true : false
              ));
            }));
          }
          else if (isHashValid['result'] == 'hash_not_valid') {
            setState(() => isTokenModalOpen = true);
            showDialog(
              context: context, 
              builder: (ctx) => TokenModal(
                server: serverObj,
                onCancel: () {
                  setState(() => isTokenModalOpen = false);
                  Navigator.pop(context);
                },
                onConfirm: (value) async {
                  setState(() => isTokenModalOpen = false);
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
                      pwHash: value,
                      defaultServer: defaultCheckbox,
                      enabled: result['status'] == 'enabled' ? true : false
                    ));
                  }));
                },
              ),
              useSafeArea: true,
              barrierDismissible: false
            );
          }
          else {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.noConnection;
            });
            setState(() {
              status = 'failed';
              height = 200;
            });
            await Future.delayed(const Duration(seconds: 3), (() {
              setState(() {
                height = 476;
              });
            }));
            await Future.delayed(const Duration(milliseconds: 300), (() => {
              setState(() {
                status = 'form';
              })
            }));
          }
        }
        else {
          if (result['result'] == 'socket') {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.checkAddress;
            });
          }
          else if (result['result'] == 'timeout') {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.connectionTimeout;
            });
          }
          else if (result['result'] == 'no_connection') {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.cantReaachServer;
            });
          }
          else if (result['result'] == 'token_invalid') {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.passwordNotValid;
            });
          }
          else if (result['result'] == 'ssl_error') {
            setState(() {
              errorMessage = AppLocalizations.of(context)!.sslErrorLong;
            });
          }
          else {
            errorMessage = AppLocalizations.of(context)!.unknownError;
          }
          setState(() {
            status = 'failed';
            height = 200;
          });
          await Future.delayed(const Duration(seconds: 3), (() {
            setState(() {
              height = 476;
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
              pwHash: hash,
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
                errorMessage = AppLocalizations.of(context)!.cantSaveConnectionData;
                status = 'failed';
                height = 200;
              });
            }
          }));
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
                setState(() => isTokenModalOpen = false);
                Navigator.pop(context);
              },
              onConfirm: (value) async {
                setState(() => isTokenModalOpen = false);
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
                    pwHash: hash,
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
                      errorMessage = AppLocalizations.of(context)!.cantSaveConnectionData;
                      status = 'failed';
                      height = 200;
                    });
                  }
                }));
              },
            ),
          );
        }
        else {
          setState(() {
            errorMessage = AppLocalizations.of(context)!.noConnection;
          });
          setState(() {
            status = 'failed';
            height = 200;
          });
          await Future.delayed(const Duration(seconds: 3), (() {
            setState(() {
              height = 476;
            });
          }));
          await Future.delayed(const Duration(milliseconds: 300), (() => {
            setState(() {
              status = 'form';
            })
          }));
        }
      }
      else {
        if (result['result'] == 'no_connection') {
          setState(() {
            errorMessage = AppLocalizations.of(context)!.checkAddress;
          });
        }
        else if (result['result'] == 'token_invalid') {
          setState(() {
            errorMessage = AppLocalizations.of(context)!.passwordNotValid;
          });
        }
        else if (result['result'] == 'ssl_error') {
          setState(() {
            errorMessage = AppLocalizations.of(context)!.sslErrorLong;
          });
        }
        else {
          errorMessage = AppLocalizations.of(context)!.unknownError;
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
      padding: isTokenModalOpen == true 
        ? const EdgeInsets.all(0)
        : mediaQueryData.viewInsets,
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
                color: Theme.of(context).dialogBackgroundColor,
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
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 40),
        Text(
          AppLocalizations.of(context)!.connecting,
          style: const TextStyle(
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
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 50,
        ),
        const SizedBox(height: 40),
        Text(
          AppLocalizations.of(context)!.saved,
          style: const TextStyle(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey
            ),
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
              ? AppLocalizations.of(context)!.editServer
              : AppLocalizations.of(context)!.addServer,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: (width-60)-120,
                          child: TextFormField(
                            onChanged: (value) => _validateIpAddress(value),
                            controller: ipFieldController,
                            enabled: widget.server != null ? false : true,
                            decoration: InputDecoration(
                              errorText: ipFieldError,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                                )
                              ),
                              labelText: AppLocalizations.of(context)!.ipAddress,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            onChanged: (value) => _validatePort(value),
                            controller: portFieldController,
                            enabled: widget.server != null ? false : true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              errorText: portFieldError,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                                )
                              ),
                              labelText: AppLocalizations.of(context)!.port,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                              onChanged: (value) => setState(() => selectedHttp = value.toString())
                            ),
                            const SizedBox(width: 5),
                            const Text("HTTPS")
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      controller: aliasFieldController,
                      onChanged: (value) => _checkDataValid(),
                      decoration: InputDecoration(
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordFieldController,
                      onChanged: (value) => _checkDataValid(),
                      decoration: InputDecoration(
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
                      label: Text(AppLocalizations.of(context)!.cancel),
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
                        widget.server != null 
                          ? AppLocalizations.of(context)!.save 
                          : AppLocalizations.of(context)!.connect
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