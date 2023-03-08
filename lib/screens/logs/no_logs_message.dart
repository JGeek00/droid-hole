import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/classes/no_scroll_behavior.dart';
import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/functions/format.dart';

class NoLogsMessage extends StatelessWidget {
  final double logsPerQuery;

  const NoLogsMessage({
    Key? key,
    required this.logsPerQuery
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final height = MediaQuery.of(context).size.height;

    String noLogsMessage() {
      if (filtersProvider.startTime != null || filtersProvider.endTime != null) {
        return "${AppLocalizations.of(context)!.noLogsDisplay} ${AppLocalizations.of(context)!.between}\n${filtersProvider.startTime != null ? formatTimestamp(filtersProvider.startTime!, "dd/MM/yyyy - HH:mm") : AppLocalizations.of(context)!.now}\n${AppLocalizations.of(context)!.and}\n${filtersProvider.startTime != null ? formatTimestamp(filtersProvider.endTime!, "dd/MM/yyyy - HH:mm") : AppLocalizations.of(context)!.now} ";
      }
      else {
        return "${AppLocalizations.of(context)!.noLogsDisplay} ${AppLocalizations.of(context)!.fromLast} ${logsPerQuery == 0.5 ? '30' : logsPerQuery.toInt()} ${logsPerQuery == 0.5 ? AppLocalizations.of(context)!.minutes : AppLocalizations.of(context)!.hours}";
      }
    }

    return ScrollConfiguration(
      behavior: NoScrollBehavior(),
      child: ListView(
        children: [
          SizedBox(
            height: height-144,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [ 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      noLogsMessage(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}