import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class LaporanScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const LaporanScreen({super.key, required this.transactions});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int _selectedPeriodIndex = 0; // 0: Mingguan, 1: Bulanan, 2: Tahunan
  int _touchedPieIndex = -1;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // 🔍 Filter transaksi berdasarkan periode pilihan
  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    return widget.transactions.where((tx) {
      if (_selectedPeriodIndex == 0) {
        // Mingguan (7 hari terakhir)
        return tx.date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedPeriodIndex == 1) {
        // Bulanan (Bulan ini)
        return tx.date.year == now.year && tx.date.month == now.month;
      } else {
        // Tahunan (Tahun ini)
        return tx.date.year == now.year;
      }
    }).toList();
  }

  double get _totalIncome {
    return _filteredTransactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _totalExpense {
    return _filteredTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // 📊 Mengelompokkan Pengeluaran per Kategori
  Map<String, double> get _expenseByCategory {
    final Map<String, double> categoryMap = {};
    for (var tx in _filteredTransactions.where((t) => t.isExpense)) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }
    return categoryMap;
  }

  @override
  Widget build(BuildContext context) {
    final netSavings = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SELECTOR PERIODE (Mingguan, Bulanan, Tahunan)
            _buildPeriodSelector(),
            const SizedBox(height: 16),

            // 2. KARTU RINGKASAN (Income, Expense, Net)
            _buildSummaryCards(netSavings),
            const SizedBox(height: 20),

            // 3. GRAFIK BATANG PEMASUKAN VS PENGELUARAN
            _buildBarChartSection(),
            const SizedBox(height: 20),

            // 4. GRAFIK PIE CHART DISTRIBUSI PENGELUARAN
            _buildPieChartSection(),
            const SizedBox(height: 20),

            // 5. RINCIAN PENGELUARAN PER KATEGORI
            _buildCategoryBreakdownSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 1: SELECTOR PERIODE ---
  Widget _buildPeriodSelector() {
    final periods = ['Mingguan', 'Bulanan', 'Tahunan'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriodIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    periods[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- WIDGET 2: KARTU RINGKASAN ---
  Widget _buildSummaryCards(double netSavings) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Pemasukan',
                currencyFormat.format(_totalIncome),
                Icons.arrow_downward,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Pengeluaran',
                currencyFormat.format(_totalExpense),
                Icons.arrow_upward,
                Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: netSavings >= 0
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    child: Icon(
                      netSavings >= 0 ? Icons.account_balance_wallet : Icons.warning_amber,
                      color: netSavings >= 0 ? Colors.blue : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selisih (Net Savings)',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        currencyFormat.format(netSavings),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: netSavings >= 0 ? Colors.blue.shade700 : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET 3: GRAFIK BATANG DUAL (Grouped Bar Chart) ---
  Widget _buildBarChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perbandingan Tren',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: [
                  _buildLegendDot(Colors.green, 'Masuk'),
                  const SizedBox(width: 12),
                  _buildLegendDot(Colors.redAccent, 'Keluar'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text('Belum ada data transaksi'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxBarY(),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final type = rodIndex == 0 ? 'Masuk' : 'Keluar';
                            return BarTooltipItem(
                              '$type\n${currencyFormat.format(rod.toY)}',
                              const TextStyle(color: Colors.white, fontSize: 10),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getBottomTitles,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: _generateBarGroups(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Generate data batang berdasarkan 7 interval/sub-periode
  List<BarChartGroupData> _generateBarGroups() {
    List<BarChartGroupData> groups = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime targetDate;
      if (_selectedPeriodIndex == 0) {
        // 7 Hari Terakhir
        targetDate = now.subtract(Duration(days: i));
      } else if (_selectedPeriodIndex == 1) {
        // 7 Sub-rentang Bulan ini (per 4 hari)
        targetDate = now.subtract(Duration(days: i * 4));
      } else {
        // 7 Bulan terakhir
        targetDate = DateTime(now.year, now.month - i, 1);
      }

      double inc = 0;
      double exp = 0;

      for (var tx in _filteredTransactions) {
        bool isSameGroup = false;
        if (_selectedPeriodIndex == 0) {
          isSameGroup = tx.date.year == targetDate.year &&
              tx.date.month == targetDate.month &&
              tx.date.day == targetDate.day;
        } else if (_selectedPeriodIndex == 1) {
          isSameGroup = tx.date.year == targetDate.year &&
              tx.date.month == targetDate.month &&
              (tx.date.day >= targetDate.day && tx.date.day < targetDate.day + 4);
        } else {
          isSameGroup = tx.date.year == targetDate.year && tx.date.month == targetDate.month;
        }

        if (isSameGroup) {
          if (tx.isExpense) {
            exp += tx.amount;
          } else {
            inc += tx.amount;
          }
        }
      }

      groups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: inc,
              color: Colors.green,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: exp,
              color: Colors.redAccent,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold);
    final now = DateTime.now();
    int index = value.toInt();
    String text = '';

    if (_selectedPeriodIndex == 0) {
      final date = now.subtract(Duration(days: 6 - index));
      text = DateFormat('E', 'id_ID').format(date); // Hari (Sn, Sl, Rb)
    } else if (_selectedPeriodIndex == 1) {
      final date = now.subtract(Duration(days: (6 - index) * 4));
      text = DateFormat('dd/MM').format(date);
    } else {
      final date = DateTime(now.year, now.month - (6 - index), 1);
      text = DateFormat('MMM', 'id_ID').format(date);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(text, style: style),
    );
  }

  double _getMaxBarY() {
    double maxVal = 100000;
    for (var group in _generateBarGroups()) {
      for (var rod in group.barRods) {
        if (rod.toY > maxVal) maxVal = rod.toY;
      }
    }
    return maxVal * 1.2;
  }

  // --- WIDGET 4: GRAFIK PIE CHART ---
  Widget _buildPieChartSection() {
    final categoryData = _expenseByCategory;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proporsi Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          categoryData.isEmpty
              ? const SizedBox(
                  height: 150,
                  child: Center(child: Text('Belum ada pengeluaran')),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 160,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedPieIndex = -1;
                                    return;
                                  }
                                  _touchedPieIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                            sections: _generatePieSections(categoryData),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _generatePieLegends(categoryData),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> categoryData) {
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    int i = 0;
    return categoryData.entries.map((entry) {
      final isTouched = i == _touchedPieIndex;
      final fontSize = isTouched ? 14.0 : 10.0;
      final radius = isTouched ? 45.0 : 38.0;
      final percentage = (_totalExpense == 0) ? 0.0 : (entry.value / _totalExpense) * 100;
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _generatePieLegends(Map<String, double> categoryData) {
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    int i = 0;
    return categoryData.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // --- WIDGET 5: RINCIAN PENGELUARAN PER KATEGORI (LIST + PROGRESS BAR) ---
  Widget _buildCategoryBreakdownSection() {
    final categoryData = _expenseByCategory;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Kategori Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          categoryData.isEmpty
              ? const Text('Belum ada data pengeluaran',
                  style: TextStyle(color: Colors.grey, fontSize: 12))
              : Column(
                  children: categoryData.entries.map((entry) {
                    final double percentage =
                        _totalExpense == 0 ? 0 : (entry.value / _totalExpense);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(
                                currencyFormat.format(entry.value),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade100,
                              color: const Color(0xFF10B981),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}