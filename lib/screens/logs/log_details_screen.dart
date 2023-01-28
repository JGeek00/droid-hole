import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/logs/log_status.dart';

import 'package:droid_hole/models/log.dart';
import 'package:droid_hole/functions/format.dart';

class LogDetailsScreen extends StatelessWidget {
  final Log log;
  final void Function(String, Log) whiteBlackList;

  const LogDetailsScreen({
    Key? key,
    required this.log,
    required this.whiteBlackList
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget item(IconData icon, String label, Widget value) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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

    Widget blackWhiteListButton() {
      if (
        log.status == '2' ||
        log.status == '3' ||
        log.status == '12' ||
        log.status == '13' ||
        log.status == '14'
      ) {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
            whiteBlackList('black', log);
          }, 
          icon: const Icon(Icons.gpp_bad_rounded),
          tooltip: AppLocalizations.of(context)!.blacklist,
        );
      }
      else {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
            whiteBlackList('white', log);
          }, 
          icon: const Icon(Icons.verified_user_rounded),
          tooltip: AppLocalizations.of(context)!.whitelist,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logDetails),
        actions: [
          blackWhiteListButton(),
        ],
      ),
      body: ListView(
        children: [
          item(
            Icons.link, 
            AppLocalizations.of(context)!.url, 
            Text(
              log.url,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
          item(
            Icons.http_rounded, 
            AppLocalizations.of(context)!.type, 
            Text(
              log.type,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
          item(
            Icons.phone_android_rounded, 
            AppLocalizations.of(context)!.device, 
            Text(
              log.device,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
          item(
            Icons.access_time_outlined, 
            AppLocalizations.of(context)!.time, 
            Text(
              formatTimestamp(log.dateTime, 'HH:mm:ss'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
          item(
            Icons.shield_outlined, 
            AppLocalizations.of(context)!.status, 
            LogStatus(status: log.status, showIcon: false)
          ),
          if (log.status == '2' && log.answeredBy != null) item(
            Icons.domain, 
            AppLocalizations.of(context)!.answeredBy, 
            Text(
              log.answeredBy!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
          item(
            Icons.system_update_alt_outlined, 
            AppLocalizations.of(context)!.reply, 
            Text(
              "${log.replyType} (${(log.replyTime/10)} ms)",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            )
          ),
        ],
      ),
    );
  }
}