import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_radio.dart';

import 'package:droid_hole/providers/app_config_provider.dart';


class ThemeModal extends StatefulWidget {
  final double statusBarHeight;
  final int selectedTheme;

  const ThemeModal({
    super.key,
    required this.statusBarHeight,
    required this.selectedTheme,
  });

  @override
  State<ThemeModal> createState() => _ThemeModalState();
}

class _ThemeModalState extends State<ThemeModal> {
  int _selectedItem = 0;

  @override
  void initState() {
    _selectedItem = widget.selectedTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.orientation == Orientation.landscape
        ? mediaQuery.size.height - (widget.statusBarHeight)
        : Platform.isIOS ? 430 : 410,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Icon(
              Icons.light_mode_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 24
            ),
            child: Text(
              AppLocalizations.of(context)!.theme,
              style: const TextStyle(
                fontSize: 24
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedItem = 0);
                        appConfigProvider.setSelectedTheme(0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListTile(
                          leading: const Icon(Icons.phone_android_rounded),
                          title: Text(
                            AppLocalizations.of(context)!.systemTheme,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal
                            ),
                          ),
                          trailing: CustomRadio(
                            value: 0, 
                            groupValue: _selectedItem,
                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedItem = 1);
                        appConfigProvider.setSelectedTheme(1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListTile(
                          leading: const Icon(Icons.light_mode_rounded),
                          title: Text(
                            AppLocalizations.of(context)!.light,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal
                            ),
                          ),
                          trailing: CustomRadio(
                            value: 1, 
                            groupValue: _selectedItem,
                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedItem = 2);
                        appConfigProvider.setSelectedTheme(2);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListTile(
                          leading: const Icon(Icons.dark_mode_rounded),
                          title: Text(
                            AppLocalizations.of(context)!.dark,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal
                            ),
                          ),
                          trailing: CustomRadio(
                            value: 2, 
                            groupValue: _selectedItem,
                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: Platform.isIOS ? 20 : 0
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: Text(AppLocalizations.of(context)!.close)
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}