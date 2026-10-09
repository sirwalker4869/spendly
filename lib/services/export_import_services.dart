import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';

class ExportImportService {
  // 📤 EXPORT DATA KE FILE JSON
  static Future<void> exportData(List<Transaction> transactions) async {
    try {
      // 1. Ubah List Transaction ke format JSON String
      final List<Map<String, dynamic>> mapList =
          transactions.map((tx) => tx.toMap()).toList();
      final String jsonString = json.encode(mapList);

      // 2. Dapatkan direktori sementara untuk membuat file
      final directory = await getTemporaryDirectory();
      final String dateFormatted = DateTime.now()
          .toIso8601String()
          .split('T')[0]
          .replaceAll('-', '');
      final File file = File('${directory.path}/spendly_backup_$dateFormatted.json');

      // 3. Tulis file JSON
      await file.writeAsString(jsonString);

      // 4. Buka menu bagikan (Share / Save to Files)
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Backup Data Spendly',
        text: 'Berikut adalah file cadangan data transaksi Spendly kamu.',
      );
    } catch (e) {
      rethrow;
    }
  }

  // 📥 IMPORT DATA DARI FILE JSON
  static Future<List<Transaction>?> importData() async {
    try {
      // 1. Buka File Picker untuk memilih file .json
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final String content = await file.readAsString();

        // 2. Decode konten file JSON
        final List<dynamic> decodedList = json.decode(content);

        // 3. Convert ke List<Transaction>
        return decodedList.map((item) => Transaction.fromMap(item)).toList();
      }
      return null; // Pengguna membatalkan pemilihan file
    } catch (e) {
      rethrow;
    }
  }
}