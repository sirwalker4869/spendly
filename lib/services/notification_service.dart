import 'package:notification_listener_service/notification_listener_service.dart';
import '../models/transaction_model.dart';

class NotificationServiceTracker {
  // Flag untuk memastikan listener hanya diinisialisasi sekali agar tidak terjadi duplikasi/looping
  static bool _isInitialized = false;

  static void initializeListener(Function(Transaction) onTransactionCaptured) async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 1. Periksa apakah izin akses notifikasi sudah diberikan
      bool hasPermission = await NotificationListenerService.isPermissionGranted() ?? false;
      
      if (!hasPermission) {
        // Jika belum, arahkan pengguna ke halaman pengaturan sistem secara aman
        await NotificationListenerService.requestPermission();
        return;
      }

      // 2. Mulai mendengarkan stream notifikasi masuk secara background / real-time
      NotificationListenerService.notificationsStream.listen((event) {
        final String? packageName = event.packageName; // Contoh: id.dana, com.bca
        final String? title = event.title;
        final String? content = event.content;

        if (content != null && packageName != null) {
          // Filter aplikasi target m-Banking / E-Wallet 
          // (Pastikan package name sesuai dengan aplikasi di HP kamu)
          if (packageName == 'id.dana' || 
              packageName == 'com.bca' || 
              packageName == 'com.ocioclub' || // Mandiri Livin
              packageName == 'com.telkomsel.cash') { // LinkAja
            
            _parseAndSaveTransaction(title ?? 'Transaksi Otomatis', content, onTransactionCaptured);
          }
        }
      }, onError: (error) {
        print('Notification Stream Error: $error');
      });
    } catch (e) {
      // Mencegah crash total jika perangkat menolak akses background service
      print('Error initializing notification listener: $e');
    }
  }

  // Helper murni untuk memparsing teks isi notifikasi menjadi nominal uang & data transaksi
  static void _parseAndSaveTransaction(
      String title, String content, Function(Transaction) onCallback) {
    // Regular Expression (Regex) untuk mendeteksi format uang seperti "Rp 50.000" atau "Rp50000"
    final regExp = RegExp(r'Rp\s?([\d.,]+)');
    final match = regExp.firstMatch(content);

    if (match != null) {
      String rawAmount = match.group(1)!.replaceAll('.', '').replaceAll(',', '');
      double amount = double.tryParse(rawAmount) ?? 0;

      if (amount > 0) {
        final newTx = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isNotEmpty ? title : 'Transaksi Otomatis',
          category: 'Lainnya',
          emoji: '🤖',
          amount: amount,
          date: DateTime.now(),
          paymentMethod: 'Auto / E-Wallet',
          isExpense: true, // Default tercatat sebagai pengeluaran otomatis
        );

        // Meneruskan data transaksi keluar via callback ke MainNavigationWrapper
        onCallback(newTx);
      }
    }
  }
}