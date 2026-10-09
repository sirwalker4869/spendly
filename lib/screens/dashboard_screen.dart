import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onEdit;
  final Function(String) onDelete;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double totalExpense = transactions
        .where((tx) => tx.isExpense)
        .fold(0, (sum, item) => sum + item.amount);

    double totalIncome = transactions
        .where((tx) => !tx.isExpense)
        .fold(0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const HeaderSection(),
          const SizedBox(height: 16),
          SummaryCardSection(totalIncome: totalIncome, totalExpense: totalExpense),
          const SizedBox(height: 16),
          RecentTransactionsSection(
            transactions: transactions,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMonthYear = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Column(
          children: [
            const Text(
              'Halo, Andi 👋',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            Row(
              children: [
                Text(
                  currentMonthYear,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172554),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
              ],
            ),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFCCFBF1),
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
        ),
      ],
    );
  }
}

class SummaryCardSection extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const SummaryCardSection({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    double saldo = totalIncome - totalExpense;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF0E7490)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sisa Saldo Bersih',
            style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${saldo.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Color(0xFF059669), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Pemasukan',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${totalIncome.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      )
                    ],
                  ),
                ),
                Container(height: 28, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Color(0xFFE11D48), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Pengeluaran',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${totalExpense.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE123C),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RecentTransactionsSection extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onEdit;
  final Function(String) onDelete;

  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  // 🗓️ Helper untuk memformat tanggal & waktu secara intuitif
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('HH:mm').format(date);

    if (txDate == today) {
      return 'Hari ini • $timeStr';
    } else if (txDate == yesterday) {
      return 'Kemarin • $timeStr';
    } else {
      return '${DateFormat('dd MMM yyyy', 'id_ID').format(date)} • $timeStr';
    }
  }

  void _showEditModal(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddTransactionScreen(
          transactionToEdit: tx,
          onSaveTransaction: onEdit,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              onDelete(id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaksi Terbaru',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...transactions.take(5).map((tx) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: tx.isExpense
                        ? const Color(0xFFFFE4E6)
                        : const Color(0xFFCCFBF1),
                    child: Text(tx.emoji),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  // 🗓️ Subtitle yang menampilkan Kategori, Metode Pembayaran, dan Tanggal Transaksi
                  subtitle: Text(
                    '${tx.category} • ${tx.paymentMethod}\n${_formatDate(tx.date)}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${tx.isExpense ? "-" : "+"} Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tx.isExpense
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF059669),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditModal(context, tx);
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, tx.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}