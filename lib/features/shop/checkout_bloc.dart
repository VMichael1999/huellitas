import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/rules.dart';

enum CheckoutPhase { idle, paying, paid }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.addressIndex = 0,
    this.shippingKind = 'std', // 'std' | 'exp'
    this.phase = CheckoutPhase.idle,
  });

  final int addressIndex;
  final String shippingKind;
  final CheckoutPhase phase;

  bool get isExpress => shippingKind == 'exp';

  double shippingFee(double subtotal) => BookingPricingRules.shippingFee(
        subtotal: subtotal,
        express: isExpress,
      );

  double total(double subtotal) => subtotal + shippingFee(subtotal);

  CheckoutState copyWith({
    int? addressIndex,
    String? shippingKind,
    CheckoutPhase? phase,
  }) =>
      CheckoutState(
        addressIndex: addressIndex ?? this.addressIndex,
        shippingKind: shippingKind ?? this.shippingKind,
        phase: phase ?? this.phase,
      );

  @override
  List<Object?> get props => [addressIndex, shippingKind, phase];
}

sealed class CheckoutEvent {
  const CheckoutEvent();
}

class CheckoutAddressSelected extends CheckoutEvent {
  const CheckoutAddressSelected(this.index);
  final int index;
}

class CheckoutShippingSelected extends CheckoutEvent {
  const CheckoutShippingSelected(this.kind);
  final String kind;
}

class CheckoutPayRequested extends CheckoutEvent {
  const CheckoutPayRequested();
}

class CheckoutReset extends CheckoutEvent {
  const CheckoutReset();
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(const CheckoutState()) {
    on<CheckoutAddressSelected>((event, emit) {
      emit(state.copyWith(addressIndex: event.index));
    });
    on<CheckoutShippingSelected>((event, emit) {
      emit(state.copyWith(shippingKind: event.kind));
    });
    on<CheckoutPayRequested>((event, emit) async {
      emit(state.copyWith(phase: CheckoutPhase.paying));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      emit(state.copyWith(phase: CheckoutPhase.paid));
    });
    on<CheckoutReset>((event, emit) {
      emit(const CheckoutState());
    });
  }
}
