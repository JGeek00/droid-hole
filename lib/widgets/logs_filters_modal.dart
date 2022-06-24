import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:droid_hole/widgets/status_filters_modal.dart';

import 'package:droid_hole/providers/filters_provider.dart';
import 'package:droid_hole/functions/format.dart';

class LogsFiltersModal extends StatefulWidget {
  final double statusBarHeight;
  final void Function() filterLogs;

  const LogsFiltersModal({
    Key? key,
    required this.statusBarHeight,
    required this.filterLogs,
  }) : super(key: key);

  @override
  State<LogsFiltersModal> createState() => _LogsFiltersModalState();
}

class _LogsFiltersModalState extends State<LogsFiltersModal> {
  @override
  Widget build(BuildContext context) {
    final filtersProvider = Provider.of<FiltersProvider>(context);

    void _openStatusModal() {
      showModalBottomSheet(
        context: context, 
        builder: (context) => StatusFiltersModal(
          statusBarHeight: widget.statusBarHeight,
        ),
        backgroundColor: Colors.transparent,
        isDismissible: true, 
        enableDrag: true,
        isScrollControlled: true,
      );
    }

    String _statusText() {
      switch (filtersProvider.statusSelected.length) {
        case 0:
          return "No items selected";

        case 14:
          return "All items selected";

        default:
          return "${filtersProvider.statusSelected.length} items selected";
      }
    }

    void _selectTime(String time) async {
      DateTime now = DateTime.now();
      DateTime? dateValue = await showDatePicker(
        context: context, 
        initialDate: now, 
        firstDate: DateTime(now.year, now.month-1, now.day), 
        lastDate: now
      );
      if (dateValue != null) {
        TimeOfDay? timeValue = await showTimePicker(
          context: context, 
          initialTime: TimeOfDay.now(),
          helpText: time == 'from'
            ? "Select start time"
            : "Select end time"
        );
        if (timeValue != null) {
          DateTime value = DateTime(
            dateValue.year,
            dateValue.month,
            dateValue.day,
            timeValue.hour,
            timeValue.minute,
            dateValue.second
          );
          if (time == 'from') {
            filtersProvider.setStartTime(value);
          }
          else {
            filtersProvider.setEndTime(value);
          }
        }
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
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectTime('from'),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const Text(
                                      "From:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      filtersProvider.startTime != null 
                                        ? formatTimestamp(filtersProvider.startTime!, "dd/MM/yyyy - HH:mm")
                                        : "Not selected",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            "-",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectTime('to'),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    const Text(
                                      "To:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      filtersProvider.endTime != null 
                                        ? formatTimestamp(filtersProvider.endTime!, "dd/MM/yyyy - HH:mm")
                                        : "Not selected",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
                                style: TextStyle(
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
                      widget.filterLogs();
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