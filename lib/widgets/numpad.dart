import 'package:flutter/material.dart';

class NumpadWidget extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  const NumpadWidget({
    super.key,
    required this.onKeyPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 4),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 4),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 4),
        _buildRow(['.', '0', '⌫']),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildKey(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String label) {
    return AspectRatio(
      aspectRatio: 2.5, // Increased from 1.5 to make buttons shorter
      child: ElevatedButton(
        onPressed: () {
          if (label == '⌫') {
            onDeletePressed();
          } else {
            onKeyPressed(label);
          }
        },
        onLongPress: label == '⌫' ? onClearPressed : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Reduced from 24
        ),
      ),
    );
  }
}
