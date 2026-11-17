import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.online = true,
    this.retrying = false,
  });

  final bool online;
  final bool retrying;

  ConnectivityState copyWith({bool? online, bool? retrying}) =>
      ConnectivityState(
        online: online ?? this.online,
        retrying: retrying ?? this.retrying,
      );

  @override
  List<Object?> get props => [online, retrying];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState());

  void toggleOffline() => emit(state.copyWith(online: !state.online));

  void setOnline(bool online) => emit(state.copyWith(online: online));

  Future<bool> retry() async {
    emit(state.copyWith(retrying: true));
    await Future<void>.delayed(const Duration(milliseconds: 900));
    emit(state.copyWith(retrying: false));
    return state.online;
  }
}
