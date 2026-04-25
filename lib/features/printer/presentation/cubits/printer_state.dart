import 'package:equatable/equatable.dart';

sealed class PrinterState extends Equatable {
  const PrinterState();

  @override
  List<Object?> get props => [];
}

class PrinterInitial extends PrinterState {
  const PrinterInitial();
}

class PrinterPrinting extends PrinterState {
  const PrinterPrinting();
}

class PrinterSuccess extends PrinterState {
  const PrinterSuccess();
}

class PrinterError extends PrinterState {
  const PrinterError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
