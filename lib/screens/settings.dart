// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:droid_hole/screens/servers.dart';
import 'package:droid_hole/widgets/theme_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/settings_top_bar.dart';
import 'package:droid_hole/widgets/legal_modal.dart';
import 'package:droid_hole/widgets/reset_modal.dart';
import 'package:droid_hole/widgets/auto_refresh_time_modal.dart';

import 'package:droid_hole/config/urls.dart';
import 'package:droid_hole/routers/router.gr.dart';
import 'package:droid_hole/models/process_modal.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    Widget _listItem({
      IconData? leadingIcon, 
      required String label, 
      String? description,
      Color? color,
      void Function()? onTap
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 25
            ),
            width: double.maxFinite,
            child: Row(
              children: [
                if (leadingIcon != null) Row(
                  children: [
                    Icon(
                      leadingIcon,
                      color: color,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: color
                      ),
                    ),
                    if (description != null) Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: TextStyle(
                            color: color ?? Colors.grey
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _deleteApplicationData() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.deleting);
      await serversProvider.deleteDbData();
      await appConfigProvider.restoreAppConfig();
      process.close();
      Phoenix.rebirth(context);
    }

    void _openResetModal() {
      showDialog(
        context: context, 
        builder: (context) => ResetModal(
          onConfirm: _deleteApplicationData,
        ),
        useSafeArea: true
      );
    }

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
        isDismissible: false,
        enableDrag: false,
      );
    }

    void _openLegalModal() {
      showDialog(
        context: context, 
        builder: (context) => const LegalModal(),
        useSafeArea: true
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
      appBar: const PreferredSize(
        preferredSize: Size(double.maxFinite, 120),
        child: SettingsTopBar()
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
                        _listItem(
                          leadingIcon: Icons.light_mode_rounded,
                          label: AppLocalizations.of(context)!.theme, 
                          description: _getThemeString(),
                          onTap: _openThemeModal,
                        ),
                        _listItem(
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
                        _listItem(
                          leadingIcon: Icons.update,
                          label: AppLocalizations.of(context)!.autoRefreshTime, 
                          description: "${appConfigProvider.getAutoRefreshTime.toString()} ${AppLocalizations.of(context)!.seconds}",
                          onTap: _openAutoRefreshTimeModal
                        ),
                        _listItem(
                          leadingIcon: Icons.delete,
                          label: AppLocalizations.of(context)!.resetApplication, 
                          description: AppLocalizations.of(context)!.erasesAppData,
                          color: Colors.red,
                          onTap: _openResetModal
                        )
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
                          _listItem(
                            label: AppLocalizations.of(context)!.legal, 
                            description: AppLocalizations.of(context)!.legalInfo, 
                            onTap: _openLegalModal
                          ),
                          _listItem(
                            label: AppLocalizations.of(context)!.appVersion, 
                            description: appConfigProvider.getAppInfo!.version
                          ),
                          _listItem(
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