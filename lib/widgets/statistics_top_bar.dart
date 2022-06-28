import 'package:flutter/material.dart';

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topBarHeight = MediaQuery.of(context).viewPadding.top;
    
    return Container(
      margin: EdgeInsets.only(top: topBarHeight),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12
          )
        )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "Statistics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                )
              ],
            ),
          ),
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(
                icon: Icon(Icons.dns_rounded),
                text: "Queries & servers",
              ),
              Tab(
                icon: Icon(Icons.http_rounded),
                text: "Domains",
              ),
              Tab(
                icon: Icon(Icons.devices_rounded),
                text: "Clients",
              ),
            ]
          )
        ],
      ),
    );
  }
}