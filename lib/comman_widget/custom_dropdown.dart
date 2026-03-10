import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:panamera_app/utils/global_tap.dart';
import 'package:panamera_app/utils/log_utils.dart';
import 'package:panamera_app/values/colors.dart';

class MCustomDropdown<T> extends StatefulWidget {
  final String? label;
  final TextStyle? labelStyle;
  final T? initialItem;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? hintText;
  final Color borderColor;
  final bool enabled;
  final String? disabledText;
  final Widget Function(BuildContext, T, bool, VoidCallback)? listItemBuilder;
  final Widget Function(BuildContext context, T item, bool isSelected)? headerBuilder;
  final bool showSearch;
  final bool extendHintBuilder;

  const MCustomDropdown({
    super.key,
    required this.label,
    required this.labelStyle,
    required this.initialItem,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.borderColor = MColors.grey,
    this.enabled = true,
    this.disabledText,
    this.listItemBuilder,
    this.headerBuilder,
    this.showSearch = true, // default: true
    this.extendHintBuilder = false, // default: true
  });

  @override
  State<MCustomDropdown<T>> createState() => _MCustomDropdownState<T>();
}

class _MCustomDropdownState<T> extends State<MCustomDropdown<T>> {
  bool _isHovered = false;
  bool _isFocused = false;

  Color _getBorderColor(BuildContext context) {
    if (_isFocused) return widget.borderColor;
    if (_isHovered) return widget.borderColor.withValues(alpha: 0.8);
    return widget.borderColor.withValues(alpha: 0.8);
  }

  T? get _validatedInitialItem {
    if (widget.initialItem == null) return null;
    if (widget.items.contains(widget.initialItem)) {
      return widget.initialItem;
    } else {
      assert(() {
        Log.e(' MCustomDropdown: initialItem "${widget.initialItem}" not found in items list. Defaulting to null.');
        return true;
      }());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownDecoration = CustomDropdownDecoration(
      closedSuffixIcon: Icon(Icons.keyboard_arrow_down, color: MColors.black),
      expandedSuffixIcon: SizedBox(height: 12, width: 12, child: Transform.rotate(angle: 3.1416, child: Icon(Icons.keyboard_arrow_down))),
      expandedShadow: [BoxShadow(color: MColors.black.withValues(alpha: 0.5), blurRadius: 4, offset: Offset(0, 2))],
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.normal, color: MColors.black),
      headerStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal, color: MColors.black),
      closedBorder: Border.all(color: _getBorderColor(context)),
      closedBorderRadius: const BorderRadius.all(Radius.circular(8)),
      expandedBorderRadius: const BorderRadius.all(Radius.circular(8)),
      closedFillColor: MColors.white,
      expandedFillColor: Colors.white,
      errorStyle: const TextStyle(color: MColors.red),
      closedErrorBorder: Border.all(color: MColors.red.withValues(alpha: 0.5)),
      searchFieldDecoration: SearchFieldDecoration(
        // constraints: const BoxConstraints(minHeight: Constant.boxHeight, maxHeight: Constant.boxHeight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.black),
        suffixIcon:
            (onTap) => InkWell(
              onTap: () => GlobalTap.safeTap(onTap),
              child: Padding(padding: const EdgeInsets.all(12), child: SizedBox(height: 16, width: 16, child: Icon(Icons.cancel_outlined))),
            ),
        prefixIcon: Padding(padding: const EdgeInsets.all(10), child: SizedBox(height: 16, width: 16, child: Icon(Icons.search))),
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MColors.grey),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(color: MColors.grey, width: 0.5)),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: MColors.grey, width: 1),
        ),
        fillColor: MColors.grey.withAlpha(25),
      ),
    );

    final dropdown =
        widget.showSearch
            ? CustomDropdown<T>.search(
              enabled: widget.enabled,
              hintText: widget.enabled ? widget.hintText ?? '' : widget.disabledText ?? 'NA',
              hintBuilder:
                  (context, item, isSelected) =>
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: widget.extendHintBuilder? 8.0 : 0),
                        child: Text(item, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey, fontWeight: FontWeight.normal)),
                      ),
              closedHeaderPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: dropdownDecoration,
              disabledDecoration: CustomDropdownDisabledDecoration(
                border: Border.all(color: MColors.grey.withValues(alpha: 0.4), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                fillColor: MColors.grey.withValues(alpha: 0.1),
              ),
              initialItem: _validatedInitialItem,
              items: widget.items,
              headerBuilder: widget.headerBuilder,
              listItemBuilder: widget.listItemBuilder,
              excludeSelected: false,
              onChanged: widget.onChanged,
            )
            : CustomDropdown<T>(
              enabled: widget.enabled,
              hintBuilder:
                  (context, item, isSelected) => Text(
                    widget.enabled ? widget.hintText ?? '' : widget.disabledText ?? 'NA',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MColors.grey, fontWeight: FontWeight.normal),
                  ),
              closedHeaderPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: dropdownDecoration,
              disabledDecoration: CustomDropdownDisabledDecoration(
                border: Border.all(color: MColors.grey.withValues(alpha: 0.4), width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                fillColor: MColors.grey.withValues(alpha: 0.1),
              ),
              initialItem: _validatedInitialItem,
              items: widget.items,
              headerBuilder: widget.headerBuilder,
              listItemBuilder: widget.listItemBuilder,
              excludeSelected: false,
              onChanged: widget.onChanged,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: widget.labelStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        SizedBox(
          // height: Constant.boxHeight,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: FocusScope(
              child: Focus(
                onFocusChange: (focus) => setState(() => _isFocused = focus),
                child: dropdown, // uses correct constructor
              ),
            ),
          ),
        ),
      ],
    );
  }
}
