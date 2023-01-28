import 'package:flutter/material.dart';

class LogStatus extends StatelessWidget {
  final String status;
  final bool showIcon;

  const LogStatus({
    Key? key,
    required this.status,
    required this.showIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _logStatusWidget({
      required IconData icon, 
      required Color color, 
      required String text
    }) {
      return Row(
        children: showIcon == true
          ? [
              Icon(
                icon,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w400,
                  fontSize: 12
                ),  
              )
            ]
          : [
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13
                ),  
              )
            ]
      );
    }
    
    switch (status) {
        case "1":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (gravity)"
          );

        case "2":
          return _logStatusWidget(
            icon: Icons.verified_user_rounded, 
            color: Colors.green, 
            text: "OK (forwarded)"
          );

        case "3":
          return _logStatusWidget(
            icon: Icons.verified_user_rounded, 
            color: Colors.green, 
            text: "OK (cache)"
          );

        case "4":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (regex blacklist)"
          );

        case "5":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (exact blacklist)"
          );

        case "6":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (external, IP)"
          );

        case "7":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (external, NULL)"
          );

        case "8":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (external, NXRA)"
          );

        case "9":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (gravity, CNAME)"
          );

        case "10":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (regex blacklist, CNAME)"
          );

        case "11":
          return _logStatusWidget(
            icon: Icons.gpp_bad_rounded, 
            color: Colors.red, 
            text: "Blocked (exact blacklist, CNAME)"
          );

        case "12":
          return _logStatusWidget(
            icon: Icons.refresh_rounded, 
            color: Colors.blue, 
            text: "Retried"
          );

        case "13":
          return _logStatusWidget(
            icon: Icons.refresh_rounded, 
            color: Colors.blue, 
            text: "Retried (ignored)"
          );

        case "14":
          return _logStatusWidget(
            icon: Icons.verified_user_rounded, 
            color: Colors.green, 
            text: "OK (already forwarded)"
          );

        case "15":
          return _logStatusWidget(
            icon: Icons.storage_rounded, 
            color: Colors.orange, 
            text: "Database is busy"
          );

        default:
          return _logStatusWidget(
            icon: Icons.shield_rounded, 
            color: Colors.grey, 
            text: "Unknown"
          );
    }
  }
}