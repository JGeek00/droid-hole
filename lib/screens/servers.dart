import 'package:flutter/material.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: ElevatedButton(
        onPressed: () => Navigator.pop(context), 
        child: Text("BAck")
      )
      ),
    );
  }
}