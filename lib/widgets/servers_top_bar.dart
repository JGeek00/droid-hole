import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'package:droid_hole/widgets/add_server_modal.dart';

import 'package:droid_hole/models/server.dart';

class ServersTopBar extends StatelessWidget {
  const ServersTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    void _openAddServerBottomSheet({Server? server}) async {
      await Future.delayed(const Duration(seconds: 0), (() => {
        showModalBottomSheet(
          context: context, 
          isScrollControlled: true,
          builder: (context) => AddServerModal(server: server),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false,
        )
      }));
    }

    return Container(
      margin: EdgeInsets.only(top: statusBarHeight),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 1
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                splashRadius: 20,
                onPressed: () => {
                  AutoRouter.of(context).pop(true)
                }, 
                icon: const Icon(Icons.arrow_back)
              ),
              const SizedBox(width: 20),
              const Text(
                "Servers",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              )
            ],
          ),
          IconButton(
            splashRadius: 20,
            onPressed: _openAddServerBottomSheet, 
            icon: const Icon(Icons.add)
          )
        ],
      )
    );
  }
}