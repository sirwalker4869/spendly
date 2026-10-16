import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart'; // 📦 Import Service Notifikasi Listener
import 'dashboard_screen.dart';
import 'riwayat_screen.dart';
import 'add_transaction_screen.dart';
import 'laporan_screen.dart';
import 'akun_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionsFromStorage();

    // 🚀 AKTIFKAN LISTENER NOTIFIKASI OTOMATIS SAAT APLIKASI DI-START
    NotificationServiceTracker.initializeListener((newTransaction) {
      setState(() {
        _transactions.insert(0, newTransaction); // Masuk ke urutan teratas
      });
      _saveTransactionsToStorage(); // Simpan permanen ke SharedPreferences

      // Tampilkan feedback notifikasi di dalam aplikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-catat: ${newTransaction.title} (Rp ${newTransaction.amount.toInt()})'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  // 📥 LOAD DATA DARI STORAGE HP
  Future<void> _loadTransactionsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('user_transactions');

    if (transactionsJson != null) {
      final List<dynamic> decodedList = json.decode(transactionsJson);
      setState(() {
        _transactions = decodedList.map((item) => Transaction.fromMap(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _transactions = [
          Transaction(
            id: '1',
            title: 'Gaji Bulan Ini',
            category: 'Gaji',
            emoji: '💰',
            amount: 7500000,
            date: DateTime.now(),
            paymentMethod: 'Transfer Bank',
            isExpense: false,
          ),
          Transaction(
            id: '2',
            title: 'Makan siang soto ayam',
            category: 'Makanan',
            emoji: '🍜',
            amount: 35000,
            date: DateTime.now(),
            paymentMethod: 'Tunai',
            isExpense: true,
          ),
        ];
        _isLoading = false;
      });
      _saveTransactionsToStorage();
    }
  }

  // 💾 SIMPAN DATA KE STORAGE HP
  Future<void> _saveTransactionsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _transactions.map((tx) => tx.toMap()).toList(),
    );
    await prefs.setString('user_transactions', encodedData);
  }

  // ➕ TAMBAH TRANSAKSI
  void _addTransaction(Transaction newTx) {
    setState(() {
      _transactions.insert(0, newTx);
      _currentIndex = 0;
    });
    _saveTransactionsToStorage();
  }

  // ✏️ EDIT TRANSAKSI
  void _editTransaction(Transaction updatedTx) {
    setState(() {
      final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
      if (index != -1) {
        _transactions[index] = updatedTx;
      }
    });
    _saveTransactionsToStorage();
  }

  // 🗑️ HAPUS TRANSAKSI
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
    _saveTransactionsToStorage();
  }

  // 📥 HANDLER SAAT DATA BERHASIL DI-IMPORT
  void _handleImportSuccess(List<Transaction> newTransactions) {
    setState(() {
      _transactions = newTransactions;
    });
    _saveTransactionsToStorage();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      );
    }

    final List<Widget> pages = [
      DashboardScreen(
        transactions: _transactions,
        onEdit: _editTransaction,
        onDelete: _deleteTransaction,
      ),
      RiwayatScreen(
        transactions: _transactions,
        onEdit: _editTransaction,
        onDelete: _deleteTransaction,
      ),
      AddTransactionScreen(onSaveTransaction: _addTransaction),
      LaporanScreen(transactions: _transactions),
      AkunScreen(
        transactions: _transactions,
        onImportSuccess: _handleImportSuccess,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Beranda', 0),
            _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Riwayat', 1),
            _buildCenterAddButton(2),
            _buildNavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Laporan', 3),
            _buildNavItem(Icons.person_outline, Icons.person, 'Akun', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF10B981) : Colors.grey;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton(int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 2),
            const Text('Tambah', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}