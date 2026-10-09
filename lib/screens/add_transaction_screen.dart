import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(Transaction) onSaveTransaction;
  final Transaction? transactionToEdit; // null jika mode tambah

  const AddTransactionScreen({
    super.key,
    required this.onSaveTransaction,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late bool _isExpense;
  late double _amount;
  late String _selectedCategory;
  late String _selectedEmoji;
  late String _paymentMethod;
  late DateTime _selectedDate; // 🗓️ Variabel Penyimpanan Tanggal & Waktu
  late TextEditingController _noteController;
  late TextEditingController _amountController;

  final List<Map<String, String>> _expenseCategories = [
    {'title': 'Makanan', 'emoji': '🍜'},
    {'title': 'Transport', 'emoji': '🚗'},
    {'title': 'Nongkrong', 'emoji': '☕'},
    {'title': 'Belanja', 'emoji': '🛒'},
    {'title': 'Tagihan', 'emoji': '💡'},
    {'title': 'Hiburan', 'emoji': '🎮'},
  ];

  final List<Map<String, String>> _incomeCategories = [
    {'title': 'Gaji', 'emoji': '💰'},
    {'title': 'Bonus', 'emoji': '🎁'},
    {'title': 'Investasi', 'emoji': '📈'},
    {'title': 'Sampingan', 'emoji': '💻'},
    {'title': 'Lainnya', 'emoji': '💵'},
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transactionToEdit;
    _isExpense = tx?.isExpense ?? true;
    _amount = tx?.amount ?? 0;
    _selectedCategory = tx?.category ?? (_isExpense ? 'Makanan' : 'Gaji');
    _selectedEmoji = tx?.emoji ?? (_isExpense ? '🍜' : '💰');
    _paymentMethod = tx?.paymentMethod ?? 'Transfer Bank';
    _selectedDate = tx?.date ?? DateTime.now(); // Default ke tanggal & jam saat ini
    _noteController = TextEditingController(text: tx?.title ?? '');

    // Controller untuk nominal manual input
    _amountController = TextEditingController(
      text: _amount > 0 ? _amount.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 🗓️ Fungsi Membuka Modal Pemilih Tanggal & Jam
  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _isExpense ? Colors.redAccent : const Color(0xFF10B981),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      // Opsional: Memilih Jam setelah memilih Tanggal
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedDate.hour,
          pickedTime?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  // Menambah nominal cepat
  void _addQuickAmount(double val) {
    setState(() {
      _amount += val;
      _amountController.text = _amount.toInt().toString();
    });
  }

  // Reset nominal ke 0
  void _resetAmount() {
    setState(() {
      _amount = 0;
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.transactionToEdit == null ? 'TAMBAH TRANSAKSI' : 'EDIT TRANSAKSI',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
              ),
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Switch Pemasukan / Pengeluaran
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpense = true;
                        _selectedCategory = _expenseCategories.first['title']!;
                        _selectedEmoji = _expenseCategories.first['emoji']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense ? Colors.redAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pengeluaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isExpense ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpense = false;
                        _selectedCategory = _incomeCategories.first['title']!;
                        _selectedEmoji = _incomeCategories.first['emoji']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense ? const Color(0xFF10B981) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Pemasukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_isExpense ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Input Nominal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpense ? 'Nominal Pengeluaran' : 'Nominal Pemasukan',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),

                // TextField Manual Input Nominal
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _isExpense ? Colors.redAccent : const Color(0xFF10B981),
                  ),
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _isExpense ? Colors.redAccent : const Color(0xFF10B981),
                    ),
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _amount > 0
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: _resetAmount,
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amount = double.tryParse(value) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Tombol Tambah Cepat
                const Text('Tambah Cepat:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickAddButton('+10rb', 10000),
                    _quickAddButton('+50rb', 50000),
                    _quickAddButton('+100rb', 100000),
                    _quickAddButton('+500rb', 500000),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🗓️ SECTION PILIH TANGGAL & WAKTU TRANSAKSI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tanggal Transaksi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: _isExpense ? Colors.redAccent : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_calendar, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Kategori
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: currentCategories.length,
                  itemBuilder: (context, index) {
                    final cat = currentCategories[index];
                    final isSelected = _selectedCategory == cat['title'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['title']!;
                          _selectedEmoji = cat['emoji']!;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (_isExpense ? Colors.redAccent : const Color(0xFF10B981))
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['emoji']!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              cat['title']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metode & Catatan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metode Pembayaran / Rekening', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Tunai', 'Transfer Bank', 'QRIS / E-Wallet'].map((method) {
                    final isSelected = _paymentMethod == method;
                    return ChoiceChip(
                      label: Text(method, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0D9488),
                      onSelected: (selected) => setState(() => _paymentMethod = method),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Catatan / Judul Transaksi',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nominal harus lebih dari 0')),
                  );
                  return;
                }

                final tx = Transaction(
                  id: widget.transactionToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _noteController.text.isEmpty ? _selectedCategory : _noteController.text,
                  category: _selectedCategory,
                  emoji: _selectedEmoji,
                  amount: _amount,
                  date: _selectedDate, // 📅 Menggunakan tanggal & jam yang dipilih
                  paymentMethod: _paymentMethod,
                  isExpense: _isExpense,
                );

                widget.onSaveTransaction(tx);
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaksi berhasil disimpan!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  _resetAmount();
                  _noteController.clear();
                  setState(() {
                    _selectedDate = DateTime.now();
                  });
                }
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                widget.transactionToEdit == null ? 'Simpan Transaksi' : 'Update Transaksi',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExpense ? Colors.redAccent : const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _quickAddButton(String label, double value) {
    return ElevatedButton(
      onPressed: () => _addQuickAmount(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF1F5F9),
        foregroundColor: Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}