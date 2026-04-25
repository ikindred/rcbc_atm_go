import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rcbc_atm_go/features/card_reader/data/card_reader_service.dart';

sealed class CardReaderState extends Equatable {
  const CardReaderState();

  @override
  List<Object?> get props => [];
}

class CardReaderIdle extends CardReaderState {
  const CardReaderIdle();
}

class CardReaderDetecting extends CardReaderState {
  const CardReaderDetecting();
}

class CardReaderCardFound extends CardReaderState {
  const CardReaderCardFound(this.data);

  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

class CardReaderError extends CardReaderState {
  const CardReaderError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CardReaderCubit extends Cubit<CardReaderState> {
  CardReaderCubit({required CardReaderService cardReaderService})
      : _cardReaderService = cardReaderService,
        super(const CardReaderIdle()) {
    _eventSub = _cardReaderService.events().listen(
      (event) {
        if (event.type == 'error') {
          emit(CardReaderError(event.data['message']?.toString() ?? 'Card reader error'));
          return;
        }
        emit(CardReaderCardFound(event.data));
      },
      onError: (Object error) {
        emit(CardReaderError(error.toString()));
      },
    );
  }

  final CardReaderService _cardReaderService;
  StreamSubscription<CardEvent>? _eventSub;

  Future<void> startSwipe() async {
    emit(const CardReaderDetecting());
    try {
      await _cardReaderService.startSwipe();
    } catch (error) {
      emit(CardReaderError(error.toString()));
    }
  }

  Future<void> startIC() async {
    emit(const CardReaderDetecting());
    try {
      await _cardReaderService.startIC();
    } catch (error) {
      emit(CardReaderError(error.toString()));
    }
  }

  Future<void> startRF() async {
    emit(const CardReaderDetecting());
    try {
      await _cardReaderService.startRF();
    } catch (error) {
      emit(CardReaderError(error.toString()));
    }
  }

  Future<void> stopAll() async {
    await _cardReaderService.stopAll();
    emit(const CardReaderIdle());
  }

  @override
  Future<void> close() async {
    await _eventSub?.cancel();
    return super.close();
  }
}
