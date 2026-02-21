import 'package:flutter/material.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [
      '#E0E0E0', '#90CAF9', '#42A5F5', 
      '#FF5900', '#EF5350', '#8E24AA',
    ];

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[800]?.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((colorString) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(colorString),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _parseColor(colorString),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      var s = colorString.replaceAll('#', '');
      if (s.length == 6) s = 'FF$s';
      return Color(int.parse(s, radix: 16));
    } catch (_) {
      return Colors.transparent;
    }
  }
}
