import '../domain/models.dart';
import '../domain/rules.dart';
import '../format/hu_format.dart';
import '../theme/hu_tokens.dart';

/// Datos exactos de la demo (`USER`, `CLIN`, `VETS`, `TYPES`, `WALKERS`, `SVCS`, `EXT`, `PRODS`, `BREEDS`, `mkPets`).
class DemoData {
  static const UserProfile defaultUser = UserProfile(
    name: 'Michael Dev',
    mail: 'michaeldev@gmail.com',
    phone: '987 654 321',
    avatarKey: 'yo',
  );

  static const List<Clinic> clinics = [
    Clinic(
      id: 'c1',
      name: 'Huellitas Centro',
      address: 'Av. Las Palmeras 245',
      km: 1.2,
      hoursLabel: 'Lun a sáb · 8:00 a 20:00',
      openStartMin: 480,
      openEndMin: 1200,
      weekdays: [1, 2, 3, 4, 5, 6],
      mapX: 38,
      mapY: 42,
      phone: '(01) 555 0142',
    ),
    Clinic(
      id: 'c2',
      name: 'Huellitas Norte',
      address: 'Calle Los Robles 88',
      km: 3.4,
      hoursLabel: 'Lun a vie · 9:00 a 19:00',
      openStartMin: 540,
      openEndMin: 1140,
      weekdays: [1, 2, 3, 4, 5],
      mapX: 70,
      mapY: 22,
      phone: '(01) 555 0188',
    ),
    Clinic(
      id: 'c3',
      name: 'Hospital Veterinario 24 h',
      address: 'Av. del Parque 1020',
      km: 5.1,
      hoursLabel: 'Abierto las 24 horas',
      openStartMin: 0,
      openEndMin: 1440,
      weekdays: [0, 1, 2, 3, 4, 5, 6],
      is24h: true,
      mapX: 72,
      mapY: 74,
      phone: '(01) 555 0911',
    ),
  ];

  static const List<Vet> vets = [
    Vet(
      id: 'sofia',
      name: 'Dra. Sofía Méndez',
      shortName: 'Dra. Sofía',
      specialty: 'Medicina general',
      clinicId: 'c1',
      rating: 4.9,
      reviews: 128,
      years: 9,
      patients: 1200,
      species: [PetSpecies.dog, PetSpecies.cat, PetSpecies.other],
      about:
          'Le encanta explicar con calma cada tratamiento. Atiende perros, gatos y pequeños mamíferos.',
      tags: ['Medicina preventiva', 'Vacunas', 'Nutrición'],
      avatarKey: 'sofia',
    ),
    Vet(
      id: 'andres',
      name: 'Dr. Andrés Ruiz',
      shortName: 'Dr. Andrés',
      specialty: 'Dermatología',
      clinicId: 'c2',
      rating: 4.8,
      reviews: 94,
      years: 12,
      patients: 2100,
      species: [PetSpecies.dog, PetSpecies.cat],
      about:
          'Especialista en piel, alergias y oídos. Busca siempre la causa, no solo el síntoma.',
      tags: ['Alergias', 'Piel', 'Oídos'],
      avatarKey: 'andres',
    ),
    Vet(
      id: 'camila',
      name: 'Dra. Camila Torres',
      shortName: 'Dra. Camila',
      specialty: 'Especialista en felinos',
      clinicId: 'c1',
      rating: 5.0,
      reviews: 76,
      years: 6,
      patients: 800,
      species: [PetSpecies.cat],
      about:
          'Consultorio libre de estrés para gatos: feromonas, manejo suave y sin prisas.',
      tags: ['Gatos', 'Comportamiento', 'Vacunas'],
      avatarKey: 'camila',
    ),
    Vet(
      id: 'mateo',
      name: 'Dr. Mateo Silva',
      shortName: 'Dr. Mateo',
      specialty: 'Cirugía y odontología',
      clinicId: 'c3',
      rating: 4.7,
      reviews: 152,
      years: 15,
      patients: 3400,
      species: [PetSpecies.dog, PetSpecies.cat, PetSpecies.other],
      about:
          'Cirujano del hospital 24 h. También hace limpiezas dentales con anestesia segura.',
      tags: ['Cirugía', 'Dientes', 'Urgencias'],
      avatarKey: 'mateo',
    ),
  ];

  static const List<VisitType> visitTypes = [
    VisitType(
      id: 'check',
      name: 'Chequeo general',
      description: 'Revisión completa y consulta',
      minutes: 30,
      price: 35,
      icon: 'i-steth',
      accent: HuAccent.teal,
      vetIds: ['sofia', 'camila', 'mateo'],
    ),
    VisitType(
      id: 'vac',
      name: 'Vacunación',
      description: 'Aplicación y registro en el carnet',
      minutes: 20,
      price: 25,
      icon: 'i-syringe',
      accent: HuAccent.lav,
      vetIds: ['sofia', 'camila'],
    ),
    VisitType(
      id: 'derm',
      name: 'Piel y alergias',
      description: 'Picazón, caída de pelo, oídos',
      minutes: 40,
      price: 45,
      icon: 'i-paw',
      accent: HuAccent.coral,
      vetIds: ['andres'],
    ),
    VisitType(
      id: 'dental',
      name: 'Limpieza dental',
      description: 'Con revisión previa y anestesia',
      minutes: 60,
      price: 80,
      icon: 'i-smile',
      accent: HuAccent.sun,
      vetIds: ['mateo'],
    ),
    VisitType(
      id: 'video',
      name: 'Videoconsulta',
      description: 'Desde casa, 20 minutos',
      minutes: 20,
      price: 25,
      icon: 'i-video',
      accent: HuAccent.sky,
      vetIds: ['sofia', 'andres'],
    ),
  ];

  static const List<Walker> walkers = [
    Walker(
      id: 'diego',
      name: 'Diego Paredes',
      rating: 4.9,
      walks: 340,
      avatarKey: 'diego',
    ),
    Walker(
      id: 'lucia',
      name: 'Lucía Gómez',
      rating: 4.8,
      walks: 215,
      avatarKey: 'lucia',
    ),
  ];

  static const List<ServiceCatalogItem> services = [
    ServiceCatalogItem(
      id: 'groom',
      name: 'Baño y corte',
      artKey: 'a-groom',
      accent: HuAccent.teal,
      kind: ServiceKind.slot,
      minutes: 60,
      sizePrices: {'S': 35, 'M': 45, 'L': 60},
      description:
          'Baño con shampoo hipoalergénico, secado, corte a tijera o máquina y perfume suave.',
      extras: ['nails', 'ears', 'perfume'],
      dqIcon: 'scissors',
      dqColorHex: 0xFFF2775E,
    ),
    ServiceCatalogItem(
      id: 'nails',
      name: 'Corte de uñas',
      artKey: 'a-nails',
      accent: HuAccent.sun,
      kind: ServiceKind.slot,
      minutes: 20,
      price: 15,
      description: 'Corte y limado de uñas con cuidado de almohadillas.',
      extras: ['ears'],
      dqIcon: 'clipper',
      dqColorHex: 0xFF1F9E8F,
    ),
    ServiceCatalogItem(
      id: 'board',
      name: 'Hospedaje',
      artKey: 'a-board',
      accent: HuAccent.lav,
      kind: ServiceKind.range,
      price: 35,
      description:
          'Habitación individual, tres paseos al día y fotos diarias por la app.',
      extras: [],
      dqIcon: 'house',
      dqColorHex: 0xFF8B7BD8,
    ),
    ServiceCatalogItem(
      id: 'walk',
      name: 'Paseo',
      artKey: 'a-walk',
      accent: HuAccent.coral,
      kind: ServiceKind.walk,
      walkPrices: {30: 20, 60: 32},
      description:
          'Paseador verificado y seguimiento en vivo con mapa, tiempo y fotos.',
      extras: [],
      dqIcon: 'walker',
      dqColorHex: 0xFF1F9E8F,
    ),
    ServiceCatalogItem(
      id: 'spa',
      name: 'Spa relajante',
      artKey: 'a-spa',
      accent: HuAccent.sky,
      kind: ServiceKind.slot,
      minutes: 45,
      price: 40,
      description:
          'Masaje, mascarilla hidratante para el pelaje y baño de burbujas.',
      extras: ['nails', 'perfume'],
      dqIcon: 'lotus',
      dqColorHex: 0xFFF2775E,
    ),
  ];

  static const Map<String, ServiceExtra> extras = {
    'nails': ServiceExtra(id: 'nails', name: 'Corte de uñas', price: 8),
    'ears': ServiceExtra(id: 'ears', name: 'Limpieza de oídos', price: 6),
    'perfume': ServiceExtra(id: 'perfume', name: 'Perfume suave', price: 4),
  };

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Croquetas premium adulto',
      brand: 'NutriHuella',
      artKey: 'a-food',
      category: 'food',
      species: [PetSpecies.dog],
      variants: [('3 kg', 19.9), ('12 kg', 54.9)],
      rating: 4.8,
      reviews: 320,
      description:
          'Con proteína de pescado y arroz, ideal para piel sensible. Sin pollo.',
    ),
    Product(
      id: 'p2',
      name: 'Paté para gatos, pack x6',
      brand: 'Miau Gourmet',
      artKey: 'a-catfood',
      category: 'food',
      species: [PetSpecies.cat],
      variants: [('Pack x6', 12.5)],
      rating: 4.7,
      reviews: 188,
      description: 'Paté de atún y salmón, con taurina. Seis latas de 85 g.',
    ),
    Product(
      id: 'p3',
      name: 'Hueso de goma resistente',
      brand: 'PlayPaw',
      artKey: 'a-bone',
      category: 'toys',
      species: [PetSpecies.dog],
      variants: [('Mediano', 9.9)],
      rating: 4.6,
      reviews: 95,
      description:
          'Goma natural para mordedores intensos. Se puede rellenar con premios.',
    ),
    Product(
      id: 'p4',
      name: 'Collar ajustable con placa',
      brand: 'Huellitas',
      artKey: 'a-collar',
      category: 'acc',
      species: [PetSpecies.dog, PetSpecies.cat],
      variants: [('S', 12.5), ('M', 14.5), ('L', 16.5)],
      rating: 4.9,
      reviews: 142,
      description:
          'Nylon suave y placa grabable con el nombre y tu teléfono.',
    ),
    Product(
      id: 'p5',
      name: 'Shampoo de avena y aloe',
      brand: 'PetSpa',
      artKey: 'a-shampoo',
      category: 'hyg',
      species: [PetSpecies.dog, PetSpecies.cat],
      variants: [('500 ml', 12.9)],
      rating: 4.7,
      reviews: 210,
      description:
          'pH balanceado, sin parabenos. Calma la piel y deja el pelaje brillante.',
    ),
    Product(
      id: 'p6',
      name: 'Arena aglomerante 10 kg',
      brand: 'Miau Gourmet',
      artKey: 'a-litter',
      category: 'hyg',
      species: [PetSpecies.cat],
      variants: [('10 kg', 18.9)],
      rating: 4.5,
      reviews: 260,
      description: 'Control de olores por 15 días. Sin polvo.',
    ),
    Product(
      id: 'p7',
      name: 'Snacks dentales',
      brand: 'NutriHuella',
      artKey: 'a-treats',
      category: 'food',
      species: [PetSpecies.dog],
      variants: [('Frasco 300 g', 7.5)],
      rating: 4.6,
      reviews: 133,
      description: 'Ayudan a reducir el sarro. Sabor menta y perejil.',
    ),
    Product(
      id: 'p8',
      name: 'Cama redonda acolchada',
      brand: 'Huellitas',
      artKey: 'a-bed',
      category: 'acc',
      species: [PetSpecies.dog, PetSpecies.cat],
      variants: [('M', 39.9), ('L', 49.9)],
      rating: 4.9,
      reviews: 77,
      description: 'Borde alto para apoyar la cabeza y funda lavable.',
    ),
  ];

  static const List<(String key, String label)> productCategories = [
    ('all', 'Todo'),
    ('food', 'Alimento'),
    ('toys', 'Juguetes'),
    ('hyg', 'Higiene'),
    ('acc', 'Accesorios'),
  ];

  static const Map<PetSpecies, List<String>> breeds = {
    PetSpecies.dog: [
      'Mestizo',
      'Golden Retriever',
      'Labrador',
      'Poodle',
      'Shih Tzu',
      'Bulldog francés',
      'Schnauzer',
      'Beagle',
      'Chihuahua',
      'Pastor alemán',
    ],
    PetSpecies.cat: [
      'Mestizo',
      'Atigrado',
      'Siamés',
      'Persa',
      'Maine Coon',
      'Bengalí',
      'Ragdoll',
    ],
    PetSpecies.other: [
      'Conejo',
      'Hámster',
      'Cuy',
      'Hurón',
      'Tortuga',
    ],
  };

  static const List<(String author, int stars, String text, String when)> vetReviews = [
    (
      'Andrea M.',
      5,
      'Se tomó el tiempo de explicarnos todo. Nuestra perrita salió feliz.',
      'hace 1 semana',
    ),
    (
      'Jorge P.',
      5,
      'Muy cariñosa con los animales y muy clara con el tratamiento.',
      'hace 3 semanas',
    ),
    (
      'Carla V.',
      4,
      'Excelente atención, aunque hubo un poco de espera.',
      'hace 1 mes',
    ),
  ];

  static const List<SavedAddress> addresses = [
    SavedAddress(
      name: 'Casa',
      address: 'Calle Los Pinos 123, depto. 402',
      isDefault: true,
    ),
    SavedAddress(
      name: 'Trabajo',
      address: 'Av. Central 500, piso 7',
    ),
  ];

  static const List<SavedCard> cards = [
    SavedCard(brand: 'Visa', last4: '4242', isDefault: true),
  ];

  static Clinic clinicById(String id) =>
      clinics.firstWhere((c) => c.id == id, orElse: () => clinics.first);

  static Vet vetById(String id) =>
      vets.firstWhere((v) => v.id == id, orElse: () => vets.first);

  static VisitType visitTypeById(String id) =>
      visitTypes.firstWhere((t) => t.id == id, orElse: () => visitTypes.first);

  static ServiceCatalogItem serviceById(String id) =>
      services.firstWhere((s) => s.id == id, orElse: () => services.first);

  static Walker walkerById(String id) =>
      walkers.firstWhere((w) => w.id == id, orElse: () => walkers.first);

  static Product productById(String id) =>
      products.firstWhere((p) => p.id == id, orElse: () => products.first);

  static List<Pet> mkPets(DateTime today) {
    String rd(int n) => HuFormat.rd(today, n);
    return [
      Pet(
        id: 'milo',
        name: 'Milo',
        species: PetSpecies.dog,
        artKey: 'a-dog',
        accent: HuAccent.teal,
        breed: 'Golden Retriever',
        sex: 'Macho',
        birthDate: rd(-2 * 365 - 40),
        weightKg: 24.6,
        weightHistory: const [21.8, 22.4, 22.9, 23.3, 23.8, 24.1, 24.4, 24.6],
        chip: '985 112 004 556 781',
        neutered: true,
        allergies: const ['Pollo'],
        activity: 78,
        appetite: 'Bien',
        mood: 'Feliz',
        vetId: 'sofia',
        vaccines: [
          Vaccine(name: 'Rabia', appliedOn: rd(-330), nextDue: rd(35)),
          Vaccine(
            name: 'Séxtuple (DHPPi+L)',
            appliedOn: rd(-200),
            nextDue: rd(165),
          ),
          Vaccine(name: 'Bordetella', appliedOn: rd(-353), nextDue: rd(12)),
          Vaccine(
            name: 'Desparasitación interna',
            appliedOn: rd(-60),
            nextDue: rd(30),
            isDeworming: true,
          ),
          Vaccine(
            name: 'Antipulgas (pipeta)',
            appliedOn: rd(-32),
            nextDue: rd(-2),
            isDeworming: true,
          ),
        ],
        history: [
          HistoryEntry(
            date: rd(-40),
            type: 'Consulta general',
            vetId: 'sofia',
            diagnosis: 'Otitis leve en la oreja derecha.',
            treatment: 'Gotas óticas cada 12 horas durante 7 días.',
            documentLabel: 'Receta',
          ),
          HistoryEntry(
            date: rd(-200),
            type: 'Vacunación',
            vetId: 'sofia',
            diagnosis: 'Vacuna séxtuple aplicada sin reacciones.',
            treatment: 'Sin indicaciones.',
          ),
          HistoryEntry(
            date: rd(-260),
            type: 'Piel y alergias',
            vetId: 'andres',
            diagnosis: 'Dermatitis por alergia alimentaria.',
            treatment: 'Dieta sin pollo. Control en 2 meses.',
            documentLabel: 'Informe',
          ),
        ],
      ),
      Pet(
        id: 'luna',
        name: 'Luna',
        species: PetSpecies.cat,
        artKey: 'a-cat',
        accent: HuAccent.coral,
        breed: 'Atigrado',
        sex: 'Hembra',
        birthDate: rd(-365 - 75),
        weightKg: 4.1,
        weightHistory: const [3.1, 3.4, 3.6, 3.8, 3.9, 4.0, 4.0, 4.1],
        chip: '985 112 004 771 203',
        neutered: true,
        allergies: const [],
        activity: 64,
        appetite: 'Bien',
        mood: 'Tranquila',
        vetId: 'camila',
        vaccines: [
          Vaccine(name: 'Triple felina', appliedOn: rd(-300), nextDue: rd(65)),
          Vaccine(name: 'Rabia', appliedOn: rd(-362), nextDue: rd(3)),
          Vaccine(
            name: 'Desparasitación interna',
            appliedOn: rd(-45),
            nextDue: rd(45),
            isDeworming: true,
          ),
        ],
        history: [
          HistoryEntry(
            date: rd(-30),
            type: 'Baño y corte',
            diagnosis: 'Servicio de grooming. Se portó muy bien.',
            treatment: 'Sin indicaciones.',
          ),
          HistoryEntry(
            date: rd(-300),
            type: 'Vacunación',
            vetId: 'camila',
            diagnosis: 'Triple felina aplicada.',
            treatment: 'Sin indicaciones.',
          ),
        ],
      ),
    ];
  }

  static List<Appointment> mkAppointments(DateTime today) {
    String rd(int n) => HuFormat.rd(today, n);
    return [
      Appointment(
        id: 'HU-4097',
        kind: AppointmentKind.vet,
        petId: 'milo',
        typeId: 'check',
        vetId: 'sofia',
        clinicId: 'c1',
        date: rd(3),
        time: '10:30',
        status: AppointmentStatus.confirmed,
        price: 35,
        note: 'Control de la otitis.',
      ),
      Appointment(
        id: 'HU-4098',
        kind: AppointmentKind.vet,
        petId: 'luna',
        typeId: 'vac',
        vetId: 'camila',
        clinicId: 'c1',
        date: rd(3),
        time: '16:00',
        status: AppointmentStatus.confirmed,
        price: 25,
      ),
      Appointment(
        id: 'HU-4099',
        kind: AppointmentKind.svc,
        petId: 'milo',
        serviceId: 'groom',
        date: rd(6),
        time: '11:00',
        status: AppointmentStatus.confirmed,
        price: 53,
        size: 'M',
        extras: const ['nails'],
      ),
      Appointment(
        id: 'HU-4041',
        kind: AppointmentKind.vet,
        petId: 'milo',
        typeId: 'derm',
        vetId: 'andres',
        clinicId: 'c2',
        date: rd(-260),
        time: '09:30',
        status: AppointmentStatus.done,
        price: 45,
      ),
      Appointment(
        id: 'HU-4072',
        kind: AppointmentKind.svc,
        petId: 'luna',
        serviceId: 'groom',
        date: rd(-30),
        time: '15:00',
        status: AppointmentStatus.done,
        price: 35,
        size: 'S',
      ),
      Appointment(
        id: 'HU-4080',
        kind: AppointmentKind.vet,
        petId: 'milo',
        typeId: 'check',
        vetId: 'sofia',
        clinicId: 'c1',
        date: rd(-40),
        time: '10:00',
        status: AppointmentStatus.done,
        price: 35,
      ),
    ];
  }

  static List<Reminder> mkReminders(DateTime today) {
    String rd(int n) => HuFormat.rd(today, n);
    return [
      Reminder(
        id: 1,
        type: 'med',
        petId: 'milo',
        title: 'Gotas para la oreja',
        subtitle: 'Cada 12 horas · 8:00 y 20:00',
        date: rd(0),
        time: '20:00',
        repeat: 'Diario',
      ),
      Reminder(
        id: 2,
        type: 'dew',
        petId: 'milo',
        title: 'Antipulgas (pipeta)',
        subtitle: 'Mensual',
        date: rd(-2),
        time: '09:00',
        repeat: 'Mensual',
      ),
      Reminder(
        id: 3,
        type: 'vac',
        petId: 'luna',
        title: 'Vacuna de la rabia',
        subtitle: 'Cita con la Dra. Camila',
        date: rd(3),
        time: '16:00',
        repeat: 'Anual',
      ),
      Reminder(
        id: 4,
        type: 'bath',
        petId: 'milo',
        title: 'Cepillado',
        subtitle: 'Dos veces por semana',
        date: rd(1),
        time: '18:00',
        repeat: 'Semanal',
      ),
      Reminder(
        id: 5,
        type: 'food',
        petId: 'luna',
        title: 'Comprar arena',
        subtitle: 'Queda para unos días',
        date: rd(-1),
        time: '12:00',
        repeat: 'No se repite',
        done: true,
      ),
    ];
  }

  static List<AppNotification> mkNotifications(DateTime today) {
    String rd(int n) => HuFormat.rd(today, n);
    return [
      AppNotification(
        id: 1,
        icon: 'i-syringe',
        accent: HuAccent.lav,
        title: 'La vacuna de Luna está cerca',
        subtitle:
            'Le toca la rabia ${HuFormat.rel(today, rd(3))}. Ya tienes cita con la Dra. Camila.',
        whenLabel: 'Hace 1 h',
        unread: true,
        targetKind: 'appt',
        targetId: 'HU-4098',
      ),
      const AppNotification(
        id: 2,
        icon: 'i-chat',
        accent: HuAccent.teal,
        title: 'Nuevo mensaje de la Dra. Sofía',
        subtitle:
            '«¡Qué bueno! Termina los 7 días de gotas y lo vemos en el control.»',
        whenLabel: 'Hace 2 h',
        unread: true,
        targetKind: 'chat',
        targetId: 'sofia',
      ),
      const AppNotification(
        id: 3,
        icon: 'i-pill',
        accent: HuAccent.coral,
        title: 'Antipulgas de Milo vencido',
        subtitle: 'Le tocaba hace 2 días. Márcalo cuando se lo pongas.',
        whenLabel: 'Ayer',
        unread: false,
        targetKind: 'rem',
      ),
      const AppNotification(
        id: 4,
        icon: 'i-bag',
        accent: HuAccent.sun,
        title: 'Envío gratis desde \$50',
        subtitle: 'En toda la tienda, hasta fin de mes.',
        whenLabel: 'Hace 3 días',
        unread: false,
        targetKind: 'shop',
      ),
    ];
  }

  static List<ChatThread> mkThreads() => const [
        ChatThread(
          id: 'sofia',
          who: 'vet',
          refId: 'sofia',
          petId: 'milo',
          unread: 1,
          messages: [
            ChatMessage(
              fromMe: false,
              text: '¡Hola, Michael! ¿Cómo se siente Milo hoy?',
              time: '10:30',
            ),
            ChatMessage(
              fromMe: true,
              text:
                  '¡Hola, doctora! Milo está un poco menos activo hoy y no está comiendo mucho.',
              time: '10:32',
            ),
            ChatMessage(
              fromMe: false,
              text:
                  'Gracias por avisarme. Vamos a observarlo. Si sigue así, quizá necesite un control.',
              time: '10:33',
            ),
          ],
        ),
        ChatThread(
          id: 'diego',
          who: 'walker',
          refId: 'diego',
          petId: 'milo',
          unread: 0,
          messages: [
            ChatMessage(
              fromMe: false,
              text: 'Hola, mañana paso por Milo a las 4 p. m. para su paseo.',
              time: 'Ayer',
            ),
            ChatMessage(
              fromMe: true,
              text: '¡Perfecto, gracias Diego!',
              time: 'Ayer',
            ),
          ],
        ),
        ChatThread(
          id: 'c1',
          who: 'clinic',
          refId: 'c1',
          petId: 'luna',
          unread: 0,
          messages: [
            ChatMessage(
              fromMe: false,
              text:
                  'Te recordamos que Luna tiene cita de vacunación. Llega 10 minutos antes, por favor.',
              time: 'Lun',
            ),
          ],
        ),
      ];

  static List<Order> mkOrders(DateTime today) => [
        Order(
          id: 'PED-2210',
          date: HuFormat.rd(today, -12),
          items: 2,
          total: 67.4,
          status: 'Entregado',
        ),
      ];

  static String appointmentTitle(Appointment a) => a.kind == AppointmentKind.vet
      ? visitTypeById(a.typeId ?? 'check').name
      : serviceById(a.serviceId ?? 'groom').name;

  static String appointmentPlace(Appointment a) {
    if (a.kind == AppointmentKind.vet) {
      return a.typeId == 'video'
          ? 'Videollamada'
          : clinicById(a.clinicId).name;
    }
    if (a.serviceId == 'walk') return 'Recojo en tu casa';
    if (a.pickup) return 'Recojo a domicilio';
    return 'Huellitas Centro';
  }

  static String appointmentWho(Appointment a) {
    if (a.kind == AppointmentKind.vet) {
      return vetById(a.vetId ?? 'sofia').shortName;
    }
    if (a.walkerId != null) {
      return walkerById(a.walkerId!).firstName;
    }
    return 'Equipo de grooming';
  }

  /// Próxima vacuna pendiente (no desparasitación) entre todas las mascotas, igual que `soon` en HTML.
  static ({Pet pet, Vaccine vaccine})? nextDueVaccine(
    DateTime today,
    List<Pet> pets,
  ) {
    final candidates = <({Pet pet, Vaccine vaccine})>[];
    for (final p in pets) {
      for (final v in p.vaccines) {
        if (!v.isDeworming &&
            PetHealthRules.vaccineState(today, v) != VaccineState.ok) {
          candidates.add((pet: p, vaccine: v));
        }
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a.vaccine.nextDue.compareTo(b.vaccine.nextDue));
    return candidates.first;
  }
}
