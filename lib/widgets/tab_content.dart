import 'package:flutter/material.dart';

import 'package:droid_hole/constants/enums.dart';

class CustomTabContent extends StatelessWidget {
  final Widget Function() loadingGenerator;
  final List<Widget> Function() contentGenerator;
  final Widget Function() errorGenerator;
  final LoadStatus loadStatus;
  final Future<void> Function() onRefresh;

  const CustomTabContent({
    Key? key,
    required this.loadingGenerator,
    required this.contentGenerator,
    required this.errorGenerator,
    required this.loadStatus,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (loadStatus) {
      case LoadStatus.loading:
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (BuildContext context) => CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: loadingGenerator()
                  ),
                )
              ],
            ),
          )
        );
        
        
      case LoadStatus.loaded:
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (BuildContext context) {
              return RefreshIndicator(
                onRefresh: onRefresh,
                edgeOffset: 95,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(contentGenerator())
                    )
                  ],
                ),
              );
            },
          ),
        );

      case LoadStatus.error: 
        return SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (BuildContext context) => CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 95,
                      left: 16,
                      right: 16
                    ),
                    child: errorGenerator()
                  ),
                )
              ],
            ),
          )
        );
       
      default:
        return const SizedBox();
    }
  }
}