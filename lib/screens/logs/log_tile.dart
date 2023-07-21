import 'package:droid_hole/models/log.dart';
import 'package:flutter/material.dart';

import 'package:droid_hole/screens/logs/log_status.dart';

import 'package:droid_hole/functions/format.dart';

class LogTile extends StatelessWidget {
  final Log log;
  final void Function(Log) showLogDetails;
  final bool? isLogSelected;

  const LogTile({
    Key? key,
    required this.log,
    required this.showLogDetails,
    this.isLogSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1000) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          borderRadius: BorderRadius.circular(28),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => showLogDetails(log),
            child: AnimatedContainer(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 200),
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isLogSelected == true
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
                        LogStatus(status: log.status, showIcon: true),
                        const SizedBox(height: 10),
                        SizedBox(
                          child: Text(
                            log.url,
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
                            log.device,
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
                  Text(
                    formatTimestamp(log.dateTime, 'HH:mm:ss')
                  ),
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
          onTap: () => showLogDetails(log),
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
                      LogStatus(status: log.status, showIcon: true),
                      const SizedBox(height: 10),
                      SizedBox(
                        child: Text(
                          log.url,
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
                          log.device,
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
                Text(
                  formatTimestamp(log.dateTime, 'HH:mm:ss')
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}