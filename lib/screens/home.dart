// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/servers_list_modal.dart';
import 'package:droid_hole/widgets/no_data_chart.dart';
import 'package:droid_hole/widgets/queries_last_hours.dart';
import 'package:droid_hole/widgets/clients_last_hours.dart';
import 'package:droid_hole/widgets/no_server_selected.dart';
import 'package:droid_hole/widgets/selected_server_disconnected.dart';

import 'package:droid_hole/constants/colors.dart';
import 'package:droid_hole/config/system_overlay_style.dart';
import 'package:droid_hole/models/overtime_data.dart';
import 'package:droid_hole/services/http_requests.dart';
import 'package:droid_hole/classes/process_modal.dart';
import 'package:droid_hole/functions/snackbar.dart';
import 'package:droid_hole/providers/app_config_provider.dart';
import 'package:droid_hole/functions/refresh_server_status.dart';
import 'package:droid_hole/functions/conversions.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final orientation = MediaQuery.of(context).orientation;

    final List<String> clientsListIps = serversProvider.getRealtimeStatus != null
      ? convertFromMapToList(serversProvider.getRealtimeStatus!.topSources).map(
          (client) {
            final split = client['label'].toString().split('|');
            if (split.length > 1) {
              return split[1];
            }
            else {
              return client['label'].toString();
            }
          }
        ).toList()
      : [];

    Widget _tile({
      required double mainWidth,
      required double innerWidth,
      required IconData icon, 
      required Color iconColor, 
      required Color color, 
      required String label, 
      required String value,
      required EdgeInsets margin,
    }) {
      return Container(
        margin: margin,
        width: mainWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color
        ),
        child: Stack(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 65,
                    color: iconColor,
                  ),
                ],
              ),
            ),
            Container(
              width: innerWidth,
              height: 100,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500
                    ),
                  )
                ],
              ),
            )
          ] 
        )
      );
    }

    Widget _tiles() {
      switch (serversProvider.getStatusLoading) {
        case 0:
          return SizedBox(
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return Column(
            children: !(orientation == Orientation.landscape && height < 1000) 
              ? [
                Row(
                  children: [
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.public, 
                      iconColor: const Color.fromARGB(255, 64, 146, 66), 
                      color: Colors.green, 
                      label: AppLocalizations.of(context)!.totalQueries, 
                      value: intFormat(serversProvider.getRealtimeStatus!.dnsQueriesToday, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 8,
                        bottom: 8
                      )
                    ),
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.block, 
                      iconColor: const Color.fromARGB(255, 28, 127, 208), 
                      color: Colors.blue, 
                      label: AppLocalizations.of(context)!.queriesBlocked, 
                      value: intFormat(serversProvider.getRealtimeStatus!.adsBlockedToday, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 8,
                        right: 20,
                        bottom: 8
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.pie_chart, 
                      iconColor: const Color.fromARGB(255, 219, 131, 0), 
                      color: Colors.orange, 
                      label: AppLocalizations.of(context)!.percentageBlocked, 
                      value: "${formatPercentage(serversProvider.getRealtimeStatus!.adsPercentageToday)}%",
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 20,
                        right: 8,
                        bottom: 20
                      )
                    ),
                    _tile(
                      mainWidth: (width-56)/2,
                      innerWidth: (width-80)/2,
                      icon: Icons.list, 
                      iconColor: const Color.fromARGB(255, 211, 58, 47), 
                      color: Colors.red, 
                      label: AppLocalizations.of(context)!.domainsAdlists, 
                      value: intFormat(serversProvider.getRealtimeStatus!.domainsBeingBlocked, "en_US"),
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 8,
                        right: 20,
                        bottom: 20
                      )
                    ),
                  ],
                )
              ]
            : [
              Row(
                children: [
                  _tile(
                    mainWidth: (width-88)/4,
                      innerWidth: (width-80)/4,
                    icon: Icons.public, 
                    iconColor: const Color.fromARGB(255, 64, 146, 66), 
                    color: Colors.green, 
                    label: AppLocalizations.of(context)!.totalQueries, 
                    value: intFormat(serversProvider.getRealtimeStatus!.dnsQueriesToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.block, 
                    iconColor: const Color.fromARGB(255, 28, 127, 208), 
                    color: Colors.blue, 
                    label: AppLocalizations.of(context)!.queriesBlocked, 
                    value: intFormat(serversProvider.getRealtimeStatus!.adsBlockedToday, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.pie_chart, 
                    iconColor: const Color.fromARGB(255, 219, 131, 0), 
                    color: Colors.orange, 
                    label: AppLocalizations.of(context)!.percentageBlocked, 
                    value: "${formatPercentage(serversProvider.getRealtimeStatus!.adsPercentageToday)}%",
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 8,
                      bottom: 20
                    )
                  ),
                  _tile(
                    mainWidth: (width-88)/4,
                    innerWidth: (width-80)/4,
                    icon: Icons.list, 
                    iconColor: const Color.fromARGB(255, 211, 58, 47), 
                    color: Colors.red, 
                    label: AppLocalizations.of(context)!.domainsAdlists, 
                    value: intFormat(serversProvider.getRealtimeStatus!.domainsBeingBlocked, "en_US"),
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 8,
                      right: 20,
                      bottom: 20
                    )
                  ),
                ],
              )
            ],
          );

        case 2: 
          return SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                SizedBox(height: 50),
                Text(
                  "Stats could not be loaded",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
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

    List<Widget> _generateLegend(List values) {
      List<Widget> _generateRow(int length) {
        Widget _generateItem(int i, int itemsPerRow) {
          Color getColor(Client client, int index) {
            final exists = clientsListIps.indexOf(client.ip);
            if (exists >= 0) {
              return colors[exists];
            }
            else {
              return client.color;
            }
          }
          return Container(
            width: appConfigProvider.oneColumnLegend == true
              ? ((width-60)/itemsPerRow)
              : itemsPerRow == 2 
                ? ((width-60)/itemsPerRow)
                : ((width-100)/itemsPerRow),
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: getColor(serversProvider.getOvertimeData!.clients[i], i)
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    serversProvider.getOvertimeData!.clients[i].ip,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          );
        }

        List<Widget> widgets = [];
        if (appConfigProvider.oneColumnLegend == true) {
          for (var i = 0; i < length; i++) {
            widgets.add(
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _generateItem(i, 1),
                    ],
                  ),
                ],
              )
            );
          }
        }
        else {
          if (!(orientation == Orientation.landscape && height < 1000)) {
            for (var i = 0; i < length; i+=2) {
              widgets.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _generateItem(i, 2),
                        i+1 < length ? _generateItem(i+1, 2) : const SizedBox(),
                      ],
                    ),
                  ],
                )
              );
            }
          }
          else {
            for (var i = 0; i < length; i+=4) {
              widgets.add(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _generateItem(i, 4),
                        i+1 < length ? _generateItem(i+1, 4) : const SizedBox(),
                        i+2 < length ? _generateItem(i+2, 4) : const SizedBox(),
                        i+3 < length ? _generateItem(i+3, 4) : const SizedBox(),
                      ],
                    ),
                  ],
                )
              );
            }
          }
        }
        return widgets;
      }

      if (values.length % 2 == 0) {
        return _generateRow(values.length);
      }
      else {
        return _generateRow(values.length);
      }
    }

    Widget _charts() {
      switch (serversProvider.getOvertimeDataLoadStatus) {
        case 0:
          return SizedBox(
            width: double.maxFinite,
            height: 280,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.loadingCharts,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 22
                  ),
                )
              ],
            ),
          );

        case 1:
          return Column(
            children: [
              serversProvider.getOvertimeDataJson!['domains_over_time'].keys.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(context)!.totalQueries24,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.maxFinite,
                          height: 350,
                          child: QueriesLastHours(
                            data: serversProvider.getOvertimeDataJson!,
                            reducedData: appConfigProvider.reducedDataCharts,
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.blocked)
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.notBlocked)
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : NoDataChart(
                    topLabel: AppLocalizations.of(context)!.totalQueries24,
                  ),
              const SizedBox(height: 20),
              serversProvider.getOvertimeDataJson!['over_time'].keys.length > 0 &&
              serversProvider.getOvertimeDataJson!['clients'].length > 0 
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.clientActivity24,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: ClientsLastHours(
                              realtimeListIps: clientsListIps,
                              data: serversProvider.getOvertimeDataJson!,
                              reducedData: appConfigProvider.reducedDataCharts,
                              hideZeroValues: appConfigProvider.hideZeroValues,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _generateLegend(serversProvider.getOvertimeData!.clients),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                )
                : NoDataChart(
                    topLabel: AppLocalizations.of(context)!.clientActivity24,
                  ),
            ],
          );

        case 2: 
          return SizedBox(
            width: double.maxFinite,
            height: 280,
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
                  AppLocalizations.of(context)!.chartsNotLoaded,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
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

    void _openWebPanel() {
      if (serversProvider.isServerConnected == true) {
        FlutterWebBrowser.openWebPage(
          url: '${serversProvider.selectedServer!.address}/admin/',
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

    void _refresh() async {
      final ProcessModal process = ProcessModal(context: context);
      process.open(AppLocalizations.of(context)!.refreshingData);
      final result = await realtimeStatus(
        serversProvider.selectedServer!,
        serversProvider.phpSessId!
      );
      process.close();
      if (result['result'] == "success") {
        serversProvider.updateselectedServerStatus(
          result['data'].status == 'enabled' ? true : false
        );
        serversProvider.setIsServerConnected(true);
        serversProvider.setRealtimeStatus(result['data']);
      }
      else {
        serversProvider.setIsServerConnected(false);
        if (serversProvider.getStatusLoading == 0) {
          serversProvider.setStatusLoading(2);
        }
        showSnackBar(
          context: context, 
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.notConnectServer, 
          color: Colors.red
        );
      }
    }

    void _changeServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        showModalBottomSheet(
          context: context, 
          builder: (context) => ServersListModal(
            statusBarHeight: statusBarHeight,
          ),
          backgroundColor: Colors.transparent,
          isDismissible: true,
          enableDrag: true,
          isScrollControlled: true
        )
      });
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: systemUiOverlayStyleConfig(context),
        toolbarHeight: 70,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: serversProvider.selectedServer != null 
                ? [
                    Icon(
                      serversProvider.isServerConnected == true 
                        ? serversProvider.selectedServer!.enabled == true 
                          ? Icons.verified_user_rounded
                          : Icons.gpp_bad_rounded
                        : Icons.shield_rounded,
                      size: 30,
                      color: serversProvider.isServerConnected == true 
                        ? serversProvider.selectedServer!.enabled == true
                          ? Colors.green
                          : Colors.red
                        : Colors.grey
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serversProvider.selectedServer!.alias,
                          style: const TextStyle(
                            fontSize: 20
                          ),
                        ),
                        Text(
                          serversProvider.selectedServer!.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14
                          )
                        )
                      ],
                    ),
                  ]
                : [
                  const Icon(
                    Icons.shield,
                    color: Colors.grey,
                    size: 30,
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: width - 128,
                    child: Text(
                      AppLocalizations.of(context)!.noServerSelected,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            splashRadius: 20,
            color: Theme.of(context).dialogBackgroundColor,
            itemBuilder: (context) => 
              serversProvider.selectedServer != null 
                ? serversProvider.isServerConnected == true 
                  ? [
                      PopupMenuItem(
                        onTap: _refresh,
                        child: Row(
                          children: [
                            const Icon(Icons.refresh),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.refresh)
                          ],
                        )
                      ),
                      PopupMenuItem(
                        onTap: _openWebPanel,
                        child: Row(
                          children: [
                            const Icon(Icons.web),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.openWebPanel)
                          ],
                        )
                      ),
                      PopupMenuItem(
                        onTap: _changeServer,
                        child: Row(
                          children: [
                            const Icon(Icons.storage_rounded),
                            const SizedBox(width: 15),
                            Text(AppLocalizations.of(context)!.changeServer)
                          ],
                        )
                      ),
                    ]
                  : [
                    PopupMenuItem(
                      onTap: _refresh,
                      child: Row(
                        children: [
                          const Icon(Icons.refresh_rounded),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.tryReconnect)
                        ],
                      )
                    ),
                    PopupMenuItem(
                      onTap: _changeServer,
                      child: Row(
                        children: [
                          const Icon(Icons.storage_rounded),
                          const SizedBox(width: 15),
                          Text(AppLocalizations.of(context)!.changeServer)
                        ],
                      )
                    ),
                  ]
                : [
                  PopupMenuItem(
                    onTap: _changeServer,
                    child: Row(
                      children: [
                        const Icon(Icons.storage_rounded),
                        const SizedBox(width: 15),
                        Text(AppLocalizations.of(context)!.selectServer)
                      ],
                    )
                  ),
                ]
            )
        ],
      ),
      body: serversProvider.selectedServer != null 
        ? serversProvider.isServerConnected == true 
          ? RefreshIndicator(
              onRefresh: () async {
                await refreshServerStatus(context, serversProvider, appConfigProvider);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _tiles(),
                    _charts(),
                  ],
                )
              ),
            )
          : const Center(
              child: SelectedServerDisconnected()
            )
        : const NoServerSelected()
    );
  }
}