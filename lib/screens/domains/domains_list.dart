// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/domains/add_domain_modal.dart';
import 'package:droid_hole/screens/domains/domain_details_screen.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/widgets/tab_content_list.dart';

import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsList extends StatefulWidget {
  final String type;
  final LoadStatus loadStatus;
  final ScrollController scrollController;
  final List<Domain> domainsList;

  const DomainsList({
    Key? key,
    required this.type,
    required this.loadStatus,
    required this.scrollController,
    required this.domainsList,
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
          fontSize: 13,
          fontWeight: FontWeight.w400
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
        Navigator.pop(context);
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

    return Stack(
      children: [
        CustomTabContentList(
          loadingGenerator: () => SizedBox(
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          ), 
          itemsCount: widget.domainsList.length,
          contentWidget: (index) => CustomListTile(
            onTap: () => {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => DomainDetailsScreen(
                    domain: widget.domainsList[index], 
                    remove: removeDomain
                  )
                )
              )
            },
            label: widget.domainsList[index].domain,
            description: formatTimestamp(widget.domainsList[index].dateAdded, 'yyyy-MM-dd'),
            trailing: domainType(widget.domainsList[index].type),
          ),
          noData:  Container(
            height: double.maxFinite,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noDomains,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                ),
              )
            ),
          ),
          errorGenerator: () => SizedBox(
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          ), 
          loadStatus: widget.loadStatus, 
          onRefresh: () async => await domainsListProvider.fetchDomainsList(serversProvider.selectedServer!)
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
}