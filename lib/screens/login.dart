import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/services/http_requests.dart';

class LoginScreen extends StatefulWidget {
  final ServersProvider serversProvider;
  final FiltersProvider filtersProvider;

  const LoginScreen({
    Key? key,
    required this.serversProvider,
    required this.filtersProvider,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  void logIn() async {
    final result = await widget.serversProvider.login(widget.serversProvider.selectedServer!);
    if (result == true) {
      final data = await Future.wait([
        realtimeStatus(widget.serversProvider.selectedServer!, widget.serversProvider.selectedServer!.token!),
        fetchOverTimeData(widget.serversProvider.selectedServer!, widget.serversProvider.phpSessId!)
      ]);
      if (data[0]['result'] == 'success' && data[1]['result'] == 'success') {
        widget.serversProvider.setRealtimeStatus(data[0]['data']);
        widget.serversProvider.setOvertimeData(data[1]['data']);
        widget.serversProvider.setOvertimeDataLoadingStatus(1);
        List<dynamic> clients = data[1]['data'].clients.map((client) {
          if (client.name != '') {
            return client.name.toString();
          }
          else {
            return client.ip.toString();
          }
        }).toList();
        widget.filtersProvider.setClients(List<String>.from(clients));
        widget.serversProvider.setNeedsLogin(false);
      }
      else {
        widget.serversProvider.setselectedServer(null);
        widget.serversProvider.setNeedsLogin(false);
      }
    }
    else {
      widget.serversProvider.setselectedServer(null);
      widget.serversProvider.setNeedsLogin(false);
    }
  }

  @override
  void initState() {
    logIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            'assets/icon/icon-no-background.png',
            width: 150,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.storage_rounded,
                      size: 30,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        "${AppLocalizations.of(context)!.connectingTo} ${widget.serversProvider.selectedServer!.alias}...",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 22,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}