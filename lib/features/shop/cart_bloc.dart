import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/domain/rules.dart';
import '../../core/utils/clock.dart';

class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    required this.orders,
  });

  final List<CartLine> lines;
  final List<Order> orders;

  int get totalQty => lines.fold(0, (acc, l) => acc + l.qty);

  double lineTotal(CartLine l) {
    final p = DemoData.productById(l.productId);
    final idx = l.variantIndex.clamp(0, p.variants.length - 1);
    return p.variants[idx].$2 * l.qty;
  }

  double get subtotal => lines.fold(0.0, (acc, l) => acc + lineTotal(l));

  double get remainingForFreeShipping =>
      math.max(0.0, BookingPricingRules.freeShippingThreshold - subtotal);

  double get standardShipping =>
      BookingPricingRules.shippingFee(subtotal: subtotal, express: false);

  double get standardTotal => subtotal + standardShipping;

  CartState copyWith({
    List<CartLine>? lines,
    List<Order>? orders,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        orders: orders ?? this.orders,
      );

  @override
  List<Object?> get props => [lines, orders];
}

sealed class CartEvent {
  const CartEvent();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded({
    required this.productId,
    required this.variantIndex,
    this.qty = 1,
  });

  final String productId;
  final int variantIndex;
  final int qty;
}

class CartItemQtyDelta extends CartEvent {
  const CartItemQtyDelta({required this.index, required this.delta});
  final int index;
  final int delta;
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.index);
  final int index;
}

class CartItemRestored extends CartEvent {
  const CartItemRestored({required this.index, required this.line});
  final int index;
  final CartLine line;
}

class CartOrderPlaced extends CartEvent {
  const CartOrderPlaced(this.order);
  final Order order;
}

class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc({required this.clock})
      : super(CartState(orders: DemoData.mkOrders(clock.today))) {
    on<CartItemAdded>((event, emit) {
      final list = List<CartLine>.from(state.lines);
      final idx = list.indexWhere(
        (l) =>
            l.productId == event.productId &&
            l.variantIndex == event.variantIndex,
      );
      if (idx >= 0) {
        final cur = list[idx];
        list[idx] = cur.copyWith(qty: math.min(9, cur.qty + event.qty));
      } else {
        list.add(CartLine(
          productId: event.productId,
          variantIndex: event.variantIndex,
          qty: event.qty,
        ));
      }
      emit(state.copyWith(lines: list));
    });

    on<CartItemQtyDelta>((event, emit) {
      if (event.index < 0 || event.index >= state.lines.length) return;
      final list = List<CartLine>.from(state.lines);
      final cur = list[event.index];
      final nextQty = (cur.qty + event.delta).clamp(1, 9);
      list[event.index] = cur.copyWith(qty: nextQty);
      emit(state.copyWith(lines: list));
    });

    on<CartItemRemoved>((event, emit) {
      if (event.index < 0 || event.index >= state.lines.length) return;
      final list = List<CartLine>.from(state.lines)..removeAt(event.index);
      emit(state.copyWith(lines: list));
    });

    on<CartItemRestored>((event, emit) {
      final list = List<CartLine>.from(state.lines);
      final safeIdx = event.index.clamp(0, list.length);
      list.insert(safeIdx, event.line);
      emit(state.copyWith(lines: list));
    });

    on<CartOrderPlaced>((event, emit) {
      emit(state.copyWith(
        lines: const [],
        orders: [event.order, ...state.orders],
      ));
    });
  }

  final Clock clock;

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final lines = (json['lines'] as List<dynamic>)
          .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return CartState(
        lines: lines,
        orders: DemoData.mkOrders(clock.today),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) => {
        'lines': state.lines.map((e) => e.toJson()).toList(),
      };
}
