import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../../../core/constants/app_constants.dart';

enum CalcButtonType { number, operator, function, equals }

class CalcButtonData {
  final String label;
  final CalcButtonType type;

  const CalcButtonData(this.label, this.type);
}

class CalculatorButton extends StatefulWidget {
  final CalcButtonData data;
  final bool isWide;

  const CalculatorButton({
    super.key,
    required this.data,
    this.isWide = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    context.read<CalculatorProvider>().onButtonPressed(widget.data.label);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
        _handleTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: double.infinity,
          decoration: _getDecoration(),
          child: Center(
            child: _buildLabel(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.data.type) {
      case CalcButtonType.equals:
        return BoxDecoration(
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case CalcButtonType.operator:
        return BoxDecoration(
          color: const Color(0xFF2D1B69),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        );
      case CalcButtonType.function:
        return BoxDecoration(
          color: const Color(0xFF1C1C26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.borderColor,
            width: 1,
          ),
        );
      case CalcButtonType.number:
      default:
        return BoxDecoration(
          color: const Color(0xFF1C1C21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.borderColor,
            width: 1,
          ),
        );
    }
  }

  Widget _buildLabel() {
    Color textColor;
    double fontSize;
    FontWeight fontWeight;

    switch (widget.data.type) {
      case CalcButtonType.equals:
        textColor = Colors.white;
        fontSize = 28;
        fontWeight = FontWeight.w500;
        break;
      case CalcButtonType.operator:
        textColor = AppConstants.primaryLightColor;
        fontSize = 26;
        fontWeight = FontWeight.w400;
        break;
      case CalcButtonType.function:
        textColor = AppConstants.textSecondary;
        fontSize = 18;
        fontWeight = FontWeight.w500;
        break;
      case CalcButtonType.number:
      default:
        textColor = AppConstants.textPrimary;
        fontSize = 22;
        fontWeight = FontWeight.w400;
        break;
    }

    if (widget.data.label == '⌫') {
      return Icon(
        Icons.backspace_outlined,
        color: AppConstants.textSecondary,
        size: 20,
      );
    }

    return Text(
      widget.data.label,
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1,
      ),
    );
  }
}
