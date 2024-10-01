import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart'
;
import 'package:droid_hole/functions/open_url.dart';

class ContactMeModal extends StatefulWidget {
  const ContactMeModal({Key? key}) : super(key: key);

  @override
  State<ContactMeModal> createState() => _ContactMeModalState();
}

class _ContactMeModalState extends State<ContactMeModal> {
  final expandableController = ExpandableController();

  void _sendEmail() {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries.map((MapEntry<String, String> e) => 
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'juangilsanz@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'DroidHole issue',
      }),
    );

    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      scrollable: true,
      contentPadding: const EdgeInsets.all(0),
      title: Column(
        children: [
          Icon(
            Icons.contact_page_rounded,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              AppLocalizations.of(context)!.contact,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openUrl('https://github.com/JGeek00/droid-hole/issues'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 20
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/resources/github.svg',
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GitHub",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)!.openIssueGitHub,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => openUrl('https://appsupport.jgeek00.com'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 20
                ),
                child: Row(
                  children: [
                    Icon(Icons.question_mark_rounded),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.supportForm,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context)!.supportFormDescription,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant
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
        ],
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