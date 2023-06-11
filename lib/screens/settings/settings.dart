// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/settings/advanced_settings/advanced_options.dart';
import 'package:droid_hole/screens/servers/servers.dart';
import 'package:droid_hole/screens/settings/contact_me_modal.dart';
import 'package:droid_hole/widgets/start_warning_modal.dart';
import 'package:droid_hole/screens/settings/logs_quantity_load_modal.dart';
import 'package:droid_hole/screens/settings/theme_modal.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/widgets/section_label.dart';
import 'package:droid_hole/screens/settings/legal_modal.dart';
import 'package:droid_hole/screens/settings/auto_refresh_time_modal.dart';

import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/config/urls.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    void openAutoRefreshTimeModal() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => AutoRefreshTimeModal(
          time: appConfigProvider.getAutoRefreshTime,
          onChange: (time) async {
            final result = await appConfigProvider.setAutoRefreshTime(time);
            if (result == true) {
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.updateTimeChanged,
                color: Colors.green
              );
            }
            else {
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.cannotChangeUpdateTime,
                color: Colors.red
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void openLogsQuantityPerLoad() {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true,
        builder: (context) => LogsQuantityPerLoadModal(
          time: appConfigProvider.logsPerQuery,
          onChange: (time) async {
            final result = await appConfigProvider.setLogsPerQuery(time);
            if (result == true) {
                showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.logsPerQueryUpdated,
                color: Colors.green
              );
            }
            else {
              showSnackBar(
                context: context, 
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.cantUpdateLogsPerQuery,
                color: Colors.green
              );
            }
          },
        ),
        backgroundColor: Colors.transparent,
      );
    }

    void openLegalModal() {
      showDialog(
        context: context, 
        builder: (context) => const LegalModal(),
      );
    }

    void openThemeModal() {
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

     void openWeb(String url) {
      if (statusProvider.isServerConnected == true) {
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

    void openImportantInformationModal() {
      showDialog(
        context: context, 
        builder: (context) => const ImportantInfoModal()
      );
    }

    void openContactModal() {
      showDialog(
        context: context, 
        builder: (context) => const ContactMeModal()
      );
    }

    String getThemeString() {
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

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar.large(
                pinned: true,
                floating: true,
                centerTitle: false,
                forceElevated: innerBoxIsScrolled,
                title: Text(AppLocalizations.of(context)!.settings),
              )
            ),
          ];
        },
        body: SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverList.list(
                  children: [
                    SectionLabel(
                      label: AppLocalizations.of(context)!.appSettings, 
                    ),
                    CustomListTile(
                      leadingIcon: Icons.light_mode_rounded,
                      label: AppLocalizations.of(context)!.theme, 
                      description: getThemeString(),
                      onTap: openThemeModal,
                    ),
                    CustomListTile(
                      leadingIcon: Icons.storage_rounded,
                      label: AppLocalizations.of(context)!.servers, 
                      description: serversProvider.selectedServer != null 
                        ? statusProvider.isServerConnected == true
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
                      onTap: openAutoRefreshTimeModal
                    ),
                    CustomListTile(
                      leadingIcon: Icons.list_rounded,
                      label: AppLocalizations.of(context)!.logsQuantityPerLoad, 
                      description: "${appConfigProvider.logsPerQuery == 0.5 ? '30' : appConfigProvider.logsPerQuery.toInt()} ${appConfigProvider.logsPerQuery == 0.5 ? AppLocalizations.of(context)!.minutes : AppLocalizations.of(context)!.hours}",
                      onTap: openLogsQuantityPerLoad
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
                    SectionLabel(
                      label: AppLocalizations.of(context)!.about, 
                    ),
                    CustomListTile(
                      label: AppLocalizations.of(context)!.importantInformation, 
                      description: AppLocalizations.of(context)!.readIssues, 
                      onTap: openImportantInformationModal
                    ),
                    CustomListTile(
                      label: AppLocalizations.of(context)!.legal, 
                      description: AppLocalizations.of(context)!.legalInfo, 
                      onTap: openLegalModal
                    ),
                    if (appConfigProvider.getAppInfo != null) CustomListTile(
                      label: AppLocalizations.of(context)!.appVersion, 
                      description: appConfigProvider.getAppInfo!.version
                    ),
                    CustomListTile(
                      label: AppLocalizations.of(context)!.contactDeveloper, 
                      description: AppLocalizations.of(context)!.issuesSuggestions, 
                      onTap: openContactModal,
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
                            onPressed: () => openWeb(Urls.playStore), 
                            icon: SvgPicture.asset(
                              'assets/resources/google-play.svg',
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 30,
                              height: 30,
                            ),
                            tooltip: AppLocalizations.of(context)!.visitGooglePlay,
                          ),
                          IconButton(
                            onPressed: () => openWeb(Urls.gitHub), 
                            icon: SvgPicture.asset(
                              'assets/resources/github.svg',
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 30,
                              height: 30,
                            ),
                            tooltip: AppLocalizations.of(context)!.gitHub,
                          ),
                        ],
                      ),
                    )
                  ]
                )
              ],
            ),
          )
        )
      ),
    );
  }
}