import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/add_server_fullscreen.dart';

class NoServerSelected extends StatelessWidget {
  const NoServerSelected({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    void _selectServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        Navigator.push(context, MaterialPageRoute(
          fullscreenDialog: true,
          builder: (BuildContext context) => const AddServerFullscreen()
        ))
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height-162 > 300 ? 300 : height-162,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.link_off,
                  size: 70,
                  color: Colors.grey,
                ),
                Text(
                  AppLocalizations.of(context)!.noServerSelected,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectServer, 
                  label: Text(AppLocalizations.of(context)!.selectConnection),
                  icon: const Icon(Icons.storage_rounded),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}