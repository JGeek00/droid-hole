// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/app_logs/app_logs.dart';
import 'package:droid_hole/screens/unlock.dart';
import 'package:droid_hole/widgets/section_label.dart';
import 'package:droid_hole/screens/settings/advanced_settings/reset_modal.dart';
import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:droid_hole/screens/settings/advanced_settings/app_unlock_setup_modal.dart';
import 'package:droid_hole/screens/settings/advanced_settings/enter_passcode_modal.dart';
import 'package:droid_hole/screens/settings/advanced_settings/statistics_visualization_modal.dart';

import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/servers_provider.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/providers/app_config_provider.dart';

class AdvancedOptions extends StatelessWidget {
  const AdvancedOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final topBarHeight = MediaQuery.of(context).viewPadding.top;

    void updateSslCheck(bool newStatus) async {
      final result = await appConfigProvider.setOverrideSslCheck(newStatus);
      if (result == true) {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.restartAppTakeEffect, 
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotUpdateSettings, 
          color: Colors.red
        );
      }
    }

    void updateOneColumnLegend(bool newStatus) async {
      final result = await appConfigProvider.setOneColumnLegend(newStatus);
      if (result == true) {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.settingsUpdatedSuccessfully, 
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotUpdateSettings, 
          color: Colors.red
        );
      }
    }

    void updateUseReducedData(bool newStatus) async {
      final result = await appConfigProvider.setReducedDataCharts(newStatus);
      if (result == true) {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.settingsUpdatedSuccessfully, 
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotUpdateSettings, 
          color: Colors.red
        );
      }
    }

    void updateHideZeroValues(bool newStatus) async {
      final result = await appConfigProvider.setHideZeroValues(newStatus);
      if (result == true) {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.settingsUpdatedSuccessfully, 
          color: Colors.green
        );
      }
      else {
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.cannotUpdateSettings, 
          color: Colors.green
        );
      }
    }

    void deleteApplicationData() async {
      void reset() async {
        final ProcessModal process = ProcessModal(context: context);
        process.open(AppLocalizations.of(context)!.deleting);
        await serversProvider.deleteDbData();
        await appConfigProvider.restoreAppConfig();
        process.close();
        Phoenix.rebirth(context);
      }

      if (appConfigProvider.passCode != null) {
        Navigator.push(context, MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => EnterPasscodeModal(
            onConfirm: () => reset()
          ),
        ));
      }
      else {
        reset();
      }
    }

    void openResetModal() {
      showDialog(
        context: context, 
        builder: (context) => ResetModal(
          onConfirm: deleteApplicationData,
        ),
        useSafeArea: true
      );
    }

    void openAppUnlockModal() {
      void openModal() {
        showModalBottomSheet(
          context: context, 
          builder: (context) => AppUnlockSetupModal(
            topBarHeight: topBarHeight,
            useBiometrics: appConfigProvider.useBiometrics,
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent
        );
      }
      
      if (appConfigProvider.passCode != null) {
        Navigator.push(context, MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => EnterPasscodeModal(
            onConfirm: () => openModal()
          ),
        ));
      }
      else {
        openModal();
      }
    }

    void showStatisticsVisualizationModeSheet() {
      showModalBottomSheet(
        context: context, 
        builder: (context) => StatisticsVisualizationModal(
          statusBarHeight: topBarHeight
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            systemOverlayStyle: systemUiOverlayStyleConfig(context),
            title: Text(AppLocalizations.of(context)!.advancedSetup),
          ),
          body: ListView(
            children: [
              SectionLabel(label: AppLocalizations.of(context)!.security),
              CustomListTile(
                leadingIcon: Icons.lock,
                label: AppLocalizations.of(context)!.dontCheckCertificate,
                description: AppLocalizations.of(context)!.dontCheckCertificateDescription,
                trailing: Switch(
                  value: appConfigProvider.overrideSslCheck, 
                  onChanged: updateSslCheck,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => updateSslCheck(!appConfigProvider.overrideSslCheck),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                )
              ),
              CustomListTile(
                leadingIcon: Icons.fingerprint_rounded,
                label: AppLocalizations.of(context)!.appUnlock,
                description: AppLocalizations.of(context)!.appUnlockDescription,
                onTap: openAppUnlockModal,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                )
              ),
              SectionLabel(label: AppLocalizations.of(context)!.charts),
              CustomListTile(
                leadingIcon: Icons.list,
                label: AppLocalizations.of(context)!.oneColumnLegend,
                description: AppLocalizations.of(context)!.oneColumnLegendDescription,
                onTap: () => updateOneColumnLegend(!appConfigProvider.oneColumnLegend),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                ),
                trailing: Switch(
                  value: appConfigProvider.oneColumnLegend, 
                  onChanged: updateOneColumnLegend,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomListTile(
                leadingIcon: Icons.stacked_line_chart_rounded,
                label: AppLocalizations.of(context)!.reducedDataCharts,
                description: AppLocalizations.of(context)!.reducedDataChartsDescription,
                onTap: () => updateUseReducedData(!appConfigProvider.reducedDataCharts),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                ),
                trailing: Switch(
                  value: appConfigProvider.reducedDataCharts, 
                  onChanged: updateUseReducedData,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomListTile(
                leadingIcon: Icons.exposure_zero_rounded,
                label: AppLocalizations.of(context)!.hideZeroValues,
                description: AppLocalizations.of(context)!.hideZeroValuesDescription,
                onTap: () => updateHideZeroValues(!appConfigProvider.hideZeroValues),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                ),
                trailing: Switch(
                  value: appConfigProvider.hideZeroValues, 
                  onChanged: updateHideZeroValues,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              CustomListTile(
                leadingIcon: Icons.pie_chart_rounded,
                label: AppLocalizations.of(context)!.domainsClientsDataMode,
                description: AppLocalizations.of(context)!.domainsClientsDataModeDescription,
                onTap: showStatisticsVisualizationModeSheet,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                ),
              ),
              SectionLabel(label: AppLocalizations.of(context)!.others),
              CustomListTile(
                leadingIcon: Icons.list,
                label: AppLocalizations.of(context)!.appLogs, 
                description: AppLocalizations.of(context)!.errorsApp,
                onTap: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AppLogs()))
                },
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                )
              ),
              CustomListTile(
                leadingIcon: Icons.delete,
                label: AppLocalizations.of(context)!.resetApplication, 
                description: AppLocalizations.of(context)!.erasesAppData,
                color: Colors.red,
                onTap: openResetModal,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 20,
                  right: 10
                )
              )
            ],
          ),
        ),
        if (appConfigProvider.passCode != null && appConfigProvider.appUnlocked == false) const Unlock()
      ],
    );
  }
}