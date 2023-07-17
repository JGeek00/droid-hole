import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';


class StatisticsVisualizationScreen extends StatelessWidget {
  const StatisticsVisualizationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    Widget item(String title, String description, IconData icon, int value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: () => appConfigProvider.setStatisticsVisualizationMode(value),
            borderRadius: BorderRadius.circular(28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: value == appConfigProvider.statisticsVisualizationMode
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).dialogBackgroundColor,
                border: Border.all(
                  color: value == appConfigProvider.statisticsVisualizationMode
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey
                )
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 50,
                    color: value == appConfigProvider.statisticsVisualizationMode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: value == appConfigProvider.statisticsVisualizationMode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: mediaQuery.size.width-170,
                          child: Text(
                            description,
                            style: TextStyle(
                              color: value == appConfigProvider.statisticsVisualizationMode
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.domainsClientsDataMode),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          item(
            AppLocalizations.of(context)!.list,
            AppLocalizations.of(context)!.listDescription,
            Icons.list_rounded,
            0
          ),
          const SizedBox(height: 24),
          item(
            AppLocalizations.of(context)!.pieChart,
            AppLocalizations.of(context)!.pieChartDescription,
            Icons.pie_chart_rounded, 
            1
          ),
        ],
      ),
    );
  }
}