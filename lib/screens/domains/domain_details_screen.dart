import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final mediaQuery = MediaQuery.of(context);

    Widget item(IconData icon, String label, Widget value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: mediaQuery.size.width - 114,
                  child: value,
                )
              ],
            )
          ],
        ),
      );  
    }

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
          item(
            Icons.domain, 
            AppLocalizations.of(context)!.domain, 
            Text(
              domain.domain,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          item(
            Icons.category_rounded, 
            AppLocalizations.of(context)!.type, 
            Text(
              getType(domain.type),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          item(
            Icons.schedule_rounded, 
            AppLocalizations.of(context)!.dateAdded, 
            Text(
              formatTimestamp(domain.dateAdded, 'yyyy-MM-dd'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          item(
            Icons.update_rounded, 
            AppLocalizations.of(context)!.dateModified, 
            Text(
              formatTimestamp(domain.dateModified, 'yyyy-MM-dd'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          item(
            Icons.check, 
            AppLocalizations.of(context)!.status, 
            Text(
              domain.enabled == 1
                ? AppLocalizations.of(context)!.enabled
                : AppLocalizations.of(context)!.disabled,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: domain.comment != "" 
                ? () => {
                  showModal(
                    context: context, 
                    builder: (context) => DomainCommentModal(
                      comment: domain.comment
                    )
                  )
                } : null,
              child: item(
                Icons.comment_rounded, 
                AppLocalizations.of(context)!.comment, 
                Text(
                  domain.comment == "" 
                    ? AppLocalizations.of(context)!.noComment
                    : domain.comment,
                  overflow: TextOverflow.ellipsis,
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}