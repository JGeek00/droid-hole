import 'package:droid_hole/widgets/custom_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class SwitchServerModal extends StatelessWidget {
  final void Function(Server) onServerSelect;

  const SwitchServerModal({
    Key? key,
    required this.onServerSelect
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);    

    return AlertDialog(
      scrollable: true,
      title: Column(
        children: [
          const Icon(
            Icons.storage_rounded,
            size: 24,
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.switchServer)
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: serversProvider.getServersList.length*72,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serversProvider.getServersList.length,
          itemBuilder: (context, index) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                onServerSelect(serversProvider.getServersList[index]);
              },
              child: CustomListTile(
                label:serversProvider.getServersList[index].alias,
                description: serversProvider.getServersList[index].address,
              ),
            ),
          )
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(AppLocalizations.of(context)!.cancel)
            )
          ],
        )
      ],
    );
  }
}