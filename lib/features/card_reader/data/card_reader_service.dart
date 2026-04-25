import 'dart:async';

import 'package:flutter/services.dart';

class CardEvent {
  const CardEvent({required this.type, required this.data});

  final String type;
  final Map<String, dynamic> data;
}

class CardReaderService {
  static const MethodChannel _methodChannel = MethodChannel('topwise/device');
  static const EventChannel _eventChannel = EventChannel('topwise/cardEvents');

  Stream<CardEvent> events() {
    return _eventChannel.receiveBroadcastStream().map((dynamic raw) {
      final map = Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
      final type = map['type']?.toString() ?? 'unknown';
      return CardEvent(type: type, data: map);
    });
  }

  Future<void> startSwipe({Duration timeout = const Duration(seconds: 60)}) async {
    await _methodChannel.invokeMethod<void>('card/startSwipe', <String, dynamic>{
      'timeoutMs': timeout.inMilliseconds,
    });
  }

  Future<void> stopSwipe() async {
    await _methodChannel.invokeMethod<void>('card/stopSwipe');
  }

  Future<void> startIC() async {
    await _methodChannel.invokeMethod<void>('card/startIC');
  }

  Future<void> stopIC() async {
    await _methodChannel.invokeMethod<void>('card/stopIC');
  }

  Future<bool> isICPresent() async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>(
      'card/isICPresent',
    );
    return response?['present'] == true;
  }

  Future<String> resetIC() async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>(
      'card/resetIC',
    );
    return response?['atr']?.toString() ?? '';
  }

  Future<String> readICApdu(String apduHex) async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>(
      'card/readICApdu',
      <String, dynamic>{'apduHex': apduHex},
    );
    return response?['responseHex']?.toString() ?? '';
  }

  Future<void> startRF() async {
    await _methodChannel.invokeMethod<void>('card/startRF');
  }

  Future<void> stopRF() async {
    await _methodChannel.invokeMethod<void>('card/stopRF');
  }

  Future<Map<String, dynamic>> pollRF() async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>('card/pollRF');
    return response ?? <String, dynamic>{};
  }

  Future<String> readRFApdu(String apduHex) async {
    final response = await _methodChannel.invokeMapMethod<String, dynamic>(
      'card/readRFApdu',
      <String, dynamic>{'apduHex': apduHex},
    );
    return response?['responseHex']?.toString() ?? '';
  }

  Future<void> stopAll() async {
    await _methodChannel.invokeMethod<void>('card/stopAll');
  }
}
