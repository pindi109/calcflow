import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';
import '../widgets/display_panel.dart';
import '../widgets/history_panel.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<CalculatorProvider>(
          builder: (context, calc, _) {
            return Column(
              children: [
                _buildTopBar(context),
                if (calc.showHistory)
                  Expanded(child: HistoryPanel())
                else
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: DisplayPanel(),
                        ),
                        Expanded(
                          flex: 6,
                          child: _buildKeypad(),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'CalcFlow',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Consumer<CalculatorProvider>(
                builder: (context, calc, _) {
                  return _TopBarButton(
                    icon: calc.showHistory
                        ? Icons.calculate_outlined
                        : Icons.history_rounded,
                    onPressed: () => calc.toggleHistory(),
                    isActive: calc.showHistory,
                  );
                },
              ),
              const SizedBox(width: 8),
              _TopBarButton(
                icon: Icons.logout_rounded,
                onPressed: () => _showSignOutDialog(context),
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Expanded(
            child: _buildButtonRow([
              const CalcButtonData('AC', CalcButtonType.function),
              const CalcButtonData('+/-', CalcButtonType.function),
              const CalcButtonData('%', CalcButtonType.function),
              const CalcButtonData('÷', CalcButtonType.operator),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildButtonRow([
              const CalcButtonData('7', CalcButtonType.number),
              const CalcButtonData('8', CalcButtonType.number),
              const CalcButtonData('9', CalcButtonType.number),
              const CalcButtonData('×', CalcButtonType.operator),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildButtonRow([
              const CalcButtonData('4', CalcButtonType.number),
              const CalcButtonData('5', CalcButtonType.number),
              const CalcButtonData('6', CalcButtonType.number),
              const CalcButtonData('-', CalcButtonType.operator),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildButtonRow([
              const CalcButtonData('1', CalcButtonType.number),
              const CalcButtonData('2', CalcButtonType.number),
              const CalcButtonData('3', CalcButtonType.number),
              const CalcButtonData('+', CalcButtonType.operator),
            ]),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _buildBottomRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<CalcButtonData> buttons) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key == 0 ? 0 : 5,
              right: entry.key == buttons.length - 1 ? 0 : 5,
            ),
            child: CalculatorButton(data: entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: CalculatorButton(
              data: const CalcButtonData('0', CalcButtonType.number),
              isWide: true,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: CalculatorButton(
              data: const CalcButtonData('.', CalcButtonType.number),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: CalculatorButton(
              data: const CalcButtonData('=', CalcButtonType.equals),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  const _TopBarButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? AppConstants.primaryColor.withOpacity(0.2)
              : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppConstants.primaryColor : AppConstants.borderColor,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppConstants.primaryLightColor : AppConstants.textSecondary,
        ),
      ),
    );
  }
}
