import 'package:flutter/material.dart';

class CustomRadio extends StatelessWidget {
  final int value;
  final int groupValue;
  final Function(int)? onChange;

  const CustomRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    this.onChange
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: value == groupValue 
              ? Theme.of(context).primaryColor
              : Colors.grey
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Colors.white
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: value == groupValue 
              ? Theme.of(context).primaryColor
              : Colors.white
          ),
        ),
      ],
    );
  }
}