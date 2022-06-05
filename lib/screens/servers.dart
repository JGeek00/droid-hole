import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/models/server.dart';
import 'package:droid_hole/providers/servers_provider.dart';

class Servers extends StatelessWidget {
  const Servers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    List<Server> servers = serversProvider.getServersList;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 15
          ),
          child: Text(
            "PiHole servers",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Expanded(
          child: servers.isNotEmpty ? 
            ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 48,
                          child: Icon(Icons.storage_rounded),
                        ),
                        Column(
                          children: [
                            Text(
                              servers[index].ipAddress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            if (servers[index].alias != null) Column(
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  servers[index].alias!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        IconButton(
                          onPressed: () => {}, 
                          icon: const Icon(Icons.chevron_right)
                        ),
                      ],
                    ),
                  ),
                ),
              )
            )
            : const SizedBox(
                height: double.maxFinite,
                child: Center(
                  child: Text(
                    "No saved servers",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
        ),
      ],
    );
  }
}