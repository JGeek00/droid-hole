import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoDataChart extends StatelessWidget {
  final String topLabel;

  const NoDataChart({
    super.key,
    required this.topLabel,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            topLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 50),
          Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.noData,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 14
            ),
          ),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}