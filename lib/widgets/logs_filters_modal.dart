import 'package:droid_hole/widgets/status_filters_modal.dart';
import 'package:flutter/material.dart';

class LogsFiltersModal extends StatefulWidget {
  final double statusBarHeight;

  const LogsFiltersModal({
    Key? key,
    required this.statusBarHeight,
  }) : super(key: key);

  @override
  State<LogsFiltersModal> createState() => _LogsFiltersModalState();
}

class _LogsFiltersModalState extends State<LogsFiltersModal> {
  List<int> _statusSelected = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    void _openStatusModal() {
      showModalBottomSheet(
        context: context, 
        builder: (context) => StatusFiltersModal(
          statusBarHeight: widget.statusBarHeight,
          statusSelected: _statusSelected,
          updateList: (List<int> list) {
            setState(() => _statusSelected = list);
          },
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true, 
        enableDrag: true,
        isScrollControlled: true,
      );
    }

    String _statusText() {
      switch (_statusSelected.length) {
        case 0:
          return "No items selected";

        case 14:
          return "All items selected";

        default:
          return "${_statusSelected.length} items selected";
      }
    }

    return Container(
      margin: EdgeInsets.only(
        top: widget.statusBarHeight,
        left: 10,
        right: 10,
        bottom: 10
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Filters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Time",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () => {}, 
                            icon: const Icon(Icons.access_time), 
                            label: const Text("Minimum time")
                          ),
                          TextButton.icon(
                            onPressed: () => {}, 
                            icon: const Icon(Icons.access_time), 
                            label: const Text("Maximum time")
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openStatusModal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Status",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _statusText(),
                                style: const TextStyle(
                                  color: Colors.grey
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_right)
                        ],
                      ),
                    ),
                  ),
                )
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
                    label: const Text("Close"),
                  ),
                  TextButton.icon(
                    onPressed: () {
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
            )
          ],
        ),
      ),
    );
  }
}