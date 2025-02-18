import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteDomainModal extends StatelessWidget {
  final void Function() onConfirm;

  const DeleteDomainModal({
    super.key,
    required this.onConfirm
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.delete,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.deleteDomain,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
            ),
          )
        ],
      ),
      content: Text(
        AppLocalizations.of(context)!.deleteDomainMessage,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(AppLocalizations.of(context)!.cancel)
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () =>  onConfirm(),
              child: Text(AppLocalizations.of(context)!.confirm)
            ),
          ],
        )
      ],
    );
  }
}