import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddDomainModal extends StatefulWidget {
  final String selectedlist;
  final void Function(Map<String, dynamic>) addDomain;

  const AddDomainModal({
    Key? key,
    required this.selectedlist,
    required this.addDomain,
  }) : super(key: key);

  @override
  State<AddDomainModal> createState() => _AddDomainModalState();
}

class _AddDomainModalState extends State<AddDomainModal> {
  final TextEditingController domainController = TextEditingController();
  String selectedType = '';
  bool wildcard = false;

  @override
  void initState() {
    selectedType = widget.selectedlist;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: 424,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28)
          )
        ),
        child: Column(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.domain_add_rounded,
                    size: 26,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => selectedType = 'whitelist'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 'whitelist', 
                              groupValue: selectedType,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) => setState(() => selectedType = value.toString())
                            ),
                            const SizedBox(width: 5),
                            const Text("Whitelist")
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => selectedType = 'blacklist'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 'blacklist', 
                              groupValue: selectedType,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) => setState(() => selectedType = value.toString())
                            ),
                            const SizedBox(width: 5),
                            const Text("Blacklist")
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: domainController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.domain_rounded),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10)
                          )
                        ),
                        labelText: AppLocalizations.of(context)!.domain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.addAsWildcard,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    value: wildcard, 
                    onChanged: (value) => {
                      setState((() => wildcard = value))
                    },
                    activeColor: Theme.of(context).primaryColor,
                  )
                ],
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
                    onPressed: domainController.text != '' && selectedType != ''
                      ? () {
                          widget.addDomain({
                            'list': selectedType,
                            'domain': domainController.text,
                            'wildcard': wildcard
                          });
                          Navigator.pop(context);
                        } 
                      : null,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(
                        domainController.text != '' && selectedType != ''
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
        ),
      ),
    );
  }
}