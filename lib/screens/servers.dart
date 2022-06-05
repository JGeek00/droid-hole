import 'package:droid_hole/models/server.dart';
import 'package:flutter/material.dart';

class Servers extends StatelessWidget {
  const Servers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    List servers = [
      Server(ipAddress: '192.168.1.100', alias: 'Home', token: '123456'),
      Server(ipAddress: '192.168.1.101', alias: 'Office', token: '123456'),
      Server(ipAddress: '192.168.1.102', alias: 'Other', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
      Server(ipAddress: '192.168.1.103', alias: 'Server', token: '123456'),
    ];
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
          child: ListView.builder(
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
                          const SizedBox(height: 10),
                          Text(
                            servers[index].alias,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic
                            ),
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
          ),
        ),
      ],
    );
  }
}