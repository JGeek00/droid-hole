import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/domains_list.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';
import 'package:droid_hole/widgets/custom_tab_indicator.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/domain.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class DomainLists extends StatelessWidget {
  const DomainLists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    return DomainListsWidget(
      server: serversProvider.selectedServer!
    );
  }
}

class DomainListsWidget extends StatefulWidget {
  final Server server;

  const DomainListsWidget({
    Key? key,
    required this.server
  }) : super(key: key);

  @override
  State<DomainListsWidget> createState() => _DomainListsWidgetState();
}

class _DomainListsWidgetState extends State<DomainListsWidget> {
  int loadingStatus = 0;
  Map<String, List<Domain>> data = {
    'blacklist': [],
    'whitelist': []
  };

  void fetchDomainsList() async {
    final result = await getDomainLists(
      server: widget.server
    );
    
    if (mounted) {
      if (result['result'] == 'success') {
        setState(() {
          loadingStatus = 1;
          data['whitelist'] = [
            ...result['data']['whitelist'],
            ...result['data']['whitelistRegex']
          ];
          data['blacklist'] = [
            ...result['data']['blacklist'],
            ...result['data']['blacklistRegex']
          ];
        });
      }
      else {
        setState(() {
          loadingStatus = 2;
        });
      }
    }
  }

  @override
  void initState() {
    fetchDomainsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);

    final orientation = MediaQuery.of(context).orientation;

    Widget _generateBody() {
      switch (loadingStatus) {
        case 0:
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.domains),
              centerTitle: true,
            ),
            body: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.loadingList,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                    ),
                  )
                ],
              ),
            ),
          );

        case 1:
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    title: Text(AppLocalizations.of(context)!.domains),
                    centerTitle: true,
                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: serversProvider.selectedServer != null && serversProvider.isServerConnected == true  
                      ? TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: orientation == Orientation.portrait
                          ? CustomTabIndicatorPortrait(
                              indicatorColor: Theme.of(context).primaryColor
                            )
                          :  CustomTabIndicatorLandscape(
                              indicatorColor: Theme.of(context).primaryColor
                            ),
                        tabs: orientation == Orientation.portrait
                          ? [
                              const Tab(
                                icon: Icon(Icons.check_circle_rounded),
                                text: "Whitelist",
                              ),
                              const Tab(
                                icon: Icon(Icons.block),
                                text: "Blacklist",
                              ),
                            ]
                          : [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle_rounded),
                                  SizedBox(width: 10),
                                  Text("Whitelist")
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.block),
                                  SizedBox(width: 10),
                                  Text("Blacklist")
                                ],
                              ),
                            ),
                          ]
                      )
                    : null
                  )
                ];
              }),
              body: TabBarView(
                children: [
                  DomainsList(
                    data: data['whitelist']!,
                  ),
                  DomainsList(
                    data: data['blacklist']!,
                  )
                ],
              ),
            ),
          );

        case 2:
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.domains),
              centerTitle: true,
            ),
            body: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    AppLocalizations.of(context)!.domainsNotLoaded,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                    ),
                  )
                ],
              ),
            ),
          );

        default:
          return const SizedBox();
      }
    } 

    return DefaultTabController(
      length: 2,
      child: serversProvider.selectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? RefreshIndicator(
              onRefresh: () async {
                // TODO: refresh list
              },
              child: _generateBody()
            )
          : const Center(
              child: SelectedServerDisconnected()
            )
        : const NoServerSelected()
    );
  }
}