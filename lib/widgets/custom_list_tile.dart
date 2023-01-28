import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData? leadingIcon;
  final String label;
  final String? description;
  final Color? color;
  final void Function()? onTap;
  final Widget? trailing;
  final EdgeInsets? padding;

  const CustomListTile({
    Key? key,
    this.leadingIcon,
    required this.label,
    this.description,
    this.color,
    this.onTap,
    this.trailing,
    this.padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16
            ),
          width: double.maxFinite,
          child: Row(
            children: [
              if (leadingIcon != null) Row(
                children: [
                  Icon(
                    leadingIcon,
                    color: color ?? Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (description != null) Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          description!,
                          style: TextStyle(
                            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              if (trailing != null) trailing!
            ],
          ),
        ),
      ),
    );
  }
}