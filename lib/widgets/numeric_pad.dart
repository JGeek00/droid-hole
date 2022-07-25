import 'package:flutter/material.dart';

class NumericPad extends StatefulWidget {
  final void Function(String) onInput;

  const NumericPad({
    Key? key,
    required this.onInput,
  }) : super(key: key);

  @override
  State<NumericPad> createState() => _NumericPadState();
}

class _NumericPadState extends State<NumericPad> {
  String _code = "";

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
          onPressed: _code.length < 4
            ? () {
                String newCode = "$_code$number";
                setState(() => _code = newCode);
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
          onPressed: () => _code.isNotEmpty
            ? () {
                String newCode = _code.substring(0, _code.length - 1);
                setState(() => _code = newCode);
                widget.onInput(newCode);
              }
            : {},
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
      width: width-100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _number(_code.isNotEmpty ? _code[0] : null),
              const SizedBox(width: 20),
              _number(_code.length >= 2 ? _code[1] : null),
              const SizedBox(width: 20),
              _number(_code.length >= 3 ? _code[2] : null),
              const SizedBox(width: 20),
              _number(_code.length >= 4 ? _code[3] : null),
            ],
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