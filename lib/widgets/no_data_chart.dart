import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoDataChart extends StatelessWidget {
  final String topLabel;

  const NoDataChart({
    Key? key,
    required this.topLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Text(
            topLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey
            ),
          ),
          const SizedBox(height: 30),
          const Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.noData,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          )
        ],
      ),
    );
  }
}