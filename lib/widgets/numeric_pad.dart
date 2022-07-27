import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'package:droid_hole/widgets/shake_animation.dart';

class NumericPad extends StatefulWidget {
  final GlobalKey? shakeKey;
  final String code;
  final void Function(String) onInput;

  const NumericPad({
    Key? key,
    this.shakeKey,
    required this.code,
    required this.onInput,
  }) : super(key: key);

  @override
  State<NumericPad> createState() => _NumericPadState();
}

class _NumericPadState extends State<NumericPad> {
  bool validVibrator = false;

  void checkVibrator() async {
    if (await Vibration.hasCustomVibrationsSupport() != null) {
      validVibrator = true;
    }
    else {
      validVibrator = false;
    }
  }

  @override
  void initState() {
    checkVibrator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget _numberButton({
      required String number
    }) {
      return SizedBox(
        width: (width-160)/3,
        height: height-180 < 426
          ? null
          : (width-160)/3,
        child: ElevatedButton(
          onPressed: widget.code.length < 4
            ? () {
                Vibration.vibrate(duration: 15, amplitude: 128);
                String newCode = "${widget.code}$number";
                widget.onInput(newCode);
              }
            : () => {},
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent)
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: height-180 < 426 ? 20 : 40
            ),
          )
        ),
      );
    }

    Widget _backButton() {
      return SizedBox(
        width: (width-160)/3,
        height: height-180 < 426
          ? null
          : (width-160)/3,
        child: ElevatedButton(
          onPressed: widget.code.isNotEmpty
            ? () {
                Vibration.vibrate(duration: 10);
                String newCode = widget.code.substring(0, widget.code.length - 1);
                widget.onInput(newCode);
              }
            : () {},
          style: ButtonStyle(
            shadowColor: MaterialStateProperty.all(Colors.transparent)
          ),
          child: Icon(
            Icons.backspace,
            size: height-180 < 426 ? 10 : 30
          )
        ),
      );
    }

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
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          : Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
            ),
      );
    }

    return SizedBox(
      height: height-180 < 426
        ? height-100
        : null,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShakeAnimation(
            key: widget.shakeKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _number(widget.code.isNotEmpty ? widget.code[0] : null),
                const SizedBox(width: 20),
                _number(widget.code.length >= 2 ? widget.code[1] : null),
                const SizedBox(width: 20),
                _number(widget.code.length >= 3 ? widget.code[2] : null),
                const SizedBox(width: 20),
                _number(widget.code.length >= 4 ? widget.code[3] : null),
              ],
            ),
          ),
          SizedBox(
            height: height-180 < 426 ? 20 : 50
          ),
          SizedBox(
            height: height-180 < 426
              ? height-160
              : 426,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "1"),
                    const SizedBox(width: 30),
                    _numberButton(number: "2"),
                    const SizedBox(width: 30),
                    _numberButton(number: "3"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "4"),
                    const SizedBox(width: 30),
                    _numberButton(number: "5"),
                    const SizedBox(width: 30),
                    _numberButton(number: "6"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _numberButton(number: "7"),
                    const SizedBox(width: 30),
                    _numberButton(number: "8"),
                    const SizedBox(width: 30),
                    _numberButton(number: "9"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: (width-160)/3),
                    const SizedBox(width: 30),
                    _numberButton(number: "0"),
                    const SizedBox(width: 30),
                    _backButton()
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }
}