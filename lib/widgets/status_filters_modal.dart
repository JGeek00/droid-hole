import 'package:flutter/material.dart';

class StatusFiltersModal extends StatefulWidget {
  final double statusBarHeight;
  final List<int> statusSelected;
  final void Function(List<int>) updateList;

  const StatusFiltersModal({
    Key? key,
    required this.statusBarHeight,
    required this.statusSelected,
    required this.updateList,
  }) : super(key: key);

  @override
  State<StatusFiltersModal> createState() => _StatusFiltersModalState();
}

class _StatusFiltersModalState extends State<StatusFiltersModal> {
  List<int> _statusSelected = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
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
    _statusSelected = widget.statusSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

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
            title: Text(label),
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

    return Container(
      margin: EdgeInsets.only(
        top: widget.statusBarHeight,
        left: 10,
        bottom: 10,
        right: 10
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Log details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: mediaQuery.size.height - 165,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (gravity)", 
                    value: 0
                  ),
                  _listItem(
                    icon: Icons.verified_user_rounded, 
                    label: "OK (forwarded)", 
                    value: 1
                  ),
                  _listItem(
                    icon: Icons.verified_user_rounded, 
                    label: "OK (cache)", 
                    value: 2
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (regex blacklist", 
                    value: 3
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (exact blacklist)", 
                    value: 4
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (external, IP)", 
                    value: 5
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (external, NULL)", 
                    value: 6
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (external, NXRA)", 
                    value: 7
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (gravity, CNAME)", 
                    value: 8
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (regex blacklist, CNAME)", 
                    value: 9
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "Blocked (exact blacklist, CNAME)", 
                    value: 10
                  ),
                  _listItem(
                    icon: Icons.refresh_rounded, 
                    label: "Retried", 
                    value: 11
                  ),
                  _listItem(
                    icon: Icons.refresh_rounded, 
                    label: "Retried (ignored)", 
                    value: 12
                  ),
                  _listItem(
                    icon: Icons.gpp_bad_rounded, 
                    label: "OK (already forwarded)", 
                    value: 13
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context), 
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.updateList(_statusSelected);
                    Navigator.pop(context);
                  }, 
                  icon: const Icon(Icons.check), 
                  label: const Text("Apply"),
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