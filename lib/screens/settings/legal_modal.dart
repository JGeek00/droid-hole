import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegalModal extends StatelessWidget {
  const LegalModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.info,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.legalInfo,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content: Text(
        AppLocalizations.of(context)!.legalText,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text(AppLocalizations.of(context)!.close)
        )
      ],
    );
  }
}