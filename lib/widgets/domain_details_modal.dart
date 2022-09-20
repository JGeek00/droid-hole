import 'dart:io';

import 'package:animations/animations.dart';
import 'package:droid_hole/widgets/domain_comment_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/functions/format.dart';
import 'package:droid_hole/models/domain.dart';

class DomainDetailsModal extends StatelessWidget {
  final Domain domain;
  final double statusBarHeight;
  final void Function(Domain) remove;
  final void Function(Domain) enableDisable;

  const DomainDetailsModal({
    Key? key,
    required this.domain,
    required this.statusBarHeight,
    required this.remove,
    required this.enableDisable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget item(IconData icon, String label, Widget value) {
      return Padding(
        padding: const EdgeInsets.all(10),
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

    return Container(
      height:(mediaQuery.size.height-statusBarHeight) > (Platform.isIOS ? 745 : 725)
        ? (Platform.isIOS ? 745 : 725)
        : mediaQuery.size.height - (statusBarHeight),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28)
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Icon(
              Icons.domain_rounded,
              size: 26,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                AppLocalizations.of(context)!.domainDetails,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: item(
                        Icons.domain, 
                        AppLocalizations.of(context)!.domain, 
                        Text(
                          domain.domain,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: item(
                        Icons.category_rounded, 
                        AppLocalizations.of(context)!.type, 
                        Text(
                          getType(domain.type),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: item(
                        Icons.schedule_rounded, 
                        AppLocalizations.of(context)!.dateAdded, 
                        Text(
                          formatTimestamp(domain.dateAdded, 'yyyy-MM-dd'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: item(
                        Icons.update_rounded, 
                        AppLocalizations.of(context)!.dateModified, 
                        Text(
                          formatTimestamp(domain.dateModified, 'yyyy-MM-dd'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: item(
                        Icons.check, 
                        AppLocalizations.of(context)!.status, 
                        Text(
                          domain.enabled == 1
                            ? AppLocalizations.of(context)!.enabled
                            : AppLocalizations.of(context)!.disabled,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: Platform.isIOS ? 20 : 0
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          enableDisable(domain);
                        }, 
                        child: Text(
                          domain.enabled == 1 
                            ? AppLocalizations.of(context)!.disable
                            : AppLocalizations.of(context)!.enable
                        )
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          remove(domain);
                        }, 
                        child: Text(AppLocalizations.of(context)!.remove)
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(AppLocalizations.of(context)!.close)
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}