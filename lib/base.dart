// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/navigation_rail.dart';
import 'package:droid_hole/screens/servers/servers.dart';
import 'package:droid_hole/screens/home/home.dart';
import 'package:droid_hole/screens/logs/logs.dart';
import 'package:droid_hole/screens/settings/settings.dart';
import 'package:droid_hole/screens/domains/domains.dart';
import 'package:droid_hole/screens/statistics/statistics.dart';

import 'package:droid_hole/widgets/start_warning_modal.dart';
import 'package:droid_hole/widgets/bottom_nav_bar.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/providers/status_provider.dart';
import 'package:droid_hole/constants/app_screens.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/providers/domains_list_provider.dart';
import 'package:droid_hole/providers/servers_provider.dart';


class Base extends StatefulWidget {
  const Base({super.key}); 

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> with WidgetsBindingObserver {
  final List<Widget> pages = [
    const Home(),
    const Statistics(),
    const Logs(),
    const DomainLists(),
    const Settings()
  ];

  final List<Widget> pagesNotSelected = [
    const ServersPage(isFromBase: true),
    const Settings()
  ];

  void fetchMainData(Server server) async {
    final statusProvider = Provider.of<StatusProvider>(context, listen: false);
    final serversProvider = Provider.of<ServersProvider>(context, listen: false);

    final result = await Future.wait([
      realtimeStatus(server),
      fetchOverTimeData(server)
    ]);

    if (result[0]['result'] == 'success' && result[1]['result'] == 'success') {
      statusProvider.setRealtimeStatus(result[0]['data']);
      statusProvider.setOvertimeData(result[1]['data']);
      serversProvider.updateselectedServerStatus(result[0]['data'].status == 'enabled' ? true : false);

      statusProvider.setOvertimeDataLoadingStatus(1);
      statusProvider.setStatusLoading(LoadStatus.loaded);

      statusProvider.setStartAutoRefresh(true);
      statusProvider.setIsServerConnected(true);
    }
    else {
      statusProvider.setOvertimeDataLoadingStatus(2);
      statusProvider.setStatusLoading(LoadStatus.error);

      statusProvider.setIsServerConnected(false);
    }
  }

  @override
  void initState() {
    final serversProvider = Provider.of<ServersProvider>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appConfigProvider = Provider.of<AppConfigProvider>(context, listen: false);
      if (appConfigProvider.importantInfoReaden == false) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => const ImportantInfoModal()
        );
      }
    });
    
    if (serversProvider.selectedServer != null) {
      fetchMainData(serversProvider.selectedServer!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    final domainsListProvider = Provider.of<DomainsListProvider>(context, listen: false);

    final width = MediaQuery.of(context).size.width;
    final systemGestureInsets = MediaQuery.of(context).systemGestureInsets;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.light
          : Brightness.dark,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
        systemNavigationBarColor: systemGestureInsets.left > 0  // If true gestures navigation
          ? Colors.transparent
          : ElevationOverlay.applySurfaceTint(
              Theme.of(context).colorScheme.surface, 
              Theme.of(context).colorScheme.surfaceTint, 
              3
            ),
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      ),
      child: Scaffold(
        body: width > 900
          ? Row(
            children: [
              CustomNavigationRail(
                screens: serversProvider.selectedServer != null
                  ? appScreens
                  : appScreensNotSelected,
                selectedScreen: serversProvider.selectedServer != null
                  ? appConfigProvider.selectedTab
                  : appConfigProvider.selectedTab > 1 ? 0 : appConfigProvider.selectedTab,
                onChange: (selected) {
                  if (selected != 3) {
                    domainsListProvider.setSelectedTab(null);
                  }
                  appConfigProvider.setSelectedTab(selected);
                },
              ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (
                    (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
                      animation: primaryAnimation, 
                      secondaryAnimation: secondaryAnimation,
                      child: child,
                    )
                  ),
                  child: serversProvider.selectedServer != null
                    ? pages[appConfigProvider.selectedTab]
                    : pagesNotSelected[appConfigProvider.selectedTab > 1 ? 0 : appConfigProvider.selectedTab]
                ),
              ),
            ],
          ) : PageTransitionSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (
            (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
              animation: primaryAnimation, 
              secondaryAnimation: secondaryAnimation,
              child: child,
            )
          ),
          child: serversProvider.selectedServer != null
            ? pages[appConfigProvider.selectedTab]
            : pagesNotSelected[appConfigProvider.selectedTab > 1 ? 0 : appConfigProvider.selectedTab]
        ),
        bottomNavigationBar: width <= 900 ? BottomNavBar(
          screens: serversProvider.selectedServer != null
            ? appScreens
            : appScreensNotSelected,
          selectedScreen: serversProvider.selectedServer != null
            ? appConfigProvider.selectedTab
            : appConfigProvider.selectedTab > 1 ? 0 : appConfigProvider.selectedTab,
          onChange: (selected) {
            if (selected != 3) {
              domainsListProvider.setSelectedTab(null);
            }
            appConfigProvider.setSelectedTab(selected);
          },
        ) : null,
      ),
    );
  }
}