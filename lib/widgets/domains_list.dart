// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/add_domain_modal.dart';
import 'package:droid_hole/widgets/domain_details_modal.dart';

import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsList extends StatefulWidget {
  final String type;
  final int loadStatus;
  final ScrollController scrollController;

  const DomainsList({
    Key? key,
    required this.type,
    required this.loadStatus,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<DomainsList> createState() => _DomainsListState();
}

class _DomainsListState extends State<DomainsList> {
  late bool isVisible;

  Widget domainType(int type) {
    String getString(int type) {
      switch (type) {
        case 0:
          return "Whitelist";

        case 1:
          return "Blacklist";

        case 2:
          return "Whitelist Regex";

        case 3:
          return "Blacklist Regex";

        default:
          return "";
       }
    }

    Color getColor(int type) {
      switch (type) {
        case 0:
          return Colors.green;

        case 1:
          return Colors.red;

        case 2:
          return Colors.blue;

        case 3:
          return Colors.orange;

        default:
          return Colors.white;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50)
      ),
      child: Text(
        getString(type),
        style: TextStyle(
          color: getColor(type),
          fontSize: 12,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isVisible = true;
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (mounted && isVisible == true) {
          setState(() => isVisible = false);
        }
      } 
      else {
        if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (mounted && isVisible == false) {
            setState(() => isVisible = true);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final domainsListProvider = Provider.of<DomainsListProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final List<Domain> data = widget.type == 'whitelist'
      ? domainsListProvider.whitelistDomains
      : domainsListProvider.blacklistDomains;

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
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainRemoved,
          color: Colors.green
        );
      }
      else if (result['result'] == 'error' && result['message'] != null && result['message'] == 'not_exists') {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainNotExists,
          color: Colors.red
        );
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.errorRemovingDomain,
          color: Colors.red
        );
      }
    }

    void openModalAddDomainToList() {
      showModalBottomSheet(
        context: context, 
        builder: (ctx) => AddDomainModal(
          selectedlist: widget.type,
          addDomain: (value) async {
            final ProcessModal process = ProcessModal(context: context);
            process.open(AppLocalizations.of(context)!.addingDomain);

            final result = await addDomainToList(
              server: serversProvider.selectedServer!, 
              domainData: value
            );

            process.close();

            if (result['result'] == 'success') {
              domainsListProvider.fetchDomainsList(serversProvider.selectedServer!);
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.domainAdded,
                color: Colors.green
              );
            }
            else if (result['result'] == 'already_added') {
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.domainAlreadyAdded,
                color: Colors.orange
              );
            }
            else {
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.cannotAddDomain,
                color: Colors.red
              );
            } 
          },
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true
      );
    }

    Widget listContent() {
      return Stack(
        children: [
          if (data.isEmpty) Container(
            height: double.maxFinite,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noDomains,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.grey
                ),
              )
            ),
          ),
          if (data.isNotEmpty) RefreshIndicator(
            onRefresh: () async {
              await domainsListProvider.fetchDomainsList(serversProvider.selectedServer!);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0),
              itemCount: data.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () => {
                  showModalBottomSheet(
                    context: context, 
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => DomainDetailsModal(
                      domain: data[index], 
                      statusBarHeight: MediaQuery.of(context).viewPadding.top, 
                      remove: removeDomain, 
                      enableDisable: (domain) => {}
                    )
                  )
                },
                title: Text(
                  data[index].domain,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Text(formatTimestamp(data[index].dateAdded, 'yyyy-MM-dd')),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Text(
                        '|',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    domainType(data[index].type)
                  ],
                ),
              )
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            bottom: isVisible ?
              appConfigProvider.showingSnackbar
                ? 70 : 20
              : -70,
            right: 20,
            child: FloatingActionButton(
              onPressed: openModalAddDomainToList,
              child: const Icon(Icons.add),
            )
          )
        ],
      );
    }

    switch (widget.loadStatus) {
      case 0:
        return SizedBox(
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
        );
      
      case 1:
        return listContent();
      
      case 2:
        return SizedBox(
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
        );

      default:
        return const SizedBox();
    }
  }
}