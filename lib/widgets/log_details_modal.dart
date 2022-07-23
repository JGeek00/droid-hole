import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/log_status.dart';

import 'package:droid_hole/models/log.dart';
import 'package:droid_hole/functions/format.dart';

class LogDetailsModal extends StatelessWidget {
  final Log log;
  final double statusBarHeight;
  final void Function(String, Log) whiteBlackList;

  const LogDetailsModal({
    Key? key,
    required this.log,
    required this.statusBarHeight,
    required this.whiteBlackList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget _item(IconData icon, String label, Widget value) {
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

    Widget _blackWhiteListButton() {
      if (
        log.status == '2' ||
        log.status == '3' ||
        log.status == '12' ||
        log.status == '13' ||
        log.status == '14'
      ) {
        return TextButton(
          onPressed: () {
            Navigator.pop(context);
            whiteBlackList('black', log);
          }, 
          child: Text(AppLocalizations.of(context)!.blacklist)
        );
      }
      else {
        return TextButton(
          onPressed: () {
            Navigator.pop(context);
            whiteBlackList('white', log);
          }, 
          child: Text(AppLocalizations.of(context)!.whitelist)
        );
      }
    }

    return Container(
      height: log.status == '2' && log.answeredBy != null
        ? (mediaQuery.size.height-statusBarHeight) > 820
          ? 820
          : mediaQuery.size.height - (statusBarHeight)
        : (mediaQuery.size.height-statusBarHeight) > 745
          ? 745
          : mediaQuery.size.height - (statusBarHeight),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Icon(
              Icons.description_rounded,
              size: 30,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                AppLocalizations.of(context)!.logDetails,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _item(Icons.link, AppLocalizations.of(context)!.url, Text(
                      log.url,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 20),
                    _item(Icons.http_rounded, AppLocalizations.of(context)!.type, Text(log.type)),
                    const SizedBox(height: 20),
                    _item(Icons.phone_android_rounded, AppLocalizations.of(context)!.device, Text(
                      log.device,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 20),
                    _item(Icons.access_time_outlined, AppLocalizations.of(context)!.time, Text(formatTimestamp(log.dateTime, 'HH:mm:ss'))),
                    const SizedBox(height: 20),
                    _item(Icons.shield_outlined, AppLocalizations.of(context)!.status, LogStatus(status: log.status, showIcon: false)),
                    const SizedBox(height: 20),
                    if (log.status == '2' && log.answeredBy != null) ...[
                      _item(Icons.domain, AppLocalizations.of(context)!.answeredBy, Text(
                        log.answeredBy!,
                        overflow: TextOverflow.ellipsis,
                      )),
                      const SizedBox(height: 20),
                    ],
                    _item(Icons.system_update_alt_outlined, AppLocalizations.of(context)!.reply, Text("${log.replyType} (${(log.replyTime/10)} ms)")),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _blackWhiteListButton(),
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text(AppLocalizations.of(context)!.close)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}