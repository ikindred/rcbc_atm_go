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
  static const int _lineWidth = 40;
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
            'textSize': 16,
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
    final dash = '-' * _lineWidth;
    final copy = '*' * 5;

    return [
      _centered('$copy CUSTOMER COPY $copy'),
      '',
      // Sub-header (logo image prints above these lines via native code)
      _centered('RCBC Savings Bank'),
      _centered('333 Sen. Gil Puyat Ave, Makati'),
      _centered('www.rcbc.com'),
      '',
      dash,
      _centered(tx.transactionType.toUpperCase()),
      dash,
      '',
      _colonRow('Date / Time', tx.dateTime),
      _colonRow('RRN',         tx.rrn),
      _colonRow('TID',         tx.tid),
      _colonRow('MID',         tx.mid),
      _colonRow('Invoice No.', tx.invoiceNo),
      _colonRow('Trace ID',    tx.traceId),
      _colonRow('Status',      tx.status),
      dash,
      _colonRow('Card Type',   tx.cardType),
      _colonRow('Auth Code',   tx.authCode),
      _colonRow('Card No',     tx.cardNo),
      dash,
      '',
      _colonRow('Amount',      'PHP  ${tx.amount.toStringAsFixed(2)}'),
      _colonRow('Acquirer Fee','PHP  ${tx.acquirerFee.toStringAsFixed(2)}'),
      '',
      _colonRow('TOTAL',       'PHP  ${tx.total.toStringAsFixed(2)}'),
      '',
      _centered('PIN Verified'),
      _centered('Signature Not Required'),
      '',
      _centered('RCBC/CARD'),
      '',
      _centered('$copy CUSTOMER COPY $copy'),
      '',
      '',
      '',
      '',
    ];
  }

  /// Formats a row as "Label        : value" matching the client receipt style.
  String _colonRow(String label, String value) {
    const labelWidth = 13;
    final paddedLabel = label.length >= labelWidth
        ? label.substring(0, labelWidth)
        : label + ' ' * (labelWidth - label.length);
    final maxValue = _lineWidth - labelWidth - 3; // 3 = " : "
    final safeValue = _truncate(value, maxValue.clamp(1, _lineWidth));
    return '$paddedLabel: $safeValue';
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
