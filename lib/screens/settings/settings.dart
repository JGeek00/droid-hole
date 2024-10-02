// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_split_view/flutter_split_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/settings/logs_quantity_load_screen.dart';
import 'package:droid_hole/screens/settings/advanced_settings/advanced_options.dart';
import 'package:droid_hole/screens/settings/theme_screen.dart';
import 'package:droid_hole/screens/settings/auto_refresh_time_screen.dart';
import 'package:droid_hole/screens/servers/servers.dart';
import 'package:droid_hole/screens/settings/contact_me_modal.dart';
import 'package:droid_hole/widgets/start_warning_modal.dart';
import 'package:droid_hole/screens/settings/logs_quantity_load_modal.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/widgets/custom_settings_tile.dart';
import 'package:droid_hole/widgets/section_label.dart';
import 'package:droid_hole/screens/settings/legal_modal.dart';

import 'package:droid_hole/config/urls.dart';
import 'package:droid_hole/functions/open_url.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 900) {
      return SplitView.material(
        hideDivider: true,
        flexWidth: const FlexWidth(mainViewFlexWidth: 1, secondaryViewFlexWidth: 2),
        placeholder: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)!.selectOptionLeftColumn,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant
              ),
            ),
          ),
        ),
        child: const SettingsWidget(),
      );
    }
    else {
      return const SettingsWidget();
    }
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int? selectedScreen;

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    if (width <= 900 && appConfigProvider.selectedSettingsScreen != null) {
      appConfigProvider.setSelectedSettingsScreen(screen: null);
    }

    Widget settingsTile({
      required String title,
      required String subtitle,
      required IconData icon,
      Widget? trailing,
      required Widget screenToNavigate,
      required int thisItem
    }) {
      if (width > 900) {
        return CustomSettingsTile(
          title: title, 
          subtitle: subtitle,
          icon: icon,
          trailing: trailing,
          thisItem: thisItem, 
          selectedItem: selectedScreen,
          onTap: () {
            setState(() => selectedScreen = thisItem);
            SplitView.of(context).setSecondary(screenToNavigate);
          },
        );
      }
      else {
        return CustomListTile(
          label: title,
          description: subtitle,
          leadingIcon: icon,
          trailing: trailing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => screenToNavigate)
            );
          },
        );
      }
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
                appConfigProvider: appConfigProvider,
                label: AppLocalizations.of(context)!.logsPerQueryUpdated,
                color: Colors.green
              );
            }
            else {
              showSnackBar(
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
                    settingsTile(
                      icon: Icons.light_mode_rounded,
                      title: AppLocalizations.of(context)!.theme, 
                      subtitle: getThemeString(),
                      thisItem: 0,
                      screenToNavigate: const ThemeScreen()
                    ),
                    settingsTile(
                      icon: Icons.storage_rounded,
                      title: AppLocalizations.of(context)!.servers, 
                      subtitle: serversProvider.selectedServer != null 
                        ? statusProvider.isServerConnected == true
                          ? "${AppLocalizations.of(context)!.connectedTo} ${serversProvider.selectedServer!.alias}"
                          : AppLocalizations.of(context)!.notConnectServer
                        : AppLocalizations.of(context)!.notSelected,
                      screenToNavigate: const ServersPage(),
                      thisItem: 1
                    ),
                    settingsTile(
                      icon: Icons.update,
                      title: AppLocalizations.of(context)!.autoRefreshTime, 
                      subtitle: "${appConfigProvider.getAutoRefreshTime.toString()} ${AppLocalizations.of(context)!.seconds}",
                      thisItem: 2,
                      screenToNavigate: const AutoRefreshTimeScreen()
                    ),
                    settingsTile(
                      icon: Icons.list_rounded,
                      title: AppLocalizations.of(context)!.logsQuantityPerLoad, 
                      subtitle: "${appConfigProvider.logsPerQuery == 0.5 ? '30' : appConfigProvider.logsPerQuery.toInt()} ${appConfigProvider.logsPerQuery == 0.5 ? AppLocalizations.of(context)!.minutes : AppLocalizations.of(context)!.hours}",
                      thisItem: 3,
                      screenToNavigate: const LogsQuantityLoadScreen()
                    ),
                    settingsTile(
                      icon: Icons.settings,
                      title: AppLocalizations.of(context)!.advancedSetup, 
                      subtitle: AppLocalizations.of(context)!.advancedSetupDescription,
                      screenToNavigate: const AdvancedOptions(),
                      thisItem: 4,
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
                            onPressed: () => openUrl(Urls.playStore), 
                            icon: SvgPicture.asset(
                              'assets/resources/google-play.svg',
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 30,
                              height: 30,
                            ),
                            tooltip: AppLocalizations.of(context)!.visitGooglePlay,
                          ),
                          IconButton(
                            onPressed: () => openUrl(Urls.gitHub), 
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