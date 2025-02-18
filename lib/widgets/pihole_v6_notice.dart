// ignore_for_file: use_build_context_synchronously

import 'package:droid_hole/config/urls.dart';
import 'package:droid_hole/functions/open_url.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class PiholeV6Notice extends StatelessWidget {
  const PiholeV6Notice({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);

    return AlertDialog(
      scrollable: true,
      title: Column(
        children: [
          Icon(
            Icons.info_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.piholeV6Support,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface
              ),
            ),
          ),
        ],
      ),
      content: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.piholeV6SupportDescription,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 16,),
          ElevatedButton(
            onPressed: () => openUrl(Urls.gitHub), 
            child: Text(AppLocalizations.of(context)!.droidHoleRepository),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await appConfigProvider.setPiholeV6InfoReaden(true);
            Navigator.pop(context);
          }, 
          child: Text(AppLocalizations.of(context)!.close)
        )
      ],
    );
  }
}