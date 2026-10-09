import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onEdit;
  final Function(String) onDelete;

  const RiwayatScreen({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  // Mode Filter: 0 = Semua, 1 = Hari Ini, 2 = Bulan Ini, 3 = Tahun Ini, 4 = Tanggal Spesifik
  int _filterMode = 0;
  DateTime? _customSelectedDate;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // 🔍 Memfilter transaksi sesuai pilihan pengguna
  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();

    return widget.transactions.where((tx) {
      if (_filterMode == 1) {
        // Hari ini
        return tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day;
      } else if (_filterMode == 2) {
        // Bulan ini
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (_filterMode == 3) {
        // Tahun ini
        return tx.date.year == now.year;
      } else if (_filterMode == 4 && _customSelectedDate != null) {
        // Tanggal spesifik pilihan pengguna
        return tx.date.year == _customSelectedDate!.year &&
            tx.date.month == _customSelectedDate!.month &&
            tx.date.day == _customSelectedDate!.day;
      }
      return true; // Mode 0 = Semua Transaksi
    }).toList();
  }

  // 🗓️ Helper Format Tanggal & Waktu Ramah Pengguna
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

  // Pemilih Tanggal Kustom (Date Picker)
  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customSelectedDate = picked;
        _filterMode = 4;
      });
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
          onSaveTransaction: widget.onEdit,
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.onDelete(id);
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
    final displayList = _filteredTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${displayList.length} Transaksi',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔍 FILTER CHIPS (Semua, Hari Ini, Bulan Ini, Tahun Ini, Pilih Tanggal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Hari Ini', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Bulan Ini', 2),
                const SizedBox(width: 8),
                _buildFilterChip('Tahun Ini', 3),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: _filterMode == 4 ? Colors.white : const Color(0xFF10B981),
                  ),
                  label: Text(
                    _filterMode == 4 && _customSelectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_customSelectedDate!)
                        : 'Pilih Tanggal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _filterMode == 4 ? Colors.white : Colors.black87,
                    ),
                  ),
                  backgroundColor:
                      _filterMode == 4 ? const Color(0xFF10B981) : Colors.grey.shade100,
                  onPressed: _pickCustomDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 📋 LIST TRANSAKSI
          displayList.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text(
                        'Tidak ada transaksi pada periode ini',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final tx = displayList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: tx.isExpense
                              ? const Color(0xFFFFE4E6)
                              : const Color(0xFFCCFBF1),
                          child: Text(tx.emoji, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          tx.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        // 🗓️ Subtitle Menampilkan Kategori, Metode, dan Tanggal Transaksi
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${tx.category} • ${tx.paymentMethod}\n${_formatDate(tx.date)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tx.isExpense ? "-" : "+"}${currencyFormat.format(tx.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: tx.isExpense
                                    ? Colors.redAccent
                                    : const Color(0xFF10B981),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditModal(context, tx);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, tx.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Hapus', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
        ],
      ),
    );
  }

  // Helper Widget Filter Chip
  Widget _buildFilterChip(String label, int mode) {
    final isSelected = _filterMode == mode;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981),
      backgroundColor: Colors.grey.shade100,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterMode = mode;
          });
        }
      },
    );
  }
}