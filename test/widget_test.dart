import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:huellitas/app/app.dart';
import 'package:huellitas/app/di.dart';
import 'package:huellitas/core/data/demo_data.dart';
import 'package:huellitas/core/domain/models.dart';
import 'package:huellitas/core/domain/rules.dart';
import 'package:huellitas/core/format/hu_format.dart';
import 'package:huellitas/core/theme/hu_tokens.dart';
import 'package:huellitas/core/utils/clock.dart';
import 'package:huellitas/core/utils/stable_hash.dart';
import 'package:huellitas/features/appointments/appointments_bloc.dart';
import 'package:huellitas/features/booking/booking_bloc.dart';
import 'package:huellitas/features/pets/pet_wizard_bloc.dart';
import 'package:huellitas/features/shop/cart_bloc.dart';
import 'package:huellitas/features/shop/checkout_bloc.dart';
import 'package:huellitas/features/walk/live_walk_bloc.dart';

class _MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;
  final fixedClock = FixedClock.demo; // Sábado 14 de noviembre de 2026, 3:30 p. m.
  final today = fixedClock.today;

  setUp(() {
    storage = _MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    when(() => storage.read(any())).thenReturn(null);
    when(() => storage.delete(any())).thenAnswer((_) async {});
    when(() => storage.clear()).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
    setupDi(clock: fixedClock);
  });

  group('Dominio y reglas de negocio (Sección 9)', () {
    test('healthScore y healthTag de Milo (86, Saludable) y Luna (94, Saludable)', () {
      final pets = DemoData.mkPets(today);
      final milo = pets[0];
      final luna = pets[1];

      final miloScore = PetHealthRules.healthScore(today, milo);
      final (miloTag, miloAccent) = PetHealthRules.healthTag(miloScore);
      expect(miloScore, 86);
      expect(miloTag, 'Saludable');
      expect(miloAccent, HuAccent.ok);

      final lunaScore = PetHealthRules.healthScore(today, luna);
      final (lunaTag, lunaAccent) = PetHealthRules.healthTag(lunaScore);
      expect(lunaScore, 94);
      expect(lunaTag, 'Saludable');
      expect(lunaAccent, HuAccent.ok);
    });

    test('vaccineState en los límites de -1, 0, 14 y 15 días', () {
      Vaccine vAt(int days) => Vaccine(
            name: 'Test',
            appliedOn: HuFormat.rd(today, -300),
            nextDue: HuFormat.rd(today, days),
          );

      expect(PetHealthRules.vaccineState(today, vAt(-1)), VaccineState.late);
      expect(PetHealthRules.vaccineState(today, vAt(0)), VaccineState.next);
      expect(PetHealthRules.vaccineState(today, vAt(14)), VaccineState.next);
      expect(PetHealthRules.vaccineState(today, vAt(15)), VaccineState.ok);
    });

    test('AvailabilityService: FNV-1a idéntico al HTML, sin horas pasadas hoy y fecha por defecto', () {
      final avail = AvailabilityService(clock: fixedClock);
      final appts = DemoData.mkAppointments(today);
      final c1 = DemoData.clinicById('c1');

      // Hoy (15:30 = 930 min): no devuelve horas que empiezan antes de ahora + 60 min (990 = 16:30)
      final todaySlots = avail.slotsFor(
        key: 'sofia',
        clinic: c1,
        dateIso: '2026-11-14',
        durationMinutes: 30,
        appointments: appts,
      )!;
      expect(todaySlots.every((s) => s.minutes >= 990), isTrue);

      // Lunes 16 de noviembre para sofia en Huellitas Centro (c1)
      final monSlots = avail.slotsFor(
        key: 'sofia',
        clinic: c1,
        dateIso: '2026-11-16',
        durationMinutes: 30,
        appointments: appts,
      )!;
      expect(monSlots.first.minutes, 540); // 9:00 a. m.
      expect(monSlots.last.minutes, 1110); // 6:30 p. m.
      for (final sl in monSlots) {
        final expectedTaken =
            stableHash('2026-11-16sofia${sl.minutes}') % 100 < 36;
        expect(sl.taken, expectedTaken);
      }

      // Fecha por defecto: primer día con >= 4 horas libres
      final defDate = avail.defaultDate(
        key: 'sofia',
        clinic: c1,
        durationMinutes: 30,
        appointments: appts,
      );
      expect(defDate, isNotNull);
      expect(
        avail.freeCount(
          key: 'sofia',
          clinic: c1,
          dateIso: defDate!,
          durationMinutes: 30,
          appointments: appts,
        ),
        greaterThanOrEqualTo(4),
      );
    });

    test('Política de 12 horas y cargo de \$10', () {
      // Sábado 14 nov 15:30 -> cita el mismo día a las 20:00 (faltan 4.5 h)
      expect(
        BookingPricingRules.isWithin12Hours(
          fixedClock.now(),
          '2026-11-14',
          '20:00',
        ),
        isTrue,
      );
      expect(
        BookingPricingRules.cancellationFee(
          fixedClock.now(),
          '2026-11-14',
          '20:00',
        ),
        10.0,
      );

      // Cita el martes 17 nov a las 10:30 (faltan > 12 h)
      expect(
        BookingPricingRules.isWithin12Hours(
          fixedClock.now(),
          '2026-11-17',
          '10:30',
        ),
        isFalse,
      );
      expect(
        BookingPricingRules.cancellationFee(
          fixedClock.now(),
          '2026-11-17',
          '10:30',
        ),
        0.0,
      );
    });

    test('Precios de servicio con tamaño, extras y recojo; hospedaje 3 noches = \$105', () {
      final groom = DemoData.serviceById('groom');
      final board = DemoData.serviceById('board');

      // Baño y corte M ($45) + uñas ($8) + recojo ($8) = $61
      expect(
        BookingPricingRules.serviceTotal(
          service: groom,
          size: 'M',
          durationMinutes: 60,
          nights: 0,
          extras: const {'nails'},
          extrasCatalog: DemoData.extras,
          pickup: true,
        ),
        61.0,
      );

      // Hospedaje de 3 noches = $105
      expect(
        BookingPricingRules.serviceTotal(
          service: board,
          size: 'M',
          durationMinutes: 30,
          nights: 3,
          extras: const {},
          extrasCatalog: DemoData.extras,
          pickup: false,
        ),
        105.0,
      );
    });

    test('Envío: \$49.99 -> \$4.99; \$50 -> gratis; express \$9.99', () {
      expect(
        BookingPricingRules.shippingFee(subtotal: 49.99, express: false),
        4.99,
      );
      expect(
        BookingPricingRules.shippingFee(subtotal: 50.0, express: false),
        0.0,
      );
      expect(
        BookingPricingRules.shippingFee(subtotal: 80.0, express: true),
        9.99,
      );
    });
  });

  group('BLoCs principales (Sección 9)', () {
    test('BookingBloc: valores por defecto, recalcular vet al cambiar tipo y reiniciar fecha al cambiar vet', () {
      final pets = DemoData.mkPets(today);
      final appts = DemoData.mkAppointments(today);
      final bloc = BookingBloc(clock: fixedClock);

      bloc.add(BookingStarted(pets: pets, appointments: appts));
      return Future<void>.delayed(Duration.zero, () {
        expect(bloc.state.petId, 'milo');
        expect(bloc.state.typeId, 'check');
        expect(bloc.state.vetId, isNotNull);
        expect(bloc.state.selectedDate, isNotNull);
        expect(bloc.state.selectedTime, isNotNull);

        // Cambiar a Piel y alergias ('derm') -> único vet es 'andres'
        bloc.add(BookingTypeChanged(
          typeId: 'derm',
          pets: pets,
          appointments: appts,
        ));
      }).then((_) => Future<void>.delayed(Duration.zero, () {
            expect(bloc.state.vetId, 'andres');
          }));
    });

    blocTest<PetWizardBloc, PetWizardState>(
      'PetWizardBloc valida cada paso y crea la mascota en el paso 5',
      build: PetWizardBloc.new,
      act: (bloc) {
        bloc
          ..add(const PetWizardStarted(isFirstPet: false))
          ..add(const PetWizardSpeciesSelected(PetSpecies.dog))
          ..add(const PetWizardNextPressed(existingPetCount: 2))
          ..add(const PetWizardNameChanged('Rocky'))
          ..add(const PetWizardNextPressed(existingPetCount: 2))
          ..add(const PetWizardBreedChanged('Labrador'))
          ..add(const PetWizardBirthDateChanged('2025-05-10'))
          ..add(const PetWizardSexSelected('Macho'))
          ..add(const PetWizardNextPressed(existingPetCount: 2))
          ..add(const PetWizardWeightChanged('18.4'))
          ..add(const PetWizardNeuteredSelected(true))
          ..add(const PetWizardNextPressed(existingPetCount: 2));
      },
      verify: (bloc) {
        expect(bloc.state.step, 5);
        expect(bloc.state.createdPet?.name, 'Rocky');
        expect(bloc.state.createdPet?.weightKg, 18.4);
      },
    );

    blocTest<CartBloc, CartState>(
      'CartBloc agrega, quita y restaura con deshacer',
      build: () => CartBloc(clock: fixedClock),
      act: (bloc) {
        bloc
          ..add(const CartItemAdded(productId: 'p1', variantIndex: 1, qty: 1))
          ..add(const CartItemRemoved(0))
          ..add(const CartItemRestored(
            index: 0,
            line: CartLine(productId: 'p1', variantIndex: 1, qty: 1),
          ));
      },
      verify: (bloc) {
        expect(bloc.state.lines.length, 1);
        expect(bloc.state.subtotal, 54.9);
        expect(bloc.state.remainingForFreeShipping, 0.0);
      },
    );

    test('CheckoutBloc transiciona idle -> paying -> paid', () {
      fakeAsync((async) {
        final bloc = CheckoutBloc();
        expect(bloc.state.phase, CheckoutPhase.idle);
        bloc.add(const CheckoutPayRequested());
        async.elapse(const Duration(milliseconds: 100));
        expect(bloc.state.phase, CheckoutPhase.paying);
        async.elapse(const Duration(milliseconds: 1200));
        expect(bloc.state.phase, CheckoutPhase.paid);
        bloc.close();
      });
    });

    test('LiveWalkBloc avanza con el ticker y agrega evento al pasar de 0.55', () {
      fakeAsync((async) {
        final bloc = LiveWalkBloc(clock: fixedClock)
          ..add(const LiveWalkStarted())
          ..add(const LiveWalkTickerStarted());
        async.elapse(const Duration(seconds: 15));
        expect(bloc.state.walk!.progress, greaterThan(0.55));
        expect(bloc.state.walk!.events.length, 2);
        bloc.close();
      });
    });

    blocTest<AppointmentsBloc, AppointmentsState>(
      'AppointmentsBloc reprograma y cancela citas',
      build: () => AppointmentsBloc(clock: fixedClock),
      act: (bloc) {
        bloc
          ..add(const AppointmentRescheduled(
            appointmentId: 'HU-4097',
            newDate: '2026-11-20',
            newTime: '11:30',
          ))
          ..add(const AppointmentCancelled('HU-4098', reason: 'No puedo ir'));
      },
      verify: (bloc) {
        expect(bloc.state.byId('HU-4097')?.date, '2026-11-20');
        expect(bloc.state.byId('HU-4097')?.time, '11:30');
        expect(
          bloc.state.byId('HU-4098')?.status,
          AppointmentStatus.cancelled,
        );
      },
    );
  });

  testWidgets('Aceptación UI: Inicio y Perfil en español con Michael Dev (michaeldev@gmail.com)', (tester) async {
    await tester.pumpWidget(const HuellitasApp(initialRoute: '/home'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Michael! 👋'), findsOneWidget);
    expect(find.text('¿Cómo cuidamos hoy a tu mascota?'), findsOneWidget);
    expect(find.text('Milo'), findsWidgets);
    expect(find.text('Luna'), findsWidgets);

    // Ir a la pestaña Perfil
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Michael Dev'), findsOneWidget);
    expect(find.text('michaeldev@gmail.com'), findsOneWidget);
  });
}
