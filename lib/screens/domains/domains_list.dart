// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/domains/add_domain_modal.dart';
import 'package:droid_hole/screens/domains/domain_tile.dart';
import 'package:droid_hole/screens/domains/domain_details_screen.dart';
import 'package:droid_hole/widgets/tab_content_list.dart';

import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsList extends StatefulWidget {
  final String type;
  final LoadStatus loadStatus;
  final ScrollController scrollController;
  final List<Domain> domainsList;
  final void Function(Domain) onDomainSelected;
  final Domain? selectedDomain;

  const DomainsList({
    Key? key,
    required this.type,
    required this.loadStatus,
    required this.scrollController,
    required this.domainsList,
    required this.onDomainSelected,
    required this.selectedDomain
  }) : super(key: key);

  @override
  State<DomainsList> createState() => _DomainsListState();
}

class _DomainsListState extends State<DomainsList> {
  late bool isVisible;

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

    void onAddDomain(Map<String, dynamic> value) async {
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
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainAdded,
          color: Colors.green
        );
      }
      else if (result['result'] == 'already_added') {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.domainAlreadyAdded,
          color: Colors.orange
        );
      }
      else {
        showSnackBar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotAddDomain,
          color: Colors.red
        );
      } 
    }

    void openModalAddDomainToList() {
      if (MediaQuery.of(context).size.width > 700) {
        showDialog(
          context: context,
          builder: (ctx) => AddDomainModal(
            selectedlist: widget.type,
            addDomain: onAddDomain,
            window: true,
          ),
        );
      }
      else {
        showModalBottomSheet(
          context: context, 
          builder: (ctx) => AddDomainModal(
            selectedlist: widget.type,
            addDomain: onAddDomain,
            window: false,
          ),
          backgroundColor: Colors.transparent,
          isScrollControlled: true
        );
      }
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
          contentWidget: (index) => Padding(
            padding: index == 0 && MediaQuery.of(context).size.width > 900
              ? const EdgeInsets.only(top: 16) 
              : const EdgeInsets.all(0),
            child: DomainTile(
              domain:  widget.domainsList[index],
              isDomainSelected: widget.selectedDomain == widget.domainsList[index],
              showDomainDetails: (domain) {
                widget.onDomainSelected(widget.domainsList[index]);
                if (MediaQuery.of(context).size.width <= 900 && widget.domainsList.length > index) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => DomainDetailsScreen(
                        domain: widget.domainsList[index], 
                        remove: removeDomain,
                      )
                    )
                  );
                }
              },  
          
            ),
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