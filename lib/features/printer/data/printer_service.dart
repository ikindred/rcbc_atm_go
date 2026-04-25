import 'dart:developer';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rcbc_atm_go/features/transaction/data/models/transaction_model.dart';

class PrinterResult {
  const PrinterResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class PrinterService {
  static const int _lineWidth = 32;
  static const MethodChannel _methodChannel = MethodChannel('topwise/device');
  static const Duration _printTimeout = Duration(seconds: 20);

  Future<PrinterResult> printReceipt(TransactionModel tx) async {
    const stagePrint = 'printer/printReceipt';

    try {
      await _methodChannel
          .invokeMethod<Map<dynamic, dynamic>>('printer/printReceipt', <String, dynamic>{
            'lines': _buildReceiptLines(tx),
            'gray': 3,
            'align': 'LEFT',
            'textSize': 18,
            'bold': false,
            'underline': false,
          })
          .timeout(_printTimeout);
      return const PrinterResult(success: true, message: 'Printed successfully');
    } on TimeoutException catch (error, stackTrace) {
      final report =
          'Printer Error\n'
          'Stage: $stagePrint\n'
          'Code: TIMEOUT\n'
          'Message: ${error.message ?? 'Operation timed out'}';
      log(report, stackTrace: stackTrace);
      return PrinterResult(success: false, message: report);
    } on PlatformException catch (error, stackTrace) {
      final report =
          'Printer Error\n'
          'Stage: $stagePrint\n'
          'Code: ${error.code}\n'
          'Message: ${error.message ?? 'Platform exception'}';
      log(report, stackTrace: stackTrace);
      return PrinterResult(success: false, message: report);
    } catch (error, stackTrace) {
      final report =
          'Printer Error\n'
          'Stage: sdk-call\n'
          'Code: EXCEPTION\n'
          'Message: $error';
      log(report, stackTrace: stackTrace);
      return PrinterResult(success: false, message: report);
    }
  }

  List<String> _buildReceiptLines(TransactionModel tx) {
    final separator = '-' * _lineWidth;
    final lines = <String>[
      _centered('RCBC ATM GO'),
      _centered('MERCHANT NAME'),
      _centered('HEADER 1'),
      _centered('HEADER 2'),
      _centered('HEADER 3'),
      _centered('HEADER 4'),
      _centered('VERSION 1.0'),
      _centered('<<${tx.transactionType}>>'),
      separator,
      _leftRight('Date/Time', tx.dateTime),
      _leftRight('RRN', tx.rrn),
      _leftRight('TID', tx.tid),
      _leftRight('MID', tx.mid),
      _leftRight('Invoice No.', tx.invoiceNo),
      _leftRight('Trace ID', tx.traceId),
      _leftRight('Status', tx.status),
      separator,
      _leftRight('Card Type', tx.cardType),
      _leftRight('Auth Code', tx.authCode),
      _leftRight('Card No.', tx.cardNo),
      separator,
      _leftRight('Amount', 'PHP ${tx.amount}'),
      _leftRight('Acquirer Fee', 'PHP ${tx.acquirerFee}'),
      _leftRight('Total', 'PHP ${tx.total}'),
      separator,
      _centered('PIN Verified'),
      _centered('Signature Not Required'),
      '',
      '',
      '',
    ];

    return lines;
  }

  String _centered(String text) {
    final safe = _truncate(text, _lineWidth);
    final left = ((_lineWidth - safe.length).clamp(0, _lineWidth)) ~/ 2;
    final right = (_lineWidth - safe.length - left).clamp(0, _lineWidth);
    return '${' ' * left}$safe${' ' * right}';
  }

  String _leftRight(String label, String value) {
    final safeValue = _truncate(value, (_lineWidth / 2).floor().clamp(8, _lineWidth));
    final maxLabel = (_lineWidth - safeValue.length - 1).clamp(1, _lineWidth);
    final safeLabel = _truncate(label, maxLabel);
    final spaces = (_lineWidth - safeLabel.length - safeValue.length).clamp(1, _lineWidth);
    return '$safeLabel${' ' * spaces}$safeValue';
  }

  String _truncate(String value, int width) {
    final safe = value.replaceAll('\n', ' ').trim();
    return safe.length > width ? safe.substring(0, width) : safe;
  }
}
