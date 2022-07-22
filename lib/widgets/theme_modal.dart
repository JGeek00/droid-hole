import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_radio.dart';

import 'package:droid_hole/providers/app_config_provider.dart';


class ThemeModal extends StatefulWidget {
  final double statusBarHeight;
  final int selectedTheme;

  const ThemeModal({
    Key? key,
    required this.statusBarHeight,
    required this.selectedTheme,
  }) : super(key: key);

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
        ? mediaQuery.size.height - (widget.statusBarHeight+10)
        : 300,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)!.theme,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
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
                          title: Text(AppLocalizations.of(context)!.systemTheme),
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
                          title: Text(AppLocalizations.of(context)!.light),
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
                          title: Text(AppLocalizations.of(context)!.dark),
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
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  label: Text(AppLocalizations.of(context)!.close),
                  icon: const Icon(Icons.close)
                )
              ],
            ),
          )
        ],
      )
    );
  }
}