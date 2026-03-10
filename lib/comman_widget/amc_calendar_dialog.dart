import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panamera_app/utils/constant.dart';
import 'package:panamera_app/values/colors.dart';

/// A custom calendar dialog that color-codes dates based on AMC job types.
/// - Green: Garden only
/// - Blue: Pool only
/// - Half green / half blue (pie): Both garden and pool
class AmcCalendarDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Map<DateTime, Set<int>> dateJobTypes;
  final Set<DateTime> availableDates;
  final String helpText;

  const AmcCalendarDialog({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.dateJobTypes,
    required this.availableDates,
    this.helpText = 'Select Date',
  });

  @override
  State<AmcCalendarDialog> createState() => _AmcCalendarDialogState();
}

class _AmcCalendarDialogState extends State<AmcCalendarDialog> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  static final Color _darkGardenColor = MColors.green.withValues(alpha: 0.6);
  static final Color _darkPoolColor = MColors.blue.withValues(alpha: 0.6);
  static final Color _gardenColor = MColors.green.withValues(alpha: 0.25);
  static final Color _poolColor = MColors.blue.withValues(alpha: 0.25);
  static final Color _gardenColorLight = Color(0xFFD6F2E2);
  static final Color _poolColorLight = Color(0xFFD6E8FF);
  static final List<Color> _notSelectedGradient = [
    MColors.green.withValues(alpha: 0.6),
    MColors.green.withValues(alpha: 0.3),
    MColors.blue.withValues(alpha: 0.3),
    MColors.blue.withValues(alpha: 0.6),
  ];
  static final List<Color> _selectedGradient = [
    MColors.green,
    MColors.green.withValues(alpha: 0.6),
    MColors.blue.withValues(alpha: 0.6),
    MColors.blue,
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime((widget.initialDate ?? widget.lastDate).year, (widget.initialDate ?? widget.lastDate).month);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isAvailable(DateTime day) {
    return widget.availableDates.any((d) => _isSameDay(d, day));
  }

  Set<int>? _getJobTypes(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return widget.dateJobTypes[normalized];
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool get _canGoBack {
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    return prevMonth.isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1));
  }

  bool get _canGoForward {
    return _currentMonth.year < widget.lastDate.year || (_currentMonth.year == widget.lastDate.year && _currentMonth.month < widget.lastDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              widget.helpText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: MColors.primaryGreen),
            ),
            const SizedBox(height: 16),

            // Month navigation
            _buildMonthHeader(), const SizedBox(height: 12),

            // Weekday labels
            _buildWeekdayLabels(), const SizedBox(height: 4),

            // Calendar grid
            _buildCalendarGrid(), const SizedBox(height: 12),

            // Legend
            _buildLegend(), const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: MColors.textDarkGrey, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _selectedDate != null ? () => Navigator.of(context).pop(_selectedDate) : null,
                  child: Text(
                    'OK',
                    style: TextStyle(color: _selectedDate != null ? MColors.primaryGreen : MColors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _canGoBack ? _goToPreviousMonth : null,
          icon: Icon(Icons.chevron_left, color: _canGoBack ? MColors.primaryGreen : MColors.grey.withValues(alpha: 0.4)),
        ),
        Text(DateFormat('MMMM yyyy').format(_currentMonth), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        IconButton(
          onPressed: _canGoForward ? _goToNextMonth : null,
          icon: Icon(Icons.chevron_right, color: _canGoForward ? MColors.primaryGreen : MColors.grey.withValues(alpha: 0.4)),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: MColors.textDarkGrey),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final totalDays = lastDayOfMonth.day;

    // Monday = 1, Sunday = 7
    int startWeekday = firstDayOfMonth.weekday; // 1=Mon .. 7=Sun
    int leadingBlanks = startWeekday - 1;

    final totalCells = leadingBlanks + totalDays;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNum = cellIndex - leadingBlanks + 1;

            if (dayNum < 1 || dayNum > totalDays) {
              return const Expanded(child: SizedBox(height: 44));
            }

            final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
            final available = _isAvailable(date);
            final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, date);
            final jobTypes = _getJobTypes(date);

            return Expanded(child: _buildDayCell(date, dayNum, available, isSelected, jobTypes));
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime date, int dayNum, bool available, bool isSelected, Set<int>? jobTypes) {
    final bool hasGarden = jobTypes?.contains(Constant.VISIT_TYPE_GARDEN) ?? false;
    final bool hasPool = jobTypes?.contains(Constant.VISIT_TYPE_POOL) ?? false;
    final bool hasBoth = hasGarden && hasPool;

    return GestureDetector(
      onTap: available
          ? () {
              setState(() {
                _selectedDate = date;
              });
            }
          : null,
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(1),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background indicator for available dates
            if (available && !isSelected) _buildJobTypeIndicator(hasGarden, hasPool, hasBoth),

            // Selected date indicator
            if (isSelected) _buildSelectedIndicator(hasGarden, hasPool, hasBoth),

            // Day number
            Text(
              '$dayNum',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: available ? FontWeight.w600 : FontWeight.w400,
                color: available
                    ? (isSelected
                          ? MColors.white
                          : (hasGarden || hasPool || hasBoth)
                          ? MColors.black
                          : MColors.black)
                    : MColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDayTextColor(bool hasGarden, bool hasPool, bool hasBoth) {
    if (hasBoth || hasGarden || hasPool) return Colors.white;
    return MColors.black;
  }

  Widget _buildSelectedIndicator(bool hasGarden, bool hasPool, bool hasBoth) {
    if (hasBoth) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: _selectedGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
      );
    } else if (hasGarden) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _darkGardenColor),
      );
    } else if (hasPool) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _darkPoolColor),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: MColors.grey.withValues(alpha: 0.3)),
    );
  }

  Widget _buildJobTypeIndicator(bool hasGarden, bool hasPool, bool hasBoth) {
    if (hasBoth) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: _notSelectedGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
      );
    } else if (hasGarden) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _gardenColorLight),
      );
    } else if (hasPool) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _poolColorLight),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(_gardenColorLight, 'Garden'),
          const SizedBox(width: 16),
          _buildLegendItem(_poolColorLight, 'Pool'),
          const SizedBox(width: 16),
          _buildBothLegendItem(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBothLegendItem() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: _notSelectedGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Both',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.textDarkGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
