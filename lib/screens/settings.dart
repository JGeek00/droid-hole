// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/advanced_options.dart';
import 'package:droid_hole/screens/servers.dart';

import 'package:droid_hole/widgets/logs_quantity_load_modal.dart';
import 'package:droid_hole/widgets/theme_modal.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/widgets/legal_modal.dart';
import 'package:droid_hole/widgets/auto_refresh_time_modal.dart';

import 'package:droid_hole/config/urls.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    void _openAutoRefreshTimeModal() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => AutoRefreshTimeModal(
          time: appConfigProvider.getAutoRefreshTime,
          onChange: (time) async {
            final result = await appConfigProvider.setAutoRefreshTime(time);
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.updateTimeChanged),
                  backgroundColor: Colors.green,
                )
              );
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.cannotChangeUpdateTime),
                  backgroundColor: Colors.red,
                )
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void _openLogsQuantityPerLoad() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => LogsQuantityPerLoadModal(
          time: appConfigProvider.logsPerQuery,
          onChange: (time) async {
            final result = await appConfigProvider.setLogsPerQuery(time);
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.logsPerQueryUpdated),
                  backgroundColor: Colors.green,
                )
              );
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.cantUpdateLogsPerQuery),
                  backgroundColor: Colors.red,
                )
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void _openLegalModal() {
      showDialog(
        context: context, 
        builder: (context) => const LegalModal(),
      );
    }

    void _openThemeModal() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => ThemeModal(
          statusBarHeight: statusBarHeight,
          selectedTheme: appConfigProvider.selectedThemeNumber,
        ),
        backgroundColor: Colors.transparent,
      );
    }

     void _openWeb(String url) {
      if (serversProvider.isServerConnected == true) {
        FlutterWebBrowser.openWebPage(
          url: url,
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
    }

    String _getThemeString() {
      switch (appConfigProvider.selectedThemeNumber) {
        case 0:
          return AppLocalizations.of(context)!.systemTheme;

        case 1:
          return AppLocalizations.of(context)!.light;

        case 2:
          return AppLocalizations.of(context)!.dark;

        default:
          return "";
      }
    }

    return  Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/icon-no-background.png',
              width: 40,
            ),
            const SizedBox(width: 20),
            const Text(
              "DroidHole",
              style: TextStyle(
                fontSize: 24
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor
                        )
                      )
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(25),
                              child: Text(
                                AppLocalizations.of(context)!.settings,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                        CustomListTile(
                          leadingIcon: Icons.light_mode_rounded,
                          label: AppLocalizations.of(context)!.theme, 
                          description: _getThemeString(),
                          onTap: _openThemeModal,
                        ),
                        CustomListTile(
                          leadingIcon: Icons.storage_rounded,
                          label: AppLocalizations.of(context)!.servers, 
                          description: serversProvider.selectedServer != null 
                            ? serversProvider.isServerConnected == true
                              ? "${AppLocalizations.of(context)!.connectedTo} ${serversProvider.selectedServer!.alias}"
                              : AppLocalizations.of(context)!.notConnectServer
                            : AppLocalizations.of(context)!.notSelected,
                          onTap: () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ServersPage()
                              ),
                            )
                          }
                        ),
                        CustomListTile(
                          leadingIcon: Icons.update,
                          label: AppLocalizations.of(context)!.autoRefreshTime, 
                          description: "${appConfigProvider.getAutoRefreshTime.toString()} ${AppLocalizations.of(context)!.seconds}",
                          onTap: _openAutoRefreshTimeModal
                        ),
                        CustomListTile(
                          leadingIcon: Icons.list_rounded,
                          label: AppLocalizations.of(context)!.logsQuantityPerLoad, 
                          description: "${appConfigProvider.logsPerQuery == 0.5 ? '30' : appConfigProvider.logsPerQuery.toInt()} ${appConfigProvider.logsPerQuery == 0.5 ? AppLocalizations.of(context)!.minutes : AppLocalizations.of(context)!.hours}",
                          onTap: _openLogsQuantityPerLoad
                        ),
                        CustomListTile(
                          leadingIcon: Icons.settings,
                          label: AppLocalizations.of(context)!.advancedSetup, 
                          description: AppLocalizations.of(context)!.advancedSetupDescription,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdvancedOptions()
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor
                        )
                      )
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(25),
                              child: Text(
                                AppLocalizations.of(context)!.about,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (appConfigProvider.getAppInfo != null) 
                          CustomListTile(
                            label: AppLocalizations.of(context)!.legal, 
                            description: AppLocalizations.of(context)!.legalInfo, 
                            onTap: _openLegalModal
                          ),
                          CustomListTile(
                            label: AppLocalizations.of(context)!.appVersion, 
                            description: appConfigProvider.getAppInfo!.version
                          ),
                          CustomListTile(
                            label: AppLocalizations.of(context)!.createdBy, 
                            description: "JGeek00"
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () => _openWeb(Urls.playStore), 
                                  icon: SvgPicture.asset(
                                    'assets/resources/google-play.svg',
                                    color: Theme.of(context).textTheme.bodyText2!.color,
                                    width: 30,
                                    height: 30,
                                  ),
                                  tooltip: AppLocalizations.of(context)!.visitGooglePlay,
                                ),
                                IconButton(
                                  onPressed: () => _openWeb(Urls.gitHub), 
                                  icon: SvgPicture.asset(
                                    'assets/resources/github.svg',
                                    color: Theme.of(context).textTheme.bodyText2!.color,
                                    width: 30,
                                    height: 30,
                                  ),
                                  tooltip: AppLocalizations.of(context)!.gitHub,
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}