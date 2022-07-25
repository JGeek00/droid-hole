import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/numeric_pad.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class ConnectingServer extends StatelessWidget {
  const ConnectingServer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    return ConnectingServerWidget(
      serversProvider: serversProvider,
      appConfigProvider: appConfigProvider,
    );
  }
}

class ConnectingServerWidget extends StatefulWidget {
  final ServersProvider serversProvider;
  final AppConfigProvider appConfigProvider;

  const ConnectingServerWidget({
    Key? key,
    required this.serversProvider,
    required this.appConfigProvider
  }) : super(key: key);

  @override
  State<ConnectingServerWidget> createState() => _ConnectingServerWidgetState();
}

class _ConnectingServerWidgetState extends State<ConnectingServerWidget> {
  bool isLoading = false;
  String _code = "";

  @override
  void initState() {
    if (widget.appConfigProvider.passCode == null) {
      setState(() {
        isLoading = true;
      });
      connectServer();
    }
    super.initState();
  }

  void connectServer() async {
    Server serverObj = widget.serversProvider.selectedServer!;
    final result = await login(serverObj);
    if (result['result'] == 'success') {
      serverObj.enabled = result['status'] == 'enabled' ? true : false;
      widget.serversProvider.setselectedServerToken('phpSessId', result['phpSessId']);
      widget.serversProvider.setselectedServerToken('token', result['token']);
      widget.serversProvider.setselectedServer(serverObj);
      widget.serversProvider.setRefreshServerStatus(true);
      widget.serversProvider.setIsServerConnected(true);
    }
    else {
      widget.serversProvider.setIsServerConnected(false);
    }
  }

  void updateCode(String value) {
    setState(() => _code = value);
    if (_code.length == 4 && _code == widget.appConfigProvider.passCode) {
      setState(() {
        isLoading = true;
      });
      connectServer();
    }
    else {
      setState(() {
        _code = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isLoading == true
        ? SizedBox(
          width: double.maxFinite,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Icon(
                      Icons.storage_rounded,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context)!.connectingToServer,
                    style: const TextStyle(
                      fontSize: 22
                    ),
                  ),
                ],
              ),
              const CircularProgressIndicator()
            ],
          ),
        )
      : SizedBox(
        height: height,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            height-180 >= 426 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Icon(
                        Icons.lock_open_rounded,
                        size: 30,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Enter code to unlock",
                        style: TextStyle(
                          fontSize: 22
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 30,
                    ),
                    SizedBox(width: 30),
                    Text(
                      "Enter code to unlock",
                      style: TextStyle(
                        fontSize: 22
                      ),
                    ),
                  ],
                ),
            NumericPad(
              onInput: (number) =>_code.length < 4
                ? updateCode(number)
                : {}, 
            )
          ],
        ),
      )
    );
  }
}