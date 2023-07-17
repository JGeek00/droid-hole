// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/section_label.dart';
import 'package:droid_hole/widgets/scan_token_modal.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';

class AddServerFullscreen extends StatefulWidget {
  final Server? server;
  final bool window;

  const AddServerFullscreen({
    Key? key,
    this.server,
    required this.window
  }) : super(key: key);

  @override
  State<AddServerFullscreen> createState() => _AddServerFullscreenState();
}

enum ConnectionType { http, https}

class _AddServerFullscreenState extends State<AddServerFullscreen> {
  TextEditingController addressFieldController = TextEditingController();
  String? addressFieldError;
  TextEditingController portFieldController = TextEditingController();
  String? portFieldError;
  TextEditingController subrouteFieldController = TextEditingController();
  String? subrouteFieldError;
  TextEditingController aliasFieldController = TextEditingController();
  TextEditingController tokenFieldController = TextEditingController();
  ConnectionType connectionType = ConnectionType.http;
  TextEditingController basicAuthUser = TextEditingController();
  TextEditingController basicAuthPassword = TextEditingController();
  bool defaultCheckbox = false;

  String? errorUrl;
  bool allDataValid = false;

  String errorMessage = 'Failed';

  bool isTokenModalOpen = false;

  bool isConnecting = false;

  void checkDataValid() {
    if (
      addressFieldController.text != '' &&
      addressFieldError == null &&
      subrouteFieldError == null &&
      portFieldError == null &&
      aliasFieldController.text != '' &&
      tokenFieldController.text != '' &&
      (
        (basicAuthUser.text != '' && basicAuthPassword.text != '') ||
        (basicAuthUser.text == '' && basicAuthPassword.text == '')
      )
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

  void validateAddress(String? value) {
    if (value != null && value != '') {
      RegExp ipAddress = RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$');
      RegExp domain = RegExp(r'^(([a-z0-9|-]+\.)*[a-z0-9|-]+\.[a-z]+)|((\w|-)+)$');
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
    checkDataValid();
  }

  void validateSubroute(String? value) {
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
    checkDataValid();
  }

  void validatePort(String? value) {
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
    checkDataValid();
  }

  void openHowCreateConnection() {
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
      basicAuthUser.text = widget.server!.basicAuthUser ?? '';
      basicAuthPassword.text = widget.server!.basicAuthPassword ?? '';
      setState(() {
        connectionType = widget.server!.address.split(':')[0] == 'https' 
          ? ConnectionType.https 
          : ConnectionType.http;
        defaultCheckbox = widget.server!.defaultServer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    void connect() async {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        isConnecting = true;
      });
      final String url = "${connectionType.name}://${addressFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}${subrouteFieldController.text}";
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
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotCheckUrlSaved,
          color: Colors.red
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
          basicAuthUser: basicAuthUser.text,
          basicAuthPassword: basicAuthPassword.text
        );
        final result = await loginQuery(serverObj);
        if (result['result'] == 'success') {
          Navigator.pop(context);
          serversProvider.addServer(Server(
            address: serverObj.address,
            alias: serverObj.alias,
            token: serverObj.token,
            defaultServer: defaultCheckbox,
            enabled: result['status'] == 'enabled' ? true : false,
            basicAuthUser: basicAuthUser.text,
            basicAuthPassword: basicAuthPassword.text
          ));
        }
        else {
          setState(() {
            isConnecting = false;
          });
          if (result['result'] == 'socket') {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.checkAddress,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
          else if (result['result'] == 'timeout') {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.connectionTimeout,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
          else if (result['result'] == 'no_connection') {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.cantReachServer,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
          else if (result['result'] == 'auth_error') {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.tokenNotValid,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
          else if (result['result'] == 'ssl_error') {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.sslErrorLong,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
          else {
            showSnackBar(
              context: context, 
              appConfigProvider: appConfigProvider,
              label: AppLocalizations.of(context)!.unknownError,
              color: Colors.red
            );
            appConfigProvider.addLog(result['log']);
          }
        }
      }
    }

    void save() async {
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
        basicAuthUser: basicAuthUser.text,
        basicAuthPassword: basicAuthPassword.text
      );
      final result = await loginQuery(serverObj);
      if (result['result'] == 'success') {
        Server server = Server(
          address: widget.server!.address, 
          alias: aliasFieldController.text,
          token: tokenFieldController.text,
          defaultServer: defaultCheckbox,
          basicAuthUser: basicAuthUser.text,
          basicAuthPassword: basicAuthPassword.text
        );
        final result = await serversProvider.editServer(server);
        if (result == true) {
          Navigator.pop(context);
        }
        else {
          setState(() {
            isConnecting = false;
          });
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.cantSaveConnectionData,
            color: Colors.red
          );
        }
      }
      else {
        setState(() {
          isConnecting = false;
        });
        if (result['result'] == 'socket') {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.checkAddress,
            color: Colors.red
          );
        }
        else if (result['result'] == 'timeout') {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.connectionTimeout,
            color: Colors.red
          );
        }
        else if (result['result'] == 'no_connection') {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.cantReachServer,
            color: Colors.red
          );
        }
        else if (result['result'] == 'auth_error') {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.tokenNotValid,
            color: Colors.red
          );
        }
        else if (result['result'] == 'ssl_error') {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.sslErrorLong,
            color: Colors.red
          );
        }
        else {
          showSnackBar(
            context: context, 
            appConfigProvider: appConfigProvider,
            label: AppLocalizations.of(context)!.unknownError,
            color: Colors.red
          );
        }
      }
    }

    bool validData() {
      if (
        addressFieldController.text != '' && 
        subrouteFieldError == null &&
        addressFieldError == null &&
        aliasFieldController.text != '' && 
        (
          (basicAuthUser.text != '' && basicAuthPassword.text != '') ||
          (basicAuthUser.text == '' && basicAuthPassword.text == '')
        )
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

    Widget formItems() {
      return ListView(
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
                      color: Theme.of(context).colorScheme.primary
                    ),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05)
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${connectionType.name}://${addressFieldController.text}${portFieldController.text != '' ? ':${portFieldController.text}' : ''}${subrouteFieldController.text}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    ],
                  ),
                ),
                SectionLabel(
                  label: AppLocalizations.of(context)!.connection,
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: TextField(
                    controller: aliasFieldController,
                    onChanged: (value) => checkDataValid(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        )
                      ),
                      labelText: AppLocalizations.of(context)!.serverName,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.maxFinite,
                  child: SegmentedButton<ConnectionType>(
                    segments: const [
                      ButtonSegment(
                        value: ConnectionType.http,
                        label: Text("HTTP")
                      ),
                      ButtonSegment(
                        value: ConnectionType.https,
                        label: Text("HTTPS")
                      ),
                    ], 
                    selected: <ConnectionType>{connectionType},
                    onSelectionChanged: (value) => setState(() => connectionType = value.first),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    onChanged: (value) => validateAddress(value),
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
                    onChanged: (value) => validateSubroute(value),
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
                    onChanged: (value) => validatePort(value),
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
                SectionLabel(
                  label: AppLocalizations.of(context)!.authentication,
                  padding: const EdgeInsets.only(
                    top: 30,
                    bottom: 10
                  )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          controller: tokenFieldController,
                          onChanged: (value) => checkDataValid(),
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
                      if (Platform.isAndroid || Platform.isIOS) ...[
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: openScanTokenModal, 
                          icon: const Icon(Icons.qr_code_rounded),
                          tooltip: AppLocalizations.of(context)!.scanQrCode,
                        )
                      ]
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.tokenInstructions,
                          )
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionLabel(
                  label: AppLocalizations.of(context)!.basicAuth,
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10
                  )
                ),
                Card(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.basicAuthInfo,
                          )
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextFormField(
                    onChanged: (_) => checkDataValid(),
                    controller: basicAuthUser,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_rounded),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        )
                      ),
                      labelText: AppLocalizations.of(context)!.username,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 30),
                  child: TextFormField(
                    onChanged: (_) => checkDataValid(),
                    controller: basicAuthPassword,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key_rounded),
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
                        setState(() => defaultCheckbox = !defaultCheckbox)
                      } : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.server == null ? (() => {
                        setState(() => defaultCheckbox = !defaultCheckbox)
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
      );
    }
    
    if (widget.window == true) {
      return Dialog(
        child: SizedBox(
          width: 400,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context), 
                          icon: const Icon(Icons.clear_rounded)
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.createConnection,
                          style: const TextStyle(
                            fontSize: 20
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: openHowCreateConnection, 
                          icon: const Icon(Icons.help_outline_rounded),
                          tooltip: AppLocalizations.of(context)!.howCreateConnection,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            tooltip: widget.server != null 
                              ? AppLocalizations.of(context)!.save 
                              : AppLocalizations.of(context)!.connect,
                            onPressed: validData()
                              ? widget.server != null ? save : connect
                              : null,
                            icon: widget.server != null 
                              ? const Icon(Icons.save_rounded)
                              : const Icon(Icons.login_rounded)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: formItems()
              )
            ],
          ),
        ),
      );
    }
    else {
      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.createConnection),
              actions: [
                IconButton(
                  onPressed: openHowCreateConnection, 
                  icon: const Icon(Icons.help_outline_rounded),
                  tooltip: AppLocalizations.of(context)!.howCreateConnection,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    tooltip: widget.server != null 
                      ? AppLocalizations.of(context)!.save 
                      : AppLocalizations.of(context)!.connect,
                    onPressed: validData()
                      ? widget.server != null ? save : connect
                      : null,
                    icon: widget.server != null 
                      ? const Icon(Icons.save_rounded)
                      : const Icon(Icons.login_rounded)
                  ),
                ),
              ],
              toolbarHeight: 70,
            ),
            body: formItems()
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
}