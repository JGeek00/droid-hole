import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  final double mainWidth;
  final double innerWidth;
  final IconData icon;
  final Color iconColor;
  final Color color;
  final String label;
  final String value;
  final EdgeInsets margin;

  const HomeTile({
    Key? key,
    required this.mainWidth,
    required this.innerWidth,
    required this.icon, 
    required this.iconColor, 
    required this.color, 
    required this.label, 
    required this.value,
    required this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: mainWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color
      ),
      child: Stack(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 65,
                  color: iconColor,
                ),
              ],
            ),
          ),
          Container(
            width: innerWidth,
            height: 100,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500
                  ),
                )
              ],
            ),
          )
        ] 
      )
    );
  }
}