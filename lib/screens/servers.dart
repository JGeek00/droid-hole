import 'package:flutter/material.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.maxFinite, 80),
        child: Container(
          margin: const EdgeInsets.only(top: 25),
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
            children: [
              IconButton(
                splashRadius: 20,
                onPressed: () => {
                  Navigator.pop(context)
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
        )
      )
    );
  }
}