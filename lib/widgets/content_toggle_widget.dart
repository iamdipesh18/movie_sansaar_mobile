import 'package:flutter/material.dart';
import '../models/content_type.dart';

class ContentToggle extends StatelessWidget {
  final ContentType selected;
  final ValueChanged<ContentType> onChanged;

  const ContentToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color selectedBackground =
        isDark ? Colors.redAccent : const Color(0xFF8973B3); // 👈 your purple
    final Color unselectedBackground =
        isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;

    final Color selectedText = Colors.white;
    final Color unselectedText =
        isDark ? Colors.white70 : Colors.black87;

    final Color borderColor =
        isDark ? Colors.white12 : Colors.grey.shade300;

    return SegmentedButton<ContentType>(
      segments: const [
        ButtonSegment(
          value: ContentType.movie,
          label: Text('Movies'),
          icon: Icon(Icons.movie),
        ),
        ButtonSegment(
          value: ContentType.series,
          label: Text('Series'),
          icon: Icon(Icons.tv),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (newSelection) => onChanged(newSelection.first),
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? selectedBackground
              : unselectedBackground;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? selectedText
              : unselectedText;
        }),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return BorderSide(
            color: isSelected ? selectedBackground : borderColor,
            width: isSelected ? 1.5 : 1.2,
          );
        }),
      ),
    );
  }
}
