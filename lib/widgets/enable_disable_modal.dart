import 'package:flutter/material.dart';

class EnableDisableModal extends StatefulWidget {
  final void Function() onCancel;
  final void Function(int) onConfirm;

  const EnableDisableModal({
    Key? key,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<EnableDisableModal> createState() => _EnableDisableModalState();
}

class _EnableDisableModalState extends State<EnableDisableModal> {
  int? selectedOption;
  TextEditingController customTimeController = TextEditingController();

  void _updateRadioValue(value) {
    setState(() {
      selectedOption = value;
      if (selectedOption != 5) {
        customTimeController.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: mediaQueryData.viewInsets,
      child: Container(
        height: 482,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              "Disable",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: Radio(
                        value: 0, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      title: const Text("30 seconds"),
                      onTap: () => _updateRadioValue(0),
                    ),
                    ListTile(
                      leading: Radio(
                        value: 1, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      title: const Text("1 minute"),
                      onTap: () => _updateRadioValue(1),
                    ),
                    ListTile(
                      leading: Radio(
                        value: 2, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      title: const Text("2 minutes"),
                      onTap: () => _updateRadioValue(2),
                    ),
                    ListTile(
                      leading: Radio(
                        value: 3, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      title: const Text("5 minutes"),
                      onTap: () => _updateRadioValue(3),
                    ),
                    ListTile(
                      leading: Radio(
                        value: 4, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      title: const Text("Indefinitely"),
                      onTap: () => _updateRadioValue(4),
                    ),
                    ListTile(
                      leading: Radio(
                        value: 5, 
                        groupValue: selectedOption, 
                        onChanged: _updateRadioValue
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: customTimeController,
                          autofocus: false,
                          enabled: selectedOption == 5 ? true : false,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Minutes',
                          ),
                        ),
                      ),
                      title: const Text("Custom"),
                      onTap: () => _updateRadioValue(5),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onCancel, 
                  child: Row(
                    children: const [
                      Icon(Icons.cancel),
                      SizedBox(width: 10),
                      Text("Cancel")
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onConfirm(1), 
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_rounded),
                      SizedBox(width: 10),
                      Text("Disable")
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}