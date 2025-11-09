import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Pin Pad Widget
///
/// Numeric keypad for PIN entry (0-9 + backspace)
class PinPad extends StatelessWidget {
  final ValueChanged<String> onNumberPressed;
  final VoidCallback onBackspacePressed;

  const PinPad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        // Row 1: 1, 2, 3
        _buildNumberButton('1'),
        _buildNumberButton('2'),
        _buildNumberButton('3'),

        // Row 2: 4, 5, 6
        _buildNumberButton('4'),
        _buildNumberButton('5'),
        _buildNumberButton('6'),

        // Row 3: 7, 8, 9
        _buildNumberButton('7'),
        _buildNumberButton('8'),
        _buildNumberButton('9'),

        // Row 4: empty, 0, backspace
        const SizedBox.shrink(), // Empty space
        _buildNumberButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Builder(
      builder: (context) => Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onNumberPressed(number),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Builder(
      builder: (context) => Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onBackspacePressed,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
