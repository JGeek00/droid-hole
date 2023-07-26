import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/screens/domains/delete_domain_modal.dart';
import 'package:droid_hole/screens/domains/domain_comment_modal.dart';

import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/domain.dart';

class DomainDetailsScreen extends StatelessWidget {
  final Domain domain;
  final void Function(Domain) remove;

  const DomainDetailsScreen({
    Key? key,
    required this.domain,
    required this.remove
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getType(int type) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.domainDetails),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context, 
              builder: (context) => DeleteDomainModal(
                onConfirm: () {
                  Navigator.pop(context);
                  remove(domain);
                },
              )
            ),
            icon: const Icon(Icons.delete_rounded)
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: ListView(
        children: [
          CustomListTile(
            leadingIcon: Icons.domain, 
            label: AppLocalizations.of(context)!.domain, 
            description: domain.domain,
          ),
          CustomListTile(
            leadingIcon: Icons.category_rounded, 
            label: AppLocalizations.of(context)!.type, 
            description: getType(domain.type),
          ),
          CustomListTile(
            leadingIcon: Icons.schedule_rounded, 
            label: AppLocalizations.of(context)!.dateAdded, 
            description: formatTimestamp(domain.dateAdded, 'yyyy-MM-dd'),
          ),
          CustomListTile(
            leadingIcon: Icons.update_rounded, 
            label: AppLocalizations.of(context)!.dateModified, 
            description: formatTimestamp(domain.dateModified, 'yyyy-MM-dd'),
          ),
          CustomListTile(
            leadingIcon: Icons.check, 
            label: AppLocalizations.of(context)!.status, 
            description: domain.enabled == 1
              ? AppLocalizations.of(context)!.enabled
              : AppLocalizations.of(context)!.disabled,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: domain.comment != null && domain.comment != "" 
                ? () => {
                  showModal(
                    context: context, 
                    builder: (context) => DomainCommentModal(
                      comment: domain.comment!
                    )
                  )
                } : null,
              child: CustomListTile(
                leadingIcon: Icons.comment_rounded, 
                label: AppLocalizations.of(context)!.comment, 
                description: domain.comment == "" 
                  ? AppLocalizations.of(context)!.noComment
                  : domain.comment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}