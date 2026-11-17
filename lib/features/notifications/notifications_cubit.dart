import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/utils/clock.dart';

class NotificationsState extends Equatable {
  const NotificationsState({required this.items});
  final List<AppNotification> items;

  bool get hasUnread => items.any((n) => n.unread);

  @override
  List<Object?> get props => [items];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required this.clock})
      : super(NotificationsState(items: DemoData.mkNotifications(clock.today)));

  final Clock clock;

  void markRead(int id) {
    final next = state.items
        .map((n) => n.id == id ? n.copyWith(unread: false) : n)
        .toList();
    emit(NotificationsState(items: next));
  }

  void markAllRead() {
    final next = state.items.map((n) => n.copyWith(unread: false)).toList();
    emit(NotificationsState(items: next));
  }

  void addNotification(AppNotification item) {
    emit(NotificationsState(items: [item, ...state.items]));
  }

  void reset({required bool empty}) {
    emit(NotificationsState(
      items: empty ? [] : DemoData.mkNotifications(clock.today),
    ));
  }
}
