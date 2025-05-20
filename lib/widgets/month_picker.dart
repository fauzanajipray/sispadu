import 'package:flutter/material.dart';
import 'package:sispadu/helpers/helpers.dart';

class MonthPicker extends StatefulWidget {
  const MonthPicker({
    Key? key,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
  }) : super(key: key);

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.selectedDate.year;
  }

  void _incrementYear() {
    setState(() {
      selectedYear++;
    });
  }

  void _decrementYear() {
    setState(() {
      selectedYear--;
    });
  }

  void _selectToday() {
    DateTime today = DateTime.now();
    if (today.isAfter(widget.firstDate) && today.isBefore(widget.lastDate)) {
      setState(() {
        selectedYear = today.year;
      });
      widget.onChanged(today);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
          border: Border(
        top: BorderSide(color: Theme.of(context).dividerColor),
        bottom: BorderSide(color: Theme.of(context).dividerColor),
      )),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _decrementYear,
              ),
              Text(
                '$selectedYear',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _incrementYear,
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                int month = index + 1;
                DateTime date = DateTime(selectedYear, month);

                bool isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month;

                bool isSelectable = date.isAfter(widget.firstDate) &&
                    date.isBefore(widget.lastDate);

                bool isSelected = widget.selectedDate.year == selectedYear &&
                    widget.selectedDate.month == month;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isSelectable
                        ? () {
                            widget.onChanged(date);
                          }
                        : null,
                    splashColor:
                        Theme.of(context).colorScheme.primary.withAlpha(30),
                    highlightColor:
                        Theme.of(context).colorScheme.primary.withAlpha(50),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isSelectable
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24.0),
                        border: isToday
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        formatDateTimeCustom(DateTime(selectedYear, month, 1),
                            format: 'MMMM'),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _selectToday,
              child: const Text('Select Today'),
            ),
          ),
        ],
      ),
    );
  }
}
