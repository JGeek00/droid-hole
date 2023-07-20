import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/providers/filters_provider.dart';

class StatusFiltersModal extends StatefulWidget {
  final double statusBarHeight;
  final double bottomNavBarHeight;
  final List<int> statusSelected;
  final bool window;

  const StatusFiltersModal({
    Key? key,
    required this.statusBarHeight,
    required this.bottomNavBarHeight,
    required this.statusSelected,
    required this.window
  }) : super(key: key);

  @override
  State<StatusFiltersModal> createState() => _StatusFiltersModalState();
}

class _StatusFiltersModalState extends State<StatusFiltersModal> {
  List<int> _statusSelected = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
  ];

  void _updateStatusSelected(int option) {
    if (_statusSelected.contains(option) == true) {
      setState(() {
        _statusSelected = _statusSelected.where((status) => status != option).toList();
      });
    }
    else {
      setState(() {
        _statusSelected.add(option);
      });
    }
  }

  @override
  void initState() {
    setState(() {
      _statusSelected = widget.statusSelected;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filtersProvider = Provider.of<FiltersProvider>(context);

    final mediaQuery = MediaQuery.of(context);

    void updateList() {
      filtersProvider.setStatusSelected(_statusSelected);
    }

    Widget _listItem({
      required IconData icon,
      required String label,
      required int value,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _updateStatusSelected(value),
          child: ListTile(
            leading: Icon(icon),
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
              value: _statusSelected.contains(value), 
              onChanged: (_) => _updateStatusSelected(value)
            ),
          ),
        ),
      );
    }

    void _checkUncheckAll() {
      if (_statusSelected.length < 14) {
        setState(() {
          _statusSelected = [
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
          ];
        });
      }
      else {
        setState(() {
          _statusSelected = [];
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
                    Icons.shield_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        bottom: 24
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.logsStatus,
                        style: const TextStyle(
                          fontSize: 24
                        ),
                      ),
                    ),
                  ],
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (gravity)", 
                  value: 1
                ),
                _listItem(
                  icon: Icons.verified_user_rounded, 
                  label: "OK (forwarded)", 
                  value: 2
                ),
                _listItem(
                  icon: Icons.verified_user_rounded, 
                  label: "OK (cache)", 
                  value: 3
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (regex blacklist", 
                  value: 4
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (exact blacklist)", 
                  value: 5
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (external, IP)", 
                  value: 6
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (external, NULL)", 
                  value: 7
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (external, NXRA)", 
                  value: 8
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (gravity, CNAME)", 
                  value: 9
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (regex blacklist, CNAME)", 
                  value: 10
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "Blocked (exact blacklist, CNAME)", 
                  value: 11
                ),
                _listItem(
                  icon: Icons.refresh_rounded, 
                  label: "Retried", 
                  value: 12
                ),
                _listItem(
                  icon: Icons.refresh_rounded, 
                  label: "Retried (ignored)", 
                  value: 13
                ),
                _listItem(
                  icon: Icons.gpp_bad_rounded, 
                  label: "OK (already forwarded)", 
                  value: 14
                ),
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
                  child: Text(
                    _statusSelected.length == 14 
                      ? AppLocalizations.of(context)!.uncheckAll
                      : AppLocalizations.of(context)!.checkAll
                  )
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
                      onPressed: _statusSelected.isNotEmpty
                        ? () {
                            updateList();
                            Navigator.pop(context);
                          }
                        : null,
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                          _statusSelected.isNotEmpty ? Theme.of(context).colorScheme.primary : Colors.grey
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
        child: content()
      );
    }
  }
}