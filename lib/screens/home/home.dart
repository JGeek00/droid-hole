// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:droid_hole/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/screens/home/home_tile.dart';
import 'package:droid_hole/screens/home/disable_modal.dart';
import 'package:droid_hole/screens/home/home_charts.dart';
import 'package:droid_hole/screens/home/home_appbar.dart';

import 'package:droid_hole/functions/server_management.dart';
import 'package:droid_hole/constants/enums.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late bool isVisible;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    isVisible = true;
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (mounted && isVisible == true) {
          setState(() => isVisible = false);
        }
      } 
      else {
        if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (mounted && isVisible == false) {
            setState(() => isVisible = true);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    Widget tiles() {
      switch (statusProvider.getStatusLoading) {
        case LoadStatus.loading:
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.loadingStats,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case LoadStatus.loaded:
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              runSpacing: 16,
              children: [
                FractionallySizedBox(
                  widthFactor: width > 700 ? 0.25 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: HomeTile(
                      icon: Icons.public, 
                      iconColor: const Color.fromARGB(255, 64, 146, 66), 
                      color: Colors.blue, 
                      label: AppLocalizations.of(context)!.totalQueries, 
                      value: intFormat(statusProvider.getRealtimeStatus!.dnsQueriesToday,Platform.localeName),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: width > 700 ? 0.25 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: HomeTile(
                      icon: Icons.block, 
                      iconColor: const Color.fromARGB(255, 28, 127, 208), 
                      color: Colors.red, 
                      label: AppLocalizations.of(context)!.queriesBlocked, 
                      value: intFormat(statusProvider.getRealtimeStatus!.adsBlockedToday, Platform.localeName),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: width > 700 ? 0.25 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: HomeTile(
                      icon: Icons.pie_chart, 
                      iconColor: const Color.fromARGB(255, 219, 131, 0), 
                      color: Colors.orange, 
                      label: AppLocalizations.of(context)!.percentageBlocked, 
                      value: "${formatPercentage(statusProvider.getRealtimeStatus!.adsPercentageToday, Platform.localeName)}%",
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: width > 700 ? 0.25 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: HomeTile(
                      icon: Icons.list, 
                      iconColor: const Color.fromARGB(255, 211, 58, 47), 
                      color: Colors.green, 
                      label: AppLocalizations.of(context)!.domainsAdlists, 
                      value: intFormat(statusProvider.getRealtimeStatus!.domainsBeingBlocked, Platform.localeName),
                    ),
                  ),
                ),
              ],
            ),
          );

        case LoadStatus.error: 
          return Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.statsNotLoaded,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        default:
          return const SizedBox();
      }
    }

    void enableDisableServer() async {
      if (
        statusProvider.isServerConnected == true &&
        serversProvider.selectedServer != null
      ) {
        if (serversProvider.selectedServer?.enabled == true) {
          if (width > 700) {
            showDialog(
              context: context, 
              builder: (_) => DisableModal(
                onDisable: (time) => disableServer(time, context),
                window: true,
              ),
            );
          }
          else {
            showModalBottomSheet(
              context: context, 
              isScrollControlled: true,
              builder: (_) => DisableModal(
                onDisable: (time) => disableServer(time, context),
                window: false,
              ),
              backgroundColor: Colors.transparent,
              isDismissible: true,
              enableDrag: true,
            );
          }
        }
        else {
          enableServer(context);
        }
      }
    }

    return serversProvider.selectedServer != null ? Stack(
      children: [
        Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: HomeAppBar(innerBoxIsScrolled: innerBoxIsScrolled)
                ),
              ];
            },
            body: SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                builder: (context) => RefreshIndicator(
                  edgeOffset: 70,
                  onRefresh: () async{
                    await refreshServerStatus(context);
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      ),
                      SliverList.list(
                        children: [
                          tiles(),
                          const SizedBox(height: 24),
                          const HomeCharts(),
                          const SizedBox(height: 16),
                        ]
                      )
                    ],
                  ),
                ),
              )
            )
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          bottom: isVisible && statusProvider.getStatusLoading == LoadStatus.loaded ?
            appConfigProvider.showingSnackbar
              ? 70 : 20
            : -70,
          right: 20,
          child: FloatingActionButton(
            onPressed: enableDisableServer,
            child: const Icon(Icons.shield_rounded),
          )
        )
      ],
    ) : const SizedBox();
  }
}