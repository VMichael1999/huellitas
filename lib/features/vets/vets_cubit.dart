import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VetsState extends Equatable {
  const VetsState({
    this.filter = 'all', // 'all' | 'open' | 'h24' | 'cat' | 'derm'
    this.mode = 'list', // 'list' | 'map'
    this.selectedVetId = 'sofia',
  });

  final String filter;
  final String mode;
  final String selectedVetId;

  VetsState copyWith({
    String? filter,
    String? mode,
    String? selectedVetId,
  }) =>
      VetsState(
        filter: filter ?? this.filter,
        mode: mode ?? this.mode,
        selectedVetId: selectedVetId ?? this.selectedVetId,
      );

  @override
  List<Object?> get props => [filter, mode, selectedVetId];
}

class VetsCubit extends Cubit<VetsState> {
  VetsCubit() : super(const VetsState());

  void setFilter(String filter) => emit(state.copyWith(filter: filter));

  void toggleMode() =>
      emit(state.copyWith(mode: state.mode == 'list' ? 'map' : 'list'));

  void selectVet(String vetId) => emit(state.copyWith(selectedVetId: vetId));
}
