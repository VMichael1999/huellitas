import 'package:equatable/equatable.dart';

import '../theme/hu_tokens.dart';

enum PetSpecies {
  dog('dog', 'Perro', 'a-dog', HuAccent.teal),
  cat('cat', 'Gato', 'a-cat', HuAccent.coral),
  other('other', 'Otra', 'a-bunny', HuAccent.lav);

  const PetSpecies(this.key, this.label, this.defaultArt, this.defaultAccent);
  final String key;
  final String label;
  final String defaultArt;
  final HuAccent defaultAccent;

  static PetSpecies fromKey(String key) => switch (key) {
        'cat' => PetSpecies.cat,
        'other' => PetSpecies.other,
        _ => PetSpecies.dog,
      };
}

enum VaccineState { ok, next, late }

class Vaccine extends Equatable {
  const Vaccine({
    required this.name,
    required this.appliedOn,
    required this.nextDue,
    this.isDeworming = false,
  });

  final String name;
  final String appliedOn;
  final String nextDue;
  final bool isDeworming;

  Map<String, dynamic> toJson() => {
        'n': name,
        'd': appliedOn,
        'next': nextDue,
        'dw': isDeworming,
      };

  factory Vaccine.fromJson(Map<String, dynamic> json) => Vaccine(
        name: json['n'] as String,
        appliedOn: json['d'] as String,
        nextDue: json['next'] as String,
        isDeworming: (json['dw'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [name, appliedOn, nextDue, isDeworming];
}

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.date,
    required this.type,
    this.vetId,
    required this.diagnosis,
    required this.treatment,
    this.documentLabel,
  });

  final String date;
  final String type;
  final String? vetId;
  final String diagnosis;
  final String treatment;
  final String? documentLabel;

  Map<String, dynamic> toJson() => {
        'd': date,
        'type': type,
        'vet': vetId,
        'dx': diagnosis,
        'rx': treatment,
        'doc': documentLabel,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        date: json['d'] as String,
        type: json['type'] as String,
        vetId: json['vet'] as String?,
        diagnosis: json['dx'] as String,
        treatment: json['rx'] as String,
        documentLabel: json['doc'] as String?,
      );

  @override
  List<Object?> get props => [date, type, vetId, diagnosis, treatment, documentLabel];
}

class Pet extends Equatable {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.artKey,
    required this.accent,
    required this.breed,
    required this.sex,
    required this.birthDate,
    required this.weightKg,
    required this.weightHistory,
    required this.chip,
    required this.neutered,
    required this.allergies,
    required this.activity,
    required this.appetite,
    required this.mood,
    this.hydration = 85,
    required this.vetId,
    required this.vaccines,
    required this.history,
  });

  final String id;
  final String name;
  final PetSpecies species;
  final String artKey;
  final HuAccent accent;
  final String breed;
  final String sex;
  final String birthDate;
  final double weightKg;
  final List<double> weightHistory;
  final String chip;
  final bool neutered;
  final List<String> allergies;
  final int activity;
  final String appetite; // 'Bien' | 'Poco' | 'Nada'
  final String mood; // 'Feliz' | 'Tranquilo' | 'Tranquila' | 'Decaído'
  final int hydration;
  final String vetId;
  final List<Vaccine> vaccines;
  final List<HistoryEntry> history;

  Pet copyWith({
    String? name,
    String? breed,
    String? chip,
    double? weightKg,
    List<double>? weightHistory,
    int? activity,
    String? appetite,
    String? mood,
    List<Vaccine>? vaccines,
    List<HistoryEntry>? history,
  }) =>
      Pet(
        id: id,
        name: name ?? this.name,
        species: species,
        artKey: artKey,
        accent: accent,
        breed: breed ?? this.breed,
        sex: sex,
        birthDate: birthDate,
        weightKg: weightKg ?? this.weightKg,
        weightHistory: weightHistory ?? this.weightHistory,
        chip: chip ?? this.chip,
        neutered: neutered,
        allergies: allergies,
        activity: activity ?? this.activity,
        appetite: appetite ?? this.appetite,
        mood: mood ?? this.mood,
        hydration: hydration,
        vetId: vetId,
        vaccines: vaccines ?? this.vaccines,
        history: history ?? this.history,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'sp': species.key,
        'art': artKey,
        'color': accent.key,
        'breed': breed,
        'sex': sex,
        'born': birthDate,
        'w': weightKg,
        'ws': weightHistory,
        'chip': chip,
        'neut': neutered,
        'allergies': allergies,
        'act': activity,
        'food': appetite,
        'mood': mood,
        'hyd': hydration,
        'vet': vetId,
        'vax': vaccines.map((e) => e.toJson()).toList(),
        'hist': history.map((e) => e.toJson()).toList(),
      };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] as String,
        name: json['n'] as String,
        species: PetSpecies.fromKey(json['sp'] as String),
        artKey: json['art'] as String,
        accent: HuAccent.fromKey(json['color'] as String),
        breed: json['breed'] as String,
        sex: json['sex'] as String,
        birthDate: json['born'] as String,
        weightKg: (json['w'] as num).toDouble(),
        weightHistory: (json['ws'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
        chip: json['chip'] as String,
        neutered: json['neut'] as bool,
        allergies: (json['allergies'] as List<dynamic>).cast<String>(),
        activity: json['act'] as int,
        appetite: json['food'] as String,
        mood: json['mood'] as String,
        hydration: (json['hyd'] as int?) ?? 85,
        vetId: json['vet'] as String,
        vaccines: (json['vax'] as List<dynamic>)
            .map((e) => Vaccine.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        history: (json['hist'] as List<dynamic>)
            .map((e) => HistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        artKey,
        accent,
        breed,
        sex,
        birthDate,
        weightKg,
        weightHistory,
        chip,
        neutered,
        allergies,
        activity,
        appetite,
        mood,
        hydration,
        vetId,
        vaccines,
        history,
      ];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.mail,
    required this.phone,
    this.avatarKey = 'yo',
  });

  final String name;
  final String mail;
  final String phone;
  final String avatarKey;

  String get firstName => name.split(' ').first;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mail': mail,
        'phone': phone,
        'av': avatarKey,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String,
        mail: json['mail'] as String,
        phone: json['phone'] as String,
        avatarKey: (json['av'] as String?) ?? 'yo',
      );

  @override
  List<Object?> get props => [name, mail, phone, avatarKey];
}

class Clinic extends Equatable {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.km,
    required this.hoursLabel,
    required this.openStartMin,
    required this.openEndMin,
    required this.weekdays,
    this.is24h = false,
    required this.mapX,
    required this.mapY,
    required this.phone,
  });

  final String id;
  final String name;
  final String address;
  final double km;
  final String hoursLabel;
  final int openStartMin;
  final int openEndMin;
  final List<int> weekdays; // 0=Sun..6=Sat (JS getDay)
  final bool is24h;
  final double mapX;
  final double mapY;
  final String phone;

  @override
  List<Object?> get props => [id, name, address, km, hoursLabel, is24h];
}

class Vet extends Equatable {
  const Vet({
    required this.id,
    required this.name,
    required this.shortName,
    required this.specialty,
    required this.clinicId,
    required this.rating,
    required this.reviews,
    required this.years,
    required this.patients,
    required this.species,
    required this.about,
    required this.tags,
    required this.avatarKey,
  });

  final String id;
  final String name;
  final String shortName;
  final String specialty;
  final String clinicId;
  final double rating;
  final int reviews;
  final int years;
  final int patients;
  final List<PetSpecies> species;
  final String about;
  final List<String> tags;
  final String avatarKey;

  @override
  List<Object?> get props => [id, name, specialty, clinicId, rating, reviews];
}

class VisitType extends Equatable {
  const VisitType({
    required this.id,
    required this.name,
    required this.description,
    required this.minutes,
    required this.price,
    required this.icon,
    required this.accent,
    required this.vetIds,
  });

  final String id;
  final String name;
  final String description;
  final int minutes;
  final double price;
  final String icon;
  final HuAccent accent;
  final List<String> vetIds;

  @override
  List<Object?> get props => [id, name, minutes, price];
}

enum ServiceKind { slot, range, walk }

class ServiceCatalogItem extends Equatable {
  const ServiceCatalogItem({
    required this.id,
    required this.name,
    required this.artKey,
    required this.accent,
    required this.kind,
    this.minutes,
    this.price,
    this.sizePrices,
    this.walkPrices,
    required this.description,
    required this.extras,
    required this.dqIcon,
    required this.dqColorHex,
  });

  final String id;
  final String name;
  final String artKey;
  final HuAccent accent;
  final ServiceKind kind;
  final int? minutes;
  final double? price;
  final Map<String, double>? sizePrices;
  final Map<int, double>? walkPrices;
  final String description;
  final List<String> extras;
  final String dqIcon;
  final int dqColorHex;

  @override
  List<Object?> get props => [id, name, kind, price];
}

class ServiceExtra extends Equatable {
  const ServiceExtra({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

class Walker extends Equatable {
  const Walker({
    required this.id,
    required this.name,
    required this.rating,
    required this.walks,
    required this.avatarKey,
  });

  final String id;
  final String name;
  final double rating;
  final int walks;
  final String avatarKey;

  String get firstName => name.split(' ').first;

  @override
  List<Object?> get props => [id, name, rating, walks];
}

enum AppointmentKind { vet, svc }

enum AppointmentStatus { confirmed, done, cancelled }

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.kind,
    required this.petId,
    this.typeId,
    this.serviceId,
    this.vetId,
    this.walkerId,
    this.clinicId = 'c1',
    required this.date,
    required this.time,
    this.endDate,
    required this.status,
    required this.price,
    this.size,
    this.extras = const [],
    this.pickup = false,
    this.note = '',
    this.remind = true,
  });

  final String id;
  final AppointmentKind kind;
  final String petId;
  final String? typeId;
  final String? serviceId;
  final String? vetId;
  final String? walkerId;
  final String clinicId;
  final String date;
  final String time;
  final String? endDate;
  final AppointmentStatus status;
  final double price;
  final String? size;
  final List<String> extras;
  final bool pickup;
  final String note;
  final bool remind;

  Appointment copyWith({
    String? date,
    String? time,
    AppointmentStatus? status,
  }) =>
      Appointment(
        id: id,
        kind: kind,
        petId: petId,
        typeId: typeId,
        serviceId: serviceId,
        vetId: vetId,
        walkerId: walkerId,
        clinicId: clinicId,
        date: date ?? this.date,
        time: time ?? this.time,
        endDate: endDate,
        status: status ?? this.status,
        price: price,
        size: size,
        extras: extras,
        pickup: pickup,
        note: note,
        remind: remind,
      );

  @override
  List<Object?> get props => [
        id,
        kind,
        petId,
        typeId,
        serviceId,
        vetId,
        walkerId,
        clinicId,
        date,
        time,
        endDate,
        status,
        price,
        size,
        extras,
        pickup,
        note,
      ];
}

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.type, // 'med' | 'vac' | 'dew' | 'bath' | 'food'
    required this.petId,
    required this.title,
    this.subtitle = '',
    required this.date,
    required this.time,
    required this.repeat, // 'No se repite' | 'Diario' | 'Semanal' | 'Mensual' | 'Anual'
    this.done = false,
  });

  final int id;
  final String type;
  final String petId;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String repeat;
  final bool done;

  Reminder copyWith({bool? done}) => Reminder(
        id: id,
        type: type,
        petId: petId,
        title: title,
        subtitle: subtitle,
        date: date,
        time: time,
        repeat: repeat,
        done: done ?? this.done,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'pet': petId,
        't': title,
        's': subtitle,
        'date': date,
        'time': time,
        'rep': repeat,
        'done': done,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as int,
        type: json['type'] as String,
        petId: json['pet'] as String,
        title: json['t'] as String,
        subtitle: (json['s'] as String?) ?? '',
        date: json['date'] as String,
        time: json['time'] as String,
        repeat: json['rep'] as String,
        done: json['done'] as bool,
      );

  @override
  List<Object?> get props => [id, type, petId, title, subtitle, date, time, repeat, done];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.whenLabel,
    required this.unread,
    this.targetKind,
    this.targetId,
  });

  final int id;
  final String icon;
  final HuAccent accent;
  final String title;
  final String subtitle;
  final String whenLabel;
  final bool unread;
  final String? targetKind;
  final String? targetId;

  AppNotification copyWith({bool? unread}) => AppNotification(
        id: id,
        icon: icon,
        accent: accent,
        title: title,
        subtitle: subtitle,
        whenLabel: whenLabel,
        unread: unread ?? this.unread,
        targetKind: targetKind,
        targetId: targetId,
      );

  @override
  List<Object?> get props => [id, icon, accent, title, subtitle, whenLabel, unread, targetKind, targetId];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.artKey,
    required this.category,
    required this.species,
    required this.variants,
    required this.rating,
    required this.reviews,
    required this.description,
  });

  final String id;
  final String name;
  final String brand;
  final String artKey;
  final String category; // 'food' | 'toys' | 'hyg' | 'acc'
  final List<PetSpecies> species;
  final List<(String label, double price)> variants;
  final double rating;
  final int reviews;
  final String description;

  @override
  List<Object?> get props => [id, name, brand, category, rating, reviews];
}

class CartLine extends Equatable {
  const CartLine({
    required this.productId,
    required this.variantIndex,
    required this.qty,
  });

  final String productId;
  final int variantIndex;
  final int qty;

  CartLine copyWith({int? qty}) => CartLine(
        productId: productId,
        variantIndex: variantIndex,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'pid': productId,
        'v': variantIndex,
        'q': qty,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
        productId: json['pid'] as String,
        variantIndex: json['v'] as int,
        qty: json['q'] as int,
      );

  @override
  List<Object?> get props => [productId, variantIndex, qty];
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
  });

  final String id;
  final String date;
  final int items;
  final double total;
  final String status;

  @override
  List<Object?> get props => [id, date, items, total, status];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.fromMe,
    this.text = '',
    this.hasPhoto = false,
    required this.time,
  });

  final bool fromMe;
  final String text;
  final bool hasPhoto;
  final String time;

  @override
  List<Object?> get props => [fromMe, text, hasPhoto, time];
}

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.who, // 'vet' | 'walker' | 'clinic'
    required this.refId,
    required this.petId,
    required this.unread,
    required this.messages,
  });

  final String id;
  final String who;
  final String refId;
  final String petId;
  final int unread;
  final List<ChatMessage> messages;

  ChatThread copyWith({
    int? unread,
    List<ChatMessage>? messages,
  }) =>
      ChatThread(
        id: id,
        who: who,
        refId: refId,
        petId: petId,
        unread: unread ?? this.unread,
        messages: messages ?? this.messages,
      );

  @override
  List<Object?> get props => [id, who, refId, petId, unread, messages];
}

enum LiveWalkState { live, done }

class WalkEvent extends Equatable {
  const WalkEvent({
    required this.icon,
    required this.text,
    required this.time,
  });

  final String icon;
  final String text;
  final String time;

  @override
  List<Object?> get props => [icon, text, time];
}

class LiveWalk extends Equatable {
  const LiveWalk({
    required this.appointmentId,
    required this.petId,
    required this.walkerId,
    required this.state,
    required this.progress,
    required this.seconds,
    required this.events,
    this.rating = 0,
  });

  final String appointmentId;
  final String petId;
  final String walkerId;
  final LiveWalkState state;
  final double progress;
  final int seconds;
  final List<WalkEvent> events;
  final int rating;

  LiveWalk copyWith({
    LiveWalkState? state,
    double? progress,
    int? seconds,
    List<WalkEvent>? events,
    int? rating,
  }) =>
      LiveWalk(
        appointmentId: appointmentId,
        petId: petId,
        walkerId: walkerId,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        seconds: seconds ?? this.seconds,
        events: events ?? this.events,
        rating: rating ?? this.rating,
      );

  @override
  List<Object?> get props => [
        appointmentId,
        petId,
        walkerId,
        state,
        progress,
        seconds,
        events,
        rating,
      ];
}

class SavedAddress extends Equatable {
  const SavedAddress({
    required this.name,
    required this.address,
    this.isDefault = false,
  });

  final String name;
  final String address;
  final bool isDefault;

  @override
  List<Object?> get props => [name, address, isDefault];
}

class SavedCard extends Equatable {
  const SavedCard({
    required this.brand,
    required this.last4,
    this.isDefault = true,
  });

  final String brand;
  final String last4;
  final bool isDefault;

  @override
  List<Object?> get props => [brand, last4, isDefault];
}

/// Configuración de la pantalla de confirmación (`done` en HTML).
class DoneScreenData {
  const DoneScreenData({
    required this.title,
    required this.subtitle,
    this.appointmentId,
    this.order,
    this.isExpressOrder = false,
  });

  final String title;
  final String subtitle;
  final String? appointmentId;
  final Order? order;
  final bool isExpressOrder;
}
