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
      margin: EdgeInsets.only(
        top: widget.statusBarHeight,
        left: 10,
        bottom: Platform.isIOS ? 30 : 10,
        right: 10
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      height: mediaQuery.size.height >= (Platform.isIOS ? 993 : 973) 
        ? (Platform.isIOS ? 993 : 973) 
        : (Platform.isIOS 
            ? mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight)+20 
            : mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight)+1
          ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  AppLocalizations.of(context)!.logDetails,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _checkUncheckAll,
                  child: ListTile(
                    title: SizedBox(
                      width: 450,
                      child: Text(
                        AppLocalizations.of(context)!.allClientsSelected,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Checkbox(
                      value: _selectedClients.length == filtersProvider.totalClients.length ? true : false, 
                      onChanged: (_) => _checkUncheckAll(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: mediaQuery.size.height >= (Platform.isIOS ? 993 : 973) 
                  ? (Platform.isIOS ? 807 : 787 )
                  : (Platform.isIOS 
                    ? mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight+218)
                    : mediaQuery.size.height-(widget.statusBarHeight+widget.bottomNavBarHeight+198)
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
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.close),
                  label: Text(AppLocalizations.of(context)!.close),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () {
                    updateList();
                    Navigator.pop(context);
                  }, 
                  icon: const Icon(Icons.check), 
                  label: Text(AppLocalizations.of(context)!.apply),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.green),
                    overlayColor: MaterialStateProperty.all(Colors.green.withOpacity(0.1))
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}