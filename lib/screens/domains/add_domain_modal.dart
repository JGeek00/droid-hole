import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/widgets/custom_list_tile.dart';

class AddDomainModal extends StatefulWidget {
  final String selectedlist;
  final void Function(Map<String, dynamic>) addDomain;
  final bool window;

  const AddDomainModal({
    super.key,
    required this.selectedlist,
    required this.addDomain,
    required this.window,
  });

  @override
  State<AddDomainModal> createState() => _AddDomainModalState();
}

enum ListType { whitelist, blacklist }

class _AddDomainModalState extends State<AddDomainModal> {
  final TextEditingController domainController = TextEditingController();
  String? domainError; 
  ListType selectedType = ListType.whitelist;
  bool wildcard = false;
  bool allDataValid = false;

  @override
  void initState() {
    selectedType = widget.selectedlist == 'whitelist' 
      ? ListType.whitelist : ListType.blacklist;
    super.initState();
  }

  String getSelectedList() {
    if (selectedType == ListType.whitelist && wildcard == false) {
      return "white";
    }
    else if (selectedType == ListType.whitelist && wildcard == true) {
      return "regex_white";
    }
    if (selectedType == ListType.blacklist && wildcard == false) {
      return "black";
    }
    else if (selectedType == ListType.blacklist && wildcard == true) {
      return "regex_black";
    }
    else {
      return "";
    }
  }

  String applyWildcard() {
    return "(\\.|^)${domainController.text.replaceAll('.', '\\.')}\$";
  }

  void validateDomain(String? value) {
    if (value != null && value != '') {
      final RegExp subrouteRegexp = RegExp(r'^([a-z0-9]+(?:[._-][a-z0-9]+)*)([a-z0-9]+(?:[.-][a-z0-9]+)*\.[a-z]{2,})$');
      if (subrouteRegexp.hasMatch(value) == true) {
        setState(() {
          domainError = null;
        });
      }
      else {
        setState(() {
          domainError = AppLocalizations.of(context)!.invalidDomain;
        });
      }
    }
    else {
      setState(() {
        domainError = null;
      });
    }
    validateAllData();
  }

  void validateAllData() {
    if (
      domainController.text != '' &&
      domainError == null &&
      (selectedType == ListType.blacklist || selectedType == ListType.whitelist)
    ) {
      setState(() {
        allDataValid = true;
      });
    }
    else {
      setState(() {
        allDataValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.domain_add_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          AppLocalizations.of(context)!.addDomain,
                          style: const TextStyle(
                            fontSize: 24
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.maxFinite,
                    child: SegmentedButton<ListType>(
                      segments: const [
                        ButtonSegment(
                          value: ListType.whitelist,
                          label: Text("Whitelist")
                        ),
                        ButtonSegment(
                          value: ListType.blacklist,
                          label: Text("Blacklist")
                        ),
                      ], 
                      selected: <ListType>{selectedType},
                      onSelectionChanged: (value) => setState(() => selectedType = value.first),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: domainController,
                      onChanged: (value) => validateDomain(value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.domain_rounded),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10)
                          )
                        ),
                        labelText: AppLocalizations.of(context)!.domain,
                        errorText: domainError
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(8)),
                  CustomListTile(
                    label: AppLocalizations.of(context)!.addAsWildcard,
                    onTap: () => setState(() => wildcard = !wildcard),
                    trailing: Switch(
                      value: wildcard, 
                      onChanged: (value) => {
                        setState((() => wildcard = value))
                      },
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel)
                ),
                const SizedBox(width: 14),
                TextButton(
                  onPressed: allDataValid == true
                    ? () {
                        widget.addDomain({
                          'list': getSelectedList(),
                          'domain': wildcard == true
                            ? applyWildcard()
                            : domainController.text,
                        });
                        Navigator.pop(context);
                      } 
                    : null,
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(
                      allDataValid == true
                        ? null
                        : Colors.grey
                    )
                  ),
                  child: Text(AppLocalizations.of(context)!.add),
                ),
              ],
            ),
          )
        ],
      );
    }

    if (widget.window == true) {
      return Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content(),
          )
        ),
      );
    }
    else {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28)
            )
          ),
          child: SafeArea(
            bottom: true,
            child: content()
          )
        ),
      );
    }
  }
}