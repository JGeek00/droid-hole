import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:droid_hole/models/app_log.dart';


class AppLogDetailsModal extends StatefulWidget {
  final AppLog log;

  const AppLogDetailsModal({
    super.key,
    required this.log
  });

  @override
  State<AppLogDetailsModal> createState() => _AppLogDetailsModalState();
}

class _AppLogDetailsModalState extends State<AppLogDetailsModal> {
  String valueToShow = 'message';

  String generateBody() {
    switch (valueToShow) {
      case 'message':
        return widget.log.message;

      case 'statusCode':
        return widget.log.statusCode != null 
          ? widget.log.statusCode.toString()
          : "[NO STAUS CODE]";

      case 'body':
        return widget.log.resBody != null
          ? widget.log.resBody.toString()
          : "[NO RESPONSE BODY]";

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.description_rounded,
            size: 24,
            color: Theme.of(context).listTileTheme.iconColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.logDetails,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface
            ),
          )
        ],
      ),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Material(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15)
                ),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15)
                  ),
                  onTap: () => setState(() => valueToShow = 'message'),
                  child: AnimatedContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15)
                      ),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                      ),
                      color: valueToShow == 'message'  
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.05)
                    ),
                    child: Text(
                      "Message",
                      style: TextStyle(
                        color: valueToShow == 'message'  
                          ? Colors.white
                          : null
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => valueToShow = 'statusCode'),
                  child: AnimatedContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.primary
                        ),
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      color: valueToShow == 'statusCode'  
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.05)
                    ),
                    child: Text(
                      "Status code",
                      style: TextStyle(
                        color: valueToShow == 'statusCode'  
                          ? Colors.white
                          : null
                      ),
                    ),
                  ),
                ),
              ),
              Material(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)
                ),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)
                  ),
                  onTap: () => setState(() => valueToShow = 'body'),
                  child: AnimatedContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15)
                      ),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                      ),
                      color: valueToShow == 'body'  
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.05)
                    ),
                    child: Text(
                      "Body",
                      style: TextStyle(
                        color: valueToShow == 'body'  
                          ? Colors.white
                          : null
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(generateBody())
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Close")
        )
      ],
    );
  }
}