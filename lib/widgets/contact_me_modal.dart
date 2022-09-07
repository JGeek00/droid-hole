import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactMeModal extends StatelessWidget {
  const ContactMeModal({Key? key}) : super(key: key);

  void _openGitHubIsues() {
    FlutterWebBrowser.openWebPage(
      url: 'https://github.com/JGeek00/droid-hole/issues',
      customTabsOptions: const CustomTabsOptions(
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: false,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      )
    );
  }

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
          const Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Icon(
              Icons.contact_page_rounded,
              size: 26,
            ),
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
              onTap: _openGitHubIsues,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 20
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/resources/github.svg',
                      color: Theme.of(context).textTheme.bodyText2!.color,
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "GitHub",
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)!.openIssueGitHub,
                          style: const TextStyle(
                            color: Colors.grey
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
              onTap: _sendEmail,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 20
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_rounded,
                      size: 24,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: width-164,
                          child: Text(
                            AppLocalizations.of(context)!.writeEmail,
                            style: const TextStyle(
                              color: Colors.grey
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