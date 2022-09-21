// ignore_for_file: use_build_context_synchronously

import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/domain_details_modal.dart';

import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/domain.dart';

class DomainsList extends StatelessWidget {
  final String type;

  const DomainsList({
    Key? key,
    required this.type
  }) : super(key: key);

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
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final domainsListProvider = Provider.of<DomainsListProvider>(context);

    final List<Domain> data = type == 'whitelist'
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.domainRemoved),
            backgroundColor: Colors.green,
          )
        );
      }
      else if (result['result'] == 'error' && result['message'] != null && result['message'] == 'not_exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.domainNotExists),
            backgroundColor: Colors.red,
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorRemovingDomain),
            backgroundColor: Colors.red,
          )
        );
      }
    }

    if (data.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await domainsListProvider.fetchDomainsList(serversProvider.selectedServer!);
        },
        child: Container(
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
      );
    }
    else {
      return RefreshIndicator(
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
      );
    }
  }
}