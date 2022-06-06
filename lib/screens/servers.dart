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

    final width = MediaQuery.of(context).size.width;

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
                child: SizedBox(
                  width: width-20,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 48,
                            margin: const EdgeInsets.only(right: 12),
                            child: const Icon(Icons.storage_rounded),
                          ),
                          SizedBox(
                            width: width-156,
                            child: Column(
                              children: [
                                Text(
                                  servers[index].address,
                                  overflow: TextOverflow.ellipsis,
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
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => {}, 
                            icon: const Icon(Icons.chevron_right)
                          ),
                        ],
                      ),
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