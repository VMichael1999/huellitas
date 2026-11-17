import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/models.dart';
import '../../core/theme/hu_tokens.dart';

class PetWizardState extends Equatable {
  const PetWizardState({
    this.step = 1,
    this.isFirstPet = false,
    this.species,
    this.name = '',
    this.artKey,
    this.breed = '',
    this.birthDate = '',
    this.sex = '',
    this.weightInput = '',
    this.neutered,
    this.allergies = const {},
    this.createdPet,
  });

  final int step; // 1..5
  final bool isFirstPet;
  final PetSpecies? species;
  final String name;
  final String? artKey;
  final String breed;
  final String birthDate;
  final String sex;
  final String weightInput;
  final bool? neutered;
  final Set<String> allergies;
  final Pet? createdPet;

  String get effectiveArtKey =>
      artKey ?? (species?.defaultArt ?? 'a-dog');

  bool get isStepValid {
    switch (step) {
      case 1:
        return species != null;
      case 2:
        return name.trim().length >= 2;
      case 3:
        return breed.trim().isNotEmpty &&
            birthDate.trim().isNotEmpty &&
            sex.isNotEmpty;
      case 4:
        final w = double.tryParse(weightInput.replaceAll(',', '.')) ?? 0;
        return w > 0 && neutered != null;
      default:
        return true;
    }
  }

  PetWizardState copyWith({
    int? step,
    bool? isFirstPet,
    PetSpecies? species,
    String? name,
    String? artKey,
    bool clearArt = false,
    String? breed,
    String? birthDate,
    String? sex,
    String? weightInput,
    bool? neutered,
    bool clearNeutered = false,
    Set<String>? allergies,
    Pet? createdPet,
  }) =>
      PetWizardState(
        step: step ?? this.step,
        isFirstPet: isFirstPet ?? this.isFirstPet,
        species: species ?? this.species,
        name: name ?? this.name,
        artKey: clearArt ? null : (artKey ?? this.artKey),
        breed: breed ?? this.breed,
        birthDate: birthDate ?? this.birthDate,
        sex: sex ?? this.sex,
        weightInput: weightInput ?? this.weightInput,
        neutered: clearNeutered ? null : (neutered ?? this.neutered),
        allergies: allergies ?? this.allergies,
        createdPet: createdPet ?? this.createdPet,
      );

  @override
  List<Object?> get props => [
        step,
        isFirstPet,
        species,
        name,
        artKey,
        breed,
        birthDate,
        sex,
        weightInput,
        neutered,
        allergies,
        createdPet,
      ];
}

sealed class PetWizardEvent {
  const PetWizardEvent();
}

class PetWizardStarted extends PetWizardEvent {
  const PetWizardStarted({required this.isFirstPet});
  final bool isFirstPet;
}

class PetWizardSpeciesSelected extends PetWizardEvent {
  const PetWizardSpeciesSelected(this.species);
  final PetSpecies species;
}

class PetWizardNameChanged extends PetWizardEvent {
  const PetWizardNameChanged(this.name);
  final String name;
}

class PetWizardArtSelected extends PetWizardEvent {
  const PetWizardArtSelected(this.artKey);
  final String artKey;
}

class PetWizardBreedChanged extends PetWizardEvent {
  const PetWizardBreedChanged(this.breed);
  final String breed;
}

class PetWizardBirthDateChanged extends PetWizardEvent {
  const PetWizardBirthDateChanged(this.birthDate);
  final String birthDate;
}

class PetWizardSexSelected extends PetWizardEvent {
  const PetWizardSexSelected(this.sex);
  final String sex;
}

class PetWizardWeightChanged extends PetWizardEvent {
  const PetWizardWeightChanged(this.weight);
  final String weight;
}

class PetWizardNeuteredSelected extends PetWizardEvent {
  const PetWizardNeuteredSelected(this.neutered);
  final bool neutered;
}

class PetWizardAllergyToggled extends PetWizardEvent {
  const PetWizardAllergyToggled(this.allergy);
  final String allergy;
}

class PetWizardNextPressed extends PetWizardEvent {
  const PetWizardNextPressed({required this.existingPetCount});
  final int existingPetCount;
}

class PetWizardBackPressed extends PetWizardEvent {
  const PetWizardBackPressed();
}

class PetWizardBloc extends Bloc<PetWizardEvent, PetWizardState> {
  PetWizardBloc() : super(const PetWizardState()) {
    on<PetWizardStarted>((event, emit) {
      emit(PetWizardState(isFirstPet: event.isFirstPet));
    });
    on<PetWizardSpeciesSelected>((event, emit) {
      emit(state.copyWith(
        species: event.species,
        clearArt: true,
        breed: '',
      ));
    });
    on<PetWizardNameChanged>((event, emit) {
      emit(state.copyWith(name: event.name));
    });
    on<PetWizardArtSelected>((event, emit) {
      emit(state.copyWith(artKey: event.artKey));
    });
    on<PetWizardBreedChanged>((event, emit) {
      emit(state.copyWith(breed: event.breed));
    });
    on<PetWizardBirthDateChanged>((event, emit) {
      emit(state.copyWith(birthDate: event.birthDate));
    });
    on<PetWizardSexSelected>((event, emit) {
      emit(state.copyWith(sex: event.sex));
    });
    on<PetWizardWeightChanged>((event, emit) {
      emit(state.copyWith(weightInput: event.weight.replaceAll(',', '.')));
    });
    on<PetWizardNeuteredSelected>((event, emit) {
      emit(state.copyWith(neutered: event.neutered));
    });
    on<PetWizardAllergyToggled>((event, emit) {
      final next = Set<String>.from(state.allergies);
      if (!next.remove(event.allergy)) {
        next.add(event.allergy);
      }
      emit(state.copyWith(allergies: next));
    });
    on<PetWizardNextPressed>((event, emit) {
      if (!state.isStepValid) return;
      if (state.step == 4) {
        const accents = [
          HuAccent.teal,
          HuAccent.coral,
          HuAccent.lav,
          HuAccent.sun,
        ];
        final accent = accents[event.existingPetCount % 4];
        final rawW = double.tryParse(state.weightInput.replaceAll(',', '.')) ?? 1.0;
        final w = (rawW * 10).round() / 10.0;
        final sp = state.species ?? PetSpecies.dog;
        final pet = Pet(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          name: state.name.trim(),
          species: sp,
          artKey: state.effectiveArtKey,
          accent: accent,
          breed: state.breed.trim(),
          sex: state.sex,
          birthDate: state.birthDate,
          weightKg: w,
          weightHistory: [w],
          chip: 'Sin registrar',
          neutered: state.neutered ?? false,
          allergies: state.allergies.toList(),
          activity: 70,
          appetite: 'Bien',
          mood: 'Feliz',
          vetId: sp == PetSpecies.cat ? 'camila' : 'sofia',
          vaccines: const [],
          history: const [],
        );
        emit(state.copyWith(step: 5, createdPet: pet));
      } else if (state.step < 5) {
        emit(state.copyWith(step: state.step + 1));
      }
    });
    on<PetWizardBackPressed>((event, emit) {
      if (state.step > 1) {
        emit(state.copyWith(step: state.step - 1));
      }
    });
  }
}
