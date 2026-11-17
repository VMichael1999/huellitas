import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/utils/clock.dart';

class PetsState extends Equatable {
  const PetsState({
    required this.pets,
    this.selectedPetId = 'milo',
    this.activeTab = 'vax', // 'vax' | 'hist' | 'data'
  });

  final List<Pet> pets;
  final String selectedPetId;
  final String activeTab;

  Pet? get selectedPet {
    if (pets.isEmpty) return null;
    return pets.firstWhere(
      (p) => p.id == selectedPetId,
      orElse: () => pets.first,
    );
  }

  Pet? byId(String id) {
    for (final p in pets) {
      if (p.id == id) return p;
    }
    return null;
  }

  PetsState copyWith({
    List<Pet>? pets,
    String? selectedPetId,
    String? activeTab,
  }) =>
      PetsState(
        pets: pets ?? this.pets,
        selectedPetId: selectedPetId ?? this.selectedPetId,
        activeTab: activeTab ?? this.activeTab,
      );

  @override
  List<Object?> get props => [pets, selectedPetId, activeTab];
}

sealed class PetsEvent {
  const PetsEvent();
}

class PetSelected extends PetsEvent {
  const PetSelected(this.petId, {this.tab});
  final String petId;
  final String? tab;
}

class PetTabChanged extends PetsEvent {
  const PetTabChanged(this.tab);
  final String tab;
}

class PetAdded extends PetsEvent {
  const PetAdded(this.pet);
  final Pet pet;
}

class PetUpdated extends PetsEvent {
  const PetUpdated({
    required this.petId,
    required this.name,
    required this.breed,
    required this.chip,
  });
  final String petId;
  final String name;
  final String breed;
  final String chip;
}

class PetDeleted extends PetsEvent {
  const PetDeleted(this.petId);
  final String petId;
}

class PetRestored extends PetsEvent {
  const PetRestored({required this.index, required this.pet});
  final int index;
  final Pet pet;
}

class PetDailyLogged extends PetsEvent {
  const PetDailyLogged({
    required this.petId,
    required this.weightKg,
    required this.activityLevel, // 'Poca' | 'Normal' | 'Mucha'
    required this.appetite, // 'Nada' | 'Poco' | 'Bien'
    required this.mood, // 'Decaído' | 'Tranquilo' | 'Tranquila' | 'Feliz'
  });

  final String petId;
  final double weightKg;
  final String activityLevel;
  final String appetite;
  final String mood;
}

class PetVaccineAdded extends PetsEvent {
  const PetVaccineAdded({
    required this.petId,
    required this.vaccine,
  });
  final String petId;
  final Vaccine vaccine;
}

class PetsReset extends PetsEvent {
  const PetsReset({required this.empty});
  final bool empty;
}

class PetsBloc extends HydratedBloc<PetsEvent, PetsState> {
  PetsBloc({required this.clock})
      : super(PetsState(pets: DemoData.mkPets(clock.today))) {
    on<PetSelected>((event, emit) {
      emit(state.copyWith(
        selectedPetId: event.petId,
        activeTab: event.tab ?? state.activeTab,
      ));
    });
    on<PetTabChanged>((event, emit) {
      emit(state.copyWith(activeTab: event.tab));
    });
    on<PetAdded>((event, emit) {
      final next = [...state.pets, event.pet];
      emit(state.copyWith(pets: next, selectedPetId: event.pet.id, activeTab: 'vax'));
    });
    on<PetUpdated>((event, emit) {
      final next = state.pets.map((p) {
        if (p.id != event.petId) return p;
        return p.copyWith(
          name: event.name,
          breed: event.breed.isEmpty ? p.breed : event.breed,
          chip: event.chip.isEmpty ? p.chip : event.chip,
        );
      }).toList();
      emit(state.copyWith(pets: next));
    });
    on<PetDeleted>((event, emit) {
      final next = state.pets.where((p) => p.id != event.petId).toList();
      emit(state.copyWith(
        pets: next,
        selectedPetId: next.isNotEmpty ? next.first.id : '',
      ));
    });
    on<PetRestored>((event, emit) {
      final next = [...state.pets];
      final safeIdx = event.index.clamp(0, next.length);
      next.insert(safeIdx, event.pet);
      emit(state.copyWith(pets: next, selectedPetId: event.pet.id));
    });
    on<PetDailyLogged>((event, emit) {
      final act = switch (event.activityLevel) {
        'Poca' => 35,
        'Mucha' => 85,
        _ => 60,
      };
      final next = state.pets.map((p) {
        if (p.id != event.petId) return p;
        final wRounded = (event.weightKg * 10).round() / 10.0;
        final ws = wRounded != p.weightKg
            ? [...p.weightHistory, wRounded]
            : p.weightHistory;
        return p.copyWith(
          weightKg: wRounded,
          weightHistory: ws,
          activity: act,
          appetite: event.appetite,
          mood: event.mood,
        );
      }).toList();
      emit(state.copyWith(pets: next));
    });
    on<PetVaccineAdded>((event, emit) {
      final next = state.pets.map((p) {
        if (p.id != event.petId) return p;
        return p.copyWith(vaccines: [...p.vaccines, event.vaccine]);
      }).toList();
      emit(state.copyWith(pets: next));
    });
    on<PetsReset>((event, emit) {
      final next = event.empty ? <Pet>[] : DemoData.mkPets(clock.today);
      emit(state.copyWith(
        pets: next,
        selectedPetId: next.isNotEmpty ? next.first.id : '',
      ));
    });
  }

  final Clock clock;

  @override
  PetsState? fromJson(Map<String, dynamic> json) {
    try {
      final list = (json['pets'] as List<dynamic>)
          .map((e) => Pet.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return PetsState(
        pets: list,
        selectedPetId: (json['selectedPetId'] as String?) ?? 'milo',
        activeTab: (json['activeTab'] as String?) ?? 'vax',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(PetsState state) => {
        'pets': state.pets.map((e) => e.toJson()).toList(),
        'selectedPetId': state.selectedPetId,
        'activeTab': state.activeTab,
      };
}
