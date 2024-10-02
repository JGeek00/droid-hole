// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/domains/domains_list.dart';
import 'package:droid_hole/screens/domains/domain_details_screen.dart';

import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/models/domain.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/domains_list_provider.dart';

class DomainLists extends StatelessWidget {
  const DomainLists({super.key});

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
    super.key,
    required this.server,
    required this.domainsListProvider,
  });

  @override
  State<DomainListsWidget> createState() => _DomainListsWidgetState();
}

class _DomainListsWidgetState extends State<DomainListsWidget> with TickerProviderStateMixin {
  late TabController tabController;
  final ScrollController scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();

  Domain? selectedDomain;

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
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void removeDomain(Domain domain) async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.deleting);

      final result = await removeDomainFromList(
        server: serversProvider.selectedServer!, 
        domain: domain
      );

      process.close();

      if (result['result'] == 'success') {
        domainsListProvider.removeDomainFromList(domain);

        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainRemoved,
          color: Colors.green
        );
      }
      else if (result['result'] == 'error' && result['message'] != null && result['message'] == 'not_exists') {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainNotExists,
          color: Colors.red
        );
      }
      else {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.errorRemovingDomain,
          color: Colors.red
        );
      }
    }

    Widget scaffold() {
      return DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: ((context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded),
                            SizedBox(width: 16),
                            Text("Whitelist")
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block),
                            SizedBox(width: 16),
                            Text("Blacklist")
                          ],
                        ),
                      ),
                    ]
                  ),
                ),
              )
            ];
          }), 
          body: TabBarView(
            controller: tabController,
            children: [
              DomainsList(
                type: 'whitelist',
                scrollController: scrollController,
                onDomainSelected: (d) => setState(() => selectedDomain = d),
                selectedDomain: selectedDomain,
              ),
              DomainsList(
                type: 'blacklist',
                scrollController: scrollController,
                onDomainSelected: (d) => setState(() => selectedDomain = d),
                selectedDomain: selectedDomain,
              )
            ],
          ),
        )
      );
    }

    if (MediaQuery.of(context).size.width > 900) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: scaffold()
          ),
          Expanded(
            flex: 3,
            child: selectedDomain != null ? DomainDetailsScreen(
              domain: selectedDomain!, 
              remove: (domain) {
                setState(() => selectedDomain = null);
                removeDomain(domain);
              },
            ) : const SizedBox()
          )
        ],
      );
    }
    else {
      return scaffold();
    }
  }
}