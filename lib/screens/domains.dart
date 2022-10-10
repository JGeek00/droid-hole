import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/domains_list.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';
import 'package:droid_hole/widgets/custom_tab_indicator.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/domains_list_provider.dart';

class DomainLists extends StatelessWidget {
  const DomainLists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final domainsListProvider = Provider.of<DomainsListProvider>(context, listen: false);

    return DomainListsWidget(
      server: serversProvider.selectedServer!,
      domainsListProvider: domainsListProvider
    );
  }
}

class DomainListsWidget extends StatefulWidget {
  final Server server;
  final DomainsListProvider domainsListProvider;

  const DomainListsWidget({
    Key? key,
    required this.server,
    required this.domainsListProvider,
  }) : super(key: key);

  @override
  State<DomainListsWidget> createState() => _DomainListsWidgetState();
}

class _DomainListsWidgetState extends State<DomainListsWidget> {

  @override
  void initState() {
    widget.domainsListProvider.fetchDomainsList(widget.server);
    widget.domainsListProvider.setSelectedTab(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final domainsListProvider = Provider.of<DomainsListProvider>(context);

    final orientation = MediaQuery.of(context).orientation;

    Widget generateBody() {
      switch (domainsListProvider.loadingStatus) {
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
              physics: const NeverScrollableScrollPhysics(),
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverSafeArea(
                      top: false,
                      sliver: SliverAppBar(
                        title: Text(AppLocalizations.of(context)!.domains),
                        centerTitle: true,
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxIsScrolled,
                        bottom: serversProvider.selectedServer != null && serversProvider.isServerConnected == true  
                          ? TabBar(
                            onTap: (value) => domainsListProvider.setSelectedTab(value),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: orientation == Orientation.portrait
                              ? CustomTabIndicatorPortrait(
                                  indicatorColor: Theme.of(context).primaryColor,
                                  itemsTabBar: 2
                                )
                              :  CustomTabIndicatorLandscape(
                                  indicatorColor: Theme.of(context).primaryColor,
                                  itemsTabBar: 2
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
                      ),
                    ),
                  )
                ];
              }),
              body: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromRGBO(220, 220, 220, 1)
                        : const Color.fromRGBO(50, 50, 50, 1)
                    )
                  )
                ),
                child: const TabBarView(
                  children: [
                    DomainsList(type: 'whitelist'),
                    DomainsList(type: 'blacklist')
                  ],
                ),
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
          ? generateBody()
          : Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.domains),
                centerTitle: true,
              ),
              body: const Center(
                child: SelectedServerDisconnected()
              ),
            )
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.domains),
              centerTitle: true,
            ),
            body: const NoServerSelected()
          )
    );
  }
}