import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../../../core/constants/app_constants.dart';

class DisplayPanel extends StatelessWidget {
  const DisplayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        return GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: calc.display));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Copied to clipboard'),
                backgroundColor: AppConstants.surfaceColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppConstants.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ExpressionWidget(expression: calc.expression),
                const SizedBox(height: 8),
                _DisplayValueWidget(
                  display: calc.display,
                  state: calc.state,
                ),
                const SizedBox(height: 12),
                _StatusRow(state: calc.state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpressionWidget extends StatelessWidget {
  final String expression;

  const _ExpressionWidget({required this.expression});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        expression.isEmpty ? ' ' : expression,
        key: ValueKey(expression),
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppConstants.textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DisplayValueWidget extends StatelessWidget {
  final String display;
  final CalculatorState state;

  const _DisplayValueWidget({required this.display, required this.state});

  double get _fontSize {
    if (display.length <= 6) return 72;
    if (display.length <= 9) return 56;
    if (display.length <= 12) return 44;
    return 36;
  }

  Color get _color {
    if (state == CalculatorState.error) return Colors.red.shade400;
    if (state == CalculatorState.hasResult) {
      return AppConstants.primaryLightColor;
    }
    return AppConstants.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        color: _color,
        fontSize: _fontSize,
        fontWeight: FontWeight.w300,
        letterSpacing: -2,
        height: 1.1,
      ),
      child: Text(
        display,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final CalculatorState state;

  const _StatusRow({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state == CalculatorState.idle) {
      return const SizedBox(height: 4);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: state == CalculatorState.hasResult
                ? AppConstants.primaryColor.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: state == CalculatorState.hasResult
                  ? AppConstants.primaryColor.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            state == CalculatorState.hasResult ? 'Result' : 'Error',
            style: TextStyle(
              color: state == CalculatorState.hasResult
                  ? AppConstants.primaryLightColor
                  : Colors.red.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
