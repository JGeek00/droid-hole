import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:droid_hole/widgets/shake_animation.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class NumericPad extends StatelessWidget {
  final GlobalKey? shakeKey;
  final String code;
  final void Function(String) onInput;

  const NumericPad({
    super.key,
    this.shakeKey,
    required this.code,
    required this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget number(String? value) {
      return SizedBox(
        width: 40,
        height: 40,
        child: value != null
          ? Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          : Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
        )
      );
    }

    Widget gridItem({
      required int number
    }) {
      return Expanded(
        flex: 1,
        child: AspectRatio(
          aspectRatio: 1/1,
          child: Padding(
            padding: EdgeInsets.all(
              width <= 700 
                ? width > height ? height*0.05 : width*0.05
                : 10
            ),
            child: ElevatedButton(
              onPressed: code.length < 4
                ? () {
                    if (appConfigProvider.validVibrator) {
                      Vibration.vibrate(duration: 15, amplitude: 128);
                    }
                    String newCode = "$code$number";
                    onInput(newCode);
                  }
                : () => {},
              style: ButtonStyle(
                shadowColor: WidgetStateProperty.all(Colors.transparent)
              ),
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: height > 700 ? 40 : 25
                ),
              )
            ),
          ),
        ),
      );
    }

    Widget backButton() {
      return Expanded(
        flex: 1,
        child: AspectRatio(
          aspectRatio: 1/1,
          child: Padding(
            padding: EdgeInsets.all(
              width <= 700 
                ? width > height ? height*0.05 : width*0.05
                : 10
            ),
            child: ElevatedButton(
              onPressed: code.isNotEmpty
                ? () {
                    Vibration.vibrate(duration: 10);
                    String newCode = code.substring(0, code.length - 1);
                    onInput(newCode);
                  }
                : () {},
              style: ButtonStyle(
                shadowColor: WidgetStateProperty.all(Colors.transparent)
              ),
              child: Icon(
                Icons.backspace,
                size: height > 700 ? 40 : 25
              )
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: height > 700 ? height*0.05 : height*0.02
            ),
            child: ShakeAnimation(
              key: shakeKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  number(code.isNotEmpty ? code[0] : null),
                  const SizedBox(width: 20),
                  number(code.length >= 2 ? code[1] : null),
                  const SizedBox(width: 20),
                  number(code.length >= 3 ? code[2] : null),
                  const SizedBox(width: 20),
                  number(code.length >= 4 ? code[3] : null),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: height > 700 
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        gridItem(number: 1),
                        gridItem(number: 2),
                        gridItem(number: 3)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        gridItem(number: 4),
                        gridItem(number: 5),
                        gridItem(number: 6)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        gridItem(number: 7),
                        gridItem(number: 8),
                        gridItem(number: 9)
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Expanded(flex: 1, child: SizedBox()),
                        gridItem(number: 0),
                        backButton()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}