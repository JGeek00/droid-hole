import 'package:droid_hole/constants/colors.dart';
import 'package:flutter/material.dart';

class PieChartLegend extends StatelessWidget {
  final Map<String, dynamic> data;
  final String? dataUnit;
  final void Function(String)? onValueTap;
  
  const PieChartLegend({
    Key? key,
    required this.data,
    this.dataUnit,
    this.onValueTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) { 
    final width = MediaQuery.of(context).size.width;

    List<Widget> _generateLegendList(Map<String, dynamic> data) {
      List<Widget> items = [];
      int index = 0;
      data.forEach((key, value) {
        items.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onValueTap != null
                ? () => onValueTap!(key)
                : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: colors[index]
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: width-160,
                          child: Text(
                            key,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 65,
                      child: Text(
                        "${value.toString()}${dataUnit != null ? " $dataUnit" : ''}",
                        textAlign: TextAlign.end,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        index++;
      });
      return items;
    }

    return Column(
      children: _generateLegendList(data),
    );
  }
}