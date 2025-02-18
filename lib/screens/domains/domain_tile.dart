import 'package:flutter/material.dart';

import 'package:droid_hole/models/domain.dart';
import 'package:droid_hole/functions/format.dart';

class DomainTile extends StatelessWidget {
  final Domain domain;
  final void Function(Domain) showDomainDetails;
  final bool? isDomainSelected;

  const DomainTile({
    super.key,
    required this.domain,
    required this.showDomainDetails,
    this.isDomainSelected
  });

  @override
  Widget build(BuildContext context) {
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

    if (MediaQuery.of(context).size.width > 900) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          borderRadius: BorderRadius.circular(28),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => showDomainDetails(domain),
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isDomainSelected == true
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text(
                            domain.domain,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          child: Text(
                            formatTimestamp(domain.dateAdded, 'yyyy-MM-dd'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).listTileTheme.textColor,
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  domainType(domain.type),
                ],
              ),
            ),
          ),
        ),
      );
    }
    else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showDomainDetails(domain),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        child: Text(
                          domain.domain,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        child: Text(
                          formatTimestamp(domain.dateAdded, 'yyyy-MM-dd'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).listTileTheme.textColor,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                domainType(domain.type),
              ],
            ),
          ),
        ),
      );
    }
  }
}