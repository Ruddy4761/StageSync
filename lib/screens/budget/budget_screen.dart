import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../data/app_state.dart';
import '../../models/expense.dart';

class BudgetScreen extends StatefulWidget {
  final AppState appState;
  final String concertId;
  const BudgetScreen(
      {super.key, required this.appState, required this.concertId});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  void _setBudget() {
    final controller = TextEditingController(
      text: _getConcert()?.totalBudget.toStringAsFixed(0) ?? '0',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Total Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: 'e.g., 500000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              widget.appState
                  .setConcertBudget(widget.concertId, amount);
              Navigator.pop(ctx);
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  dynamic _getConcert() {
    try {
      return widget.appState.concerts
          .firstWhere((c) => c.id == widget.concertId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          TextButton.icon(
            onPressed: _setBudget,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Set Budget'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.appState,
        builder: (context, _) {
          final concert = _getConcert();
          if (concert == null) {
            return const Center(child: Text('Concert not found'));
          }

          final expenses =
              widget.appState.getExpensesForConcert(widget.concertId);
          final totalSpent = widget.appState.getTotalSpent(widget.concertId);
          final totalBudget = concert.totalBudget;
          final remaining = totalBudget - totalSpent;
          final spentPercent =
              totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

          // Group expenses by category
          final categoryTotals = <String, double>{};
          for (final e in expenses) {
            categoryTotals[e.category] =
                (categoryTotals[e.category] ?? 0) + e.amount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (totalBudget == 0 && expenses.isEmpty) ...[
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 56,
                          color: AppColors.textMuted.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('No budget set',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text(
                          'Set a budget and start tracking expenses',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _setBudget,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Set Budget'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Chart and stats
                if (totalBudget > 0)
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            sections: [
                              PieChartSectionData(
                                value: totalSpent,
                                color: AppColors.secondary,
                                radius: 25,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: remaining > 0 ? remaining : 0,
                                color: AppColors.surfaceElevated,
                                radius: 20,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(spentPercent * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            const Text('spent',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Summary cards
                Row(
                  children: [
                    _budgetCard('Total', '₹${totalBudget.toStringAsFixed(0)}',
                        AppColors.primary),
                    const SizedBox(width: 8),
                    _budgetCard('Spent', '₹${totalSpent.toStringAsFixed(0)}',
                        AppColors.secondary),
                    const SizedBox(width: 8),
                    _budgetCard(
                        'Left',
                        '₹${remaining.toStringAsFixed(0)}',
                        remaining >= 0
                            ? AppColors.neonGreen
                            : AppColors.neonRed),
                  ],
                ),
                const SizedBox(height: 20),

                // Category breakdown
                if (categoryTotals.isNotEmpty) ...[
                  const Text('By Category',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...categoryTotals.entries.map((entry) {
                    final percent = totalBudget > 0
                        ? (entry.value / totalBudget * 100)
                        : 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (percent / 100).clamp(0.0, 1.0),
                                    backgroundColor: AppColors.surfaceElevated,
                                    valueColor: AlwaysStoppedAnimation(
                                        AppColors.secondary),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${entry.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text('${percent.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addExpense',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addExpense,
            arguments: widget.concertId),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _budgetCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
