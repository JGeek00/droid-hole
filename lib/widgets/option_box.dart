import 'package:flutter/material.dart';

class OptionBox extends StatelessWidget {
  final Widget child;
  final dynamic optionsValue;
  final dynamic itemValue;
  final void Function(dynamic) onTap;

  const OptionBox({
    super.key,
    required this.child,
    required this.optionsValue,
    required this.itemValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onTap(itemValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: optionsValue == itemValue
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant
            ),
            color: optionsValue == itemValue
              ? Theme.of(context).colorScheme.secondaryContainer
              : Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}