import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/export_import_services.dart';

class AkunScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(List<Transaction>) onImportSuccess;

  const AkunScreen({
    super.key,
    required this.transactions,
    required this.onImportSuccess,
  });

  void _handleExport(BuildContext context) async {
    try {
      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data transaksi untuk di-export.')),
        );
        return;
      }
      await ExportImportService.exportData(transactions);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengeksport data: $e')),
      );
    }
  }

  void _handleImport(BuildContext context) async {
    try {
      final importedList = await ExportImportService.importData();
      if (importedList != null) {
        onImportSuccess(importedList);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengimpor ${importedList.length} transaksi!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format file salah atau terdistorsi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan & Cadangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Card Backup & Restore
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadangan Data (Backup & Restore)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Simpan data transaksi kamu ke dalam file JSON atau pulihkan data dari cadangan sebelumnya.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Tombol Export
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.upload_file, color: Colors.blue),
                  ),
                  title: const Text('Export Data (Backup)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Simpan file data ke HP atau kirim via WA/Email', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _handleExport(context),
                ),
                const Divider(),

                // Tombol Import
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    child: const Icon(Icons.download_for_offline, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Import Data (Restore)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Muat kembali file .json cadangan transaksi kamu', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _handleImport(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}