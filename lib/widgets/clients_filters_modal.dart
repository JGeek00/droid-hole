import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/filters_provider.dart';

class ClientsFiltersModal extends StatefulWidget {
  final double statusBarHeight;
  final double bottomNavBarHeight;
  final List<String> selectedClients;

  const ClientsFiltersModal({
    Key? key,
    required this.statusBarHeight,
    required this.bottomNavBarHeight,
    required this.selectedClients,
  }) : super(key: key);

  @override
  State<ClientsFiltersModal> createState() => _ClientsFiltersModalState();
}

class _ClientsFiltersModalState extends State<ClientsFiltersModal> {
  List<String> _selectedClients = [];

  void _updateStatusSelected(String option) {
    if (_selectedClients.contains(option) == true) {
      setState(() {
        _selectedClients = _selectedClients.where((status) => status != option).toList();
      });
    }
    else {
      setState(() {
        _selectedClients.add(option);
      });
    }
  }

  @override
  void initState() {
    setState(() {
      _selectedClients = widget.selectedClients;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    void updateList() {
      filtersProvider.setSelectedClients(_selectedClients);
    }

    Widget _listItem({
      required String label,
      required String value,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _updateStatusSelected(value),
          child: ListTile(
            title: Text(label),
            trailing: Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ),
              value: _selectedClients.contains(value), 
              onChanged: (_) => _updateStatusSelected(value)
            ),
          ),
        ),
      );
    }

    void _checkUncheckAll() {
      if (_selectedClients.length < filtersProvider.totalClients.length) {
        setState(() {
          _selectedClients = filtersProvider.totalClients;
        });
      }
      else {
        setState(() {
          _selectedClients = [];
        });
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      height: mediaQuery.size.height >= (Platform.isIOS ? 993 : 973) 
        ? (Platform.isIOS ? 993 : 973) 
        : mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight)+1,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Icon(
              Icons.phone_android_rounded,
              size: 30,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 20
            ),
            child: Text(
              AppLocalizations.of(context)!.clients,
              style: const TextStyle(
                fontSize: 22
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: mediaQuery.size.height >= (Platform.isIOS ? 1018 : 998) 
                  ? (Platform.isIOS ? 828 : 808)
                  : (Platform.isIOS 
                    ? mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight+247)
                    : mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight+228)
                  ),
                child: ListView.builder(
                  itemCount: filtersProvider.totalClients.length,
                  itemBuilder: (context, index) => _listItem(
                    label: filtersProvider.totalClients[index], 
                    value:filtersProvider.totalClients[index], 
                  )
                )
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _checkUncheckAll, 
                  child: _selectedClients.length == filtersProvider.totalClients.length 
                    ? Text(AppLocalizations.of(context)!.uncheckAll) 
                    : Text(AppLocalizations.of(context)!.checkAll) 
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: _selectedClients.isNotEmpty
                        ? () {
                            updateList();
                            Navigator.pop(context);
                          }
                        : null,
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          _selectedClients.isNotEmpty ? Theme.of(context).primaryColor : Colors.grey
                        ),
                        overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1))
                      ), 
                      child: Text(AppLocalizations.of(context)!.apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}