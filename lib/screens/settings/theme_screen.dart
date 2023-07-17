import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/custom_radio.dart';

import 'package:droid_hole/providers/app_config_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  int _selectedItem = 0;

  @override
  void initState() {
    _selectedItem = Provider.of<AppConfigProvider>(context, listen: false).selectedThemeNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.theme),
      ),
      body: ListView(
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
    );
  }
}