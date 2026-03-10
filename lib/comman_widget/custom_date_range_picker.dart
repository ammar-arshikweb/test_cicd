import 'package:flutter/material.dart';
import 'package:panamera_app/l10n/app_localizations.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/helpers.dart';
import 'package:panamera_app/values/colors.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primaryColor;
  final Color rangeHighlightColor;

  const CustomDateRangePicker({
    Key? key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.primaryColor = Colors.green,
    this.rangeHighlightColor = const Color(0xFFB2DFDB),
  }) : super(key: key);

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late AppLocalizations strings;
  late DateTime _focusedMonth;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late PageController _pageController;


  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialDateRange?.start;
    _rangeEnd = widget.initialDateRange?.end;
    _focusedMonth = _rangeStart ?? DateTime.now();

    // Calculate initial page index
    final monthsDiff = (_focusedMonth.year - widget.firstDate.year) * 12 + (_focusedMonth.month - widget.firstDate.month);
    _pageController = PageController(initialPage: monthsDiff);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
        // Start new selection
        _rangeStart = date;
        _rangeEnd = null;
      } else if (date.isBefore(_rangeStart!)) {
        // Selected date is before start, make it the new start
        _rangeStart = date;
      } else {
        // Complete the range
        _rangeEnd = date;
      }
    });
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goToNextMonth() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _selectYear() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return _YearPickerDialog(
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          currentYear: _focusedMonth.year,
          primaryColor: widget.primaryColor,
        );
      },
    );

    if (selectedYear != null) {
      final newDate = DateTime(selectedYear, _focusedMonth.month);
      final monthsDiff = (newDate.year - widget.firstDate.year) * 12 + (newDate.month - widget.firstDate.month);

      _pageController.jumpToPage(monthsDiff);
    }
  }

  @override
  Widget build(BuildContext context) {
    strings = Helper.getLocalization()!;
    return Container(
      constraints: const BoxConstraints(maxWidth: 450, maxHeight: 550),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildDateRangeDisplay(),
          _buildMonthNavigation(),
          _buildWeekdayHeaders(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _focusedMonth = DateTime(widget.firstDate.year + (index ~/ 12), widget.firstDate.month + (index % 12));
                });
              },
              itemBuilder: (context, index) {
                final month = DateTime(widget.firstDate.year + (index ~/ 12), widget.firstDate.month + (index % 12));
                return _buildCalendarGrid(month);
              },
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop())),
          const Text('Select range', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          Text('     '),
        ],
      ),
    );
  }

  Widget _buildDateRangeDisplay() {
    String displayText = '';
    if (_rangeStart != null && _rangeEnd != null) {
      displayText = '${_formatDate(_rangeStart!)} – ${_formatDate(_rangeEnd!)}';
    } else if (_rangeStart != null) {
      displayText = _formatDate(_rangeStart!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Text(displayText, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final canGoBack = DateTime(_focusedMonth.year, _focusedMonth.month).isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
    final canGoForward = DateTime(_focusedMonth.year, _focusedMonth.month).isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => GlobalTap.safeTap(_selectYear),
            child: Row(
              children: [
                Text(_getMonthYearString(_focusedMonth), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: canGoBack ? () => GlobalTap.safeTap(_goToPreviousMonth) : null,
                color: canGoBack ? Colors.black : Colors.grey,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: canGoForward ? () => GlobalTap.safeTap(_goToNextMonth) : null,
                color: canGoForward ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            weekdays
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Center(child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87))),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final totalCells = ((startingWeekday + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayOffset = index - startingWeekday;
          if (dayOffset < 0 || dayOffset >= daysInMonth) {
            return const SizedBox.shrink();
          }

          final date = DateTime(month.year, month.month, dayOffset + 1);
          final isDisabled = date.isAfter(widget.lastDate) || date.isBefore(widget.firstDate);

          return _buildDayCell(date, isDisabled);
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime date, bool isDisabled) {
    final isStart = _isSameDay(date, _rangeStart);
    final isEnd = _isSameDay(date, _rangeEnd);
    final isInRange = _isInRange(date);
    final isToday = _isSameDay(date, DateTime.now());

    Color? backgroundColor;
    Color? textColor;
    bool isCircle = false;

    if (isDisabled) {
      textColor = Colors.grey[400];
    } else if (isStart || isEnd) {
      backgroundColor = widget.primaryColor;
      textColor = Colors.white;
      isCircle = false;
    } else if (isInRange) {
      backgroundColor = widget.rangeHighlightColor;
      textColor = Colors.black87;
    } else if (isToday) {
      textColor = widget.primaryColor;
    } else {
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => GlobalTap.safeTap(() => _onDateSelected(date)),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(color: textColor, fontWeight: isStart || isEnd || isToday ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => GlobalTap.safeTap(() => Navigator.of(context).pop()),
                child: Center(child: Text(strings.cancel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed:
                    _rangeStart != null && _rangeEnd != null
                        ? () => GlobalTap.safeTap(() {
                          Navigator.of(context).pop(DateTimeRange(start: _rangeStart!, end: _rangeEnd!));
                        })
                        : null,
                child: Text(strings.apply, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return date.isAfter(_rangeStart!) && date.isBefore(_rangeEnd!);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getMonthYearString(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _YearPickerDialog extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final int currentYear;
  final Color primaryColor;

  const _YearPickerDialog({Key? key, required this.firstDate, required this.lastDate, required this.currentYear, required this.primaryColor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final years = List.generate(lastDate.year - firstDate.year + 1, (index) => firstDate.year + index);

    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Year', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => GlobalTap.safeTap(() => Navigator.of(context).pop())),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == currentYear;

                  return InkWell(
                    onTap: () => GlobalTap.safeTap(() => Navigator.of(context).pop(year)),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$year',
                          style: TextStyle(
                            fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? primaryColor : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the date range picker
Future<DateTimeRange?> showCustomDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  DateTime? firstDate,
  DateTime? lastDate,
  Color primaryColor = MColors.primaryGreen,
  Color? rangeHighlightColor,
}) async {
  return await showDialog<DateTimeRange?>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: CustomDateRangePicker(
          initialDateRange: initialDateRange,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime.now(),
          primaryColor: primaryColor,
          rangeHighlightColor: rangeHighlightColor ?? primaryColor.withValues(alpha: 0.3),
        ),
      );
    },
  );
}
