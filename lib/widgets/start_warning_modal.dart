// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class ImportantInfoModal extends StatelessWidget {
  const ImportantInfoModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);

    return AlertDialog(
      scrollable: true,
      title: Column(
        children: [
          const Icon(
            Icons.info_rounded,
            size: 26,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.importantAnnouncment,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content:  Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.requiredVersions,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),
              ),
              Container(
                width: double.maxFinite,
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text("Pi-hole: v5.12+"),
                    SizedBox(height: 5),
                    Text("Web interface: v5.14.2+")
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.olderVersion,
                textAlign: TextAlign.justify,
              )
            ],
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.letMeKnow,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 30),
          Text(
            AppLocalizations.of(context)!.howToContact,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await appConfigProvider.setImportantInfoReaden(true);
            Navigator.pop(context);
          }, 
          child: Text(AppLocalizations.of(context)!.close)
        )
      ],
    );
  }
}