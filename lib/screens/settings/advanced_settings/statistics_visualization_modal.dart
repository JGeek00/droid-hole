import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';


class StatisticsVisualizationModal extends StatelessWidget {
  final double statusBarHeight;

  const StatisticsVisualizationModal({
    Key? key,
    required this.statusBarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    Widget _item(String title, String description, IconData icon, int value) {
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
                      : Theme.of(context).textTheme.bodyLarge!.color
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: value == appConfigProvider.statisticsVisualizationMode
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyLarge!.color
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
                              : Theme.of(context).textTheme.bodyLarge!.color
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: mediaQuery.orientation == Orientation.landscape
        ? mediaQuery.size.height - (statusBarHeight)
        : Platform.isIOS ? 550 : 530,
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
            padding: EdgeInsets.only(top: 24),
            child: Icon(
              Icons.pie_chart_rounded,
              size: 26,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 24
            ),
            child: Text(
              AppLocalizations.of(context)!.domainsClientsDataMode,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _item(
                    AppLocalizations.of(context)!.list,
                    AppLocalizations.of(context)!.listDescription,
                    Icons.list_rounded,
                    0
                  ),
                  const SizedBox(height: 24),
                  _item(
                    AppLocalizations.of(context)!.pieChart,
                    AppLocalizations.of(context)!.pieChartDescription,
                    Icons.pie_chart_rounded, 
                    1
                  ),
                ],
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(AppLocalizations.of(context)!.close)
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}