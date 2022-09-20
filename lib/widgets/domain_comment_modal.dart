import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DomainCommentModal extends StatelessWidget {
  final String comment;

  const DomainCommentModal({
    Key? key,
    required this.comment
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Column(
        children: [
          const Icon(
            Icons.comment_rounded,
            size: 26,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.comment,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content: Text(
        comment,
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