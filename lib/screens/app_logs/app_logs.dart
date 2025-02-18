// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/screens/app_logs/app_log_details_modal.dart';


class AppLogs extends StatelessWidget {
  const AppLogs({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void copyLogsClipboard() async {
      List<Map<String, String>> logsString = appConfigProvider.logs.map((log) => log.toMap()).toList();
      await Clipboard.setData(
        ClipboardData(text: jsonEncode(logsString))
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.logsCopiedClipboard),
          backgroundColor: Colors.black,
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.logs),
        actions: [
          IconButton(
            onPressed: appConfigProvider.logs.isNotEmpty
              ? copyLogsClipboard
              : null, 
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context)!.copyLogsClipboard,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: appConfigProvider.logs.isNotEmpty
        ? ListView.builder(
          padding: const EdgeInsets.only(top: 0),
          itemCount: appConfigProvider.logs.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(
              appConfigProvider.logs[index].message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
            subtitle: Text(
              appConfigProvider.logs[index].dateTime.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).listTileTheme.textColor
              ),
            ),
            trailing: Text(appConfigProvider.logs[index].type),
            onTap: () => {
              showDialog(
                context: context, 
                builder: (context) => AppLogDetailsModal(
                  log: appConfigProvider.logs[index]
                )
              )
            },
          )
        )
      : Center(
          child: Text(
            AppLocalizations.of(context)!.noSavedLogs,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
    );
  }
}