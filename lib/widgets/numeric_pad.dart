import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:droid_hole/widgets/shake_animation.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class NumericPad extends StatelessWidget {
  final GlobalKey? shakeKey;
  final String code;
  final void Function(String) onInput;
  final bool window;

  const NumericPad({
    Key? key,
    this.shakeKey,
    required this.code,
    required this.onInput,
    required this.window
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget _number(String? value) {
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
                shadowColor: MaterialStateProperty.all(Colors.transparent)
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
                shadowColor: MaterialStateProperty.all(Colors.transparent)
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: height*0.05
          ),
          child: ShakeAnimation(
            key: shakeKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _number(code.isNotEmpty ? code[0] : null),
                const SizedBox(width: 20),
                _number(code.length >= 2 ? code[1] : null),
                const SizedBox(width: 20),
                _number(code.length >= 3 ? code[2] : null),
                const SizedBox(width: 20),
                _number(code.length >= 4 ? code[3] : null),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          height: width <= 700 
            ? height-((height*0.1)+40)-60 
            : height-((height*0.1)+40)-200,
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
        )
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         _numberButton(number: "1"),
        //         const SizedBox(width: 30),
        //         _numberButton(number: "2"),
        //         const SizedBox(width: 30),
        //         _numberButton(number: "3"),
        //       ],
        //     ),
        //     const SizedBox(height: 20),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         _numberButton(number: "4"),
        //         const SizedBox(width: 30),
        //         _numberButton(number: "5"),
        //         const SizedBox(width: 30),
        //         _numberButton(number: "6"),
        //       ],
        //     ),
        //     const SizedBox(height: 20),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         _numberButton(number: "7"),
        //         const SizedBox(width: 30),
        //         _numberButton(number: "8"),
        //          const SizedBox(width: 30),
        //         _numberButton(number: "9"),
        //       ],
        //     ),
        //     const SizedBox(height: 20),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         SizedBox(width: window == false ? ((width-160)/3+10) : 100),
        //         _numberButton(number: "0"),
        //         const SizedBox(width: 30),
        //         _backButton()
        //       ],
        //     ),
        //     const SizedBox(height: 20),
        //   ],
        // )
      ],
    );
  }
}