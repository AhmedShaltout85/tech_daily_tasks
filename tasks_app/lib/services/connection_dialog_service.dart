// lib/services/dialog_service.dart
import 'package:flutter/material.dart';
import 'package:tasks_app/services/connectivity_service.dart';

class ConnectionDialogService {
  static ConnectivityService? _connectivityService;

  static Future<void> showNoInternetDialog(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('لا يوجد اتصال بالإنترنت'),
          ],
        ),
        content: const Text(
          'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () async {
                // Check connection again before retrying
                _connectivityService ??= ConnectivityService();
                final hasConnection =
                    await _connectivityService!.hasConnection();

                if (!hasConnection) {
                  // Still no connection, show toast
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يزال لا يوجد اتصال بالإنترنت'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (Navigator.canPop(context)) Navigator.pop(context);
                onRetry();
              },
              child: const Text('إعادة المحاولة'),
            ),
        ],
      ),
    );
  }

  // Optional: Method to check connection and show dialog if needed
  static Future<bool> checkAndHandleConnection(
    BuildContext context, {
    VoidCallback? onConnected,
  }) async {
    _connectivityService ??= ConnectivityService();
    final hasConnection = await _connectivityService!.hasConnection();

    if (!hasConnection) {
      await showNoInternetDialog(
        context,
        onRetry: onConnected,
      );
      return false;
    }

    return true;
  }
}
