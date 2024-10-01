import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/filters_provider.dart';

class ClientsFiltersModal extends StatefulWidget {
  final double statusBarHeight;
  final double bottomNavBarHeight;
  final List<String> selectedClients;
  final bool window;

  const ClientsFiltersModal({
    Key? key,
    required this.statusBarHeight,
    required this.bottomNavBarHeight,
    required this.selectedClients,
    required this.window
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
            title: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w400
              ),
            ),
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

    Widget content() {
      return Wrap(
        alignment: WrapAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.8
            ),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Icon(
                    Icons.phone_android_rounded,
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
                    AppLocalizations.of(context)!.clients,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24
                    ),
                  ),
                ),
                ...filtersProvider.totalClients.map((e) => _listItem(
                  label: e, 
                  value: e, 
                )),
              ],
            ),
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
                          _selectedClients.isNotEmpty ? Theme.of(context).colorScheme.primary : Colors.grey
                        ),
                        overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.1))
                      ), 
                      child: Text(AppLocalizations.of(context)!.apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (widget.window == true) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500
          ),
          child: content()
        ),
      );
    }
    else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          ),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: SafeArea(
          bottom: true,
          child: content()
        )
      );
    }
  }
}