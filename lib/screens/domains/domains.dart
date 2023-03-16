import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/domains/domains_list.dart';

import 'package:droid_hole/models/domain.dart';
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

class _DomainListsWidgetState extends State<DomainListsWidget> with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    widget.domainsListProvider.fetchDomainsList(widget.server);
    widget.domainsListProvider.setSelectedTab(0);
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final domainsListProvider = Provider.of<DomainsListProvider>(context);

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAppBar(
                  title: domainsListProvider.searchMode 
                    ? TextFormField(
                        initialValue: domainsListProvider.searchTerm,
                        onChanged: domainsListProvider.onSearch,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "${AppLocalizations.of(context)!.searchDomains}...",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          )
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.domains),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  actions: [
                    if (domainsListProvider.searchMode == false) IconButton(
                      onPressed: () => domainsListProvider.setSearchMode(true), 
                      icon: const Icon(Icons.search)
                    ),
                    if (domainsListProvider.searchMode == true) IconButton(
                      onPressed: () => setState(() {
                        domainsListProvider.setSearchMode(false);
                        searchController.text = "";
                        domainsListProvider.onSearch("");
                      }), 
                      icon: const Icon(Icons.close_rounded)
                    ),
                    const SizedBox(width: 10)
                  ],
                  bottom: TabBar(
                    controller: tabController,
                    onTap: (value) => domainsListProvider.setSelectedTab(value),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.check_circle_rounded),
                        text: "Whitelist",
                      ),
                      Tab(
                        icon: Icon(Icons.block),
                        text: "Blacklist",
                      ),
                    ]
                  ),
                ),
              ),
            )
          ];
        }), 
        body: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).brightness == Brightness.light
                  ? const Color.fromRGBO(220, 220, 220, 1)
                  : const Color.fromRGBO(50, 50, 50, 1)
              )
            )
          ),
          child: TabBarView(
            controller: tabController,
            children: [
              DomainsList(
                type: 'whitelist',
                loadStatus: domainsListProvider.loadingStatus,
                scrollController: scrollController,
                domainsList: domainsListProvider.filteredWhitelistDomains,
              ),
              DomainsList(
                type: 'blacklist',
                loadStatus: domainsListProvider.loadingStatus,
                scrollController: scrollController,
                domainsList: domainsListProvider.filteredBlacklistDomains,
              )
            ],
          )
        ),
      )
    );
  }
}