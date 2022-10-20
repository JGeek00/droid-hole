// ignore_for_file: use_build_context_synchronously

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/scan_token_modal.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/services/http_requests.dart';
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
  TextEditingController subrouteFieldController = TextEditingController();
  String? subrouteFieldError;
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController tokenFieldController = TextEditingController();
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
      subrouteFieldError == null &&
      portFieldError == null &&
      aliasFieldController.text != '' &&
      tokenFieldController.text != ''
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
      RegExp domain = RegExp(r'^([a-z0-9|-]+\.)*[a-z0-9|-]+\.[a-z]+$');
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

  void _validateSubroute(String? value) {
    if (value != null && value != '') {
      RegExp subrouteRegexp = RegExp(r'^\/\b([A-Za-z0-9_\-~/]*)[^\/|\.|\:]$');
      if (subrouteRegexp.hasMatch(value) == true) {
        setState(() {
          subrouteFieldError = null;
        });
      }
      else {
        setState(() {
          subrouteFieldError = AppLocalizations.of(context)!.invalidSubroute;
        });
      }
    }
    else {
      setState(() {
        subrouteFieldError = null;
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

  void _openHowCreateConnection() {
    FlutterWebBrowser.openWebPage(
      url: "https://github.com/JGeek00/droid-hole/wiki/Create-a-connection",
      customTabsOptions: const CustomTabsOptions(
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: false,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      )
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      final List<String> splitted = widget.server!.address.split(':');
      addressFieldController.text = splitted[1].split('/')[2];
      portFieldController.text = splitted.length == 3 ? splitted[2] : '';
      aliasFieldController.text = widget.server!.alias;
      tokenFieldController.text = widget.server!.token ?? '';
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
      final String url = "$selectedHttp://${addressFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}${subrouteFieldController.text}";
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
          token: tokenFieldController.text, 
          defaultServer: false,
        );
        final result = await login(serverObj);
        if (result['result'] == 'success') {
          Navigator.pop(context);
          serversProvider.addServer(Server(
            address: serverObj.address,
            alias: serverObj.alias,
            token: serverObj.token,
            defaultServer: defaultCheckbox,
            enabled: result['status'] == 'enabled' ? true : false
          ));
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
          else if (result['result'] == 'auth_error') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.tokenNotValid),
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
        token: tokenFieldController.text,
        defaultServer: false,
      );
      final result = await login(serverObj);
      if (result['result'] == 'success') {
        Server server = Server(
          address: widget.server!.address, 
          alias: aliasFieldController.text,
          token: tokenFieldController.text,
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
        else if (result['result'] == 'auth_error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.tokenNotValid),
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

    bool _validData() {
      if (
        addressFieldController.text != '' && 
        subrouteFieldError == null &&
        addressFieldError == null &&
        aliasFieldController.text != ''
      ) {
        return true;
      }
      else {
        return false;
      }
    }

    void openScanTokenModal() {
      showDialog(
        context: context, 
        builder: (context) => ScanTokenModal(
          qrScanned: (value) => setState(() => tokenFieldController.text = value),
        )
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          appBar: AppBar(
            systemOverlayStyle: systemUiOverlayStyleConfig(context),
            title: Text(
              widget.server != null 
                ? AppLocalizations.of(context)!.editServer
                : AppLocalizations.of(context)!.addServer,
            ),
            elevation: 5,
            actions: [
              IconButton(
                onPressed: _openHowCreateConnection, 
                icon: const Icon(Icons.help_outline_rounded),
                tooltip: AppLocalizations.of(context)!.howCreateConnection,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  tooltip: widget.server != null 
                    ? AppLocalizations.of(context)!.save 
                    : AppLocalizations.of(context)!.connect,
                  onPressed: _validData()
                    ? widget.server != null ? _save : _connect
                    : null,
                  icon: widget.server != null 
                    ? const Icon(Icons.save_rounded)
                    : const Icon(Icons.login_rounded)
                ),
              ),
            ],
            toolbarHeight: 70,
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Theme.of(context).primaryColor
                        ),
                        color: Theme.of(context).primaryColor.withOpacity(0.05)
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$selectedHttp://${addressFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}${subrouteFieldController.text}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
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
                        onChanged: (value) => _validateSubroute(value),
                        controller: subrouteFieldController,
                        enabled: widget.server != null ? false : true,
                        decoration: InputDecoration(
                          errorText: subrouteFieldError,
                          prefixIcon: const Icon(Icons.route_rounded),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10)
                            )
                          ),
                          labelText: AppLocalizations.of(context)!.subrouteField,
                          hintText: AppLocalizations.of(context)!.subrouteExample,
                          helperText: AppLocalizations.of(context)!.subrouteHelper,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: mediaQuery.size.width - 100,
                            child: TextField(
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              controller: tokenFieldController,
                              onChanged: (value) => _checkDataValid(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.key_rounded),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10)
                                  )
                                ),
                                labelText: AppLocalizations.of(context)!.token,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: openScanTokenModal, 
                            icon: const Icon(Icons.qr_code_rounded),
                            tooltip: AppLocalizations.of(context)!.scanQrCode,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: Theme.of(context).textTheme.bodyText1?.color
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: mediaQuery.size.width - 88,
                          child: Text(
                            AppLocalizations.of(context)!.tokenInstructions,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyText1?.color
                            ),
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
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