import 'package:flutter/material.dart';

import 'package:droid_hole/widgets/servers_list_modal.dart';

class NoServerSelected extends StatelessWidget {
  const NoServerSelected({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    void _selectServer() {
      Future.delayed(const Duration(seconds: 0), () => {
        showModalBottomSheet(
          context: context, 
          builder: (context) => const ServersListModal(),
          backgroundColor: Colors.transparent,
          isDismissible: false,
          enableDrag: false
        )
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height-150 > 300 ? 300 : height-150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.link_off,
                  size: 70,
                  color: Colors.grey,
                ),
                const Text(
                  "No server is selected",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 24
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectServer, 
                  label: const Text("Select a connection"),
                  icon: const Icon(Icons.storage_rounded),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 1.0, 
                      color: Theme.of(context).primaryColor
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}