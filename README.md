<div align="center">

<img src="assets/logo/huellitas_app_icon.png" alt="Huellitas" width="110" />

# Huellitas

**Cuidamos a quien te cuida** — cuidado de mascotas en un solo lugar.

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.13-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/state-BLoC-1F9E8B)
![Routing](https://img.shields.io/badge/routing-go__router-F4735E)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-lightgrey?logo=apple&logoColor=white)
![Locale](https://img.shields.io/badge/idioma-es__419-yellow)
![Tests](https://img.shields.io/badge/tests-widget%20%2B%20golden-success)
![Version](https://img.shields.io/badge/version-1.0.0-blue)

</div>

---

Aplicación en **Flutter + BLoC** para dueños de mascotas, fiel al prototipo `huellitas-prototipo.html` y escrita en español neutro (`es_419`). Reúne la ficha de cada mascota, citas veterinarias, servicios (baños, paseos, grooming), tienda, recordatorios y mensajería.

## Capturas

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/01-splash.png" width="200" /><br/><sub>Splash</sub></td>
    <td align="center"><img src="docs/screenshots/02-onboarding.png" width="200" /><br/><sub>Onboarding · Mascota</sub></td>
    <td align="center"><img src="docs/screenshots/03-onboarding-citas.png" width="200" /><br/><sub>Onboarding · Servicios</sub></td>
    <td align="center"><img src="docs/screenshots/04-login.png" width="200" /><br/><sub>Inicio de sesión</sub></td>
    <td align="center"><img src="docs/screenshots/05-home.png" width="200" /><br/><sub>Inicio</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/06-citas.png" width="200" /><br/><sub>Citas</sub></td>
    <td align="center"><img src="docs/screenshots/07-mascotas.png" width="200" /><br/><sub>Mascotas</sub></td>
    <td align="center"><img src="docs/screenshots/08-mensajes.png" width="200" /><br/><sub>Mensajes</sub></td>
    <td align="center"><img src="docs/screenshots/09-perfil.png" width="200" /><br/><sub>Perfil</sub></td>
    <td></td>
  </tr>
</table>

## Funcionalidades

- **Mascotas:** ficha, salud (anillo de salud), peso, vacunas y asistente de alta.
- **Citas:** reserva con veterinario, detalle y recordatorios.
- **Veterinarios cercanos:** mapa ilustrado y perfil del vet.
- **Servicios:** baños, grooming, paseos con seguimiento **en vivo**.
- **Tienda:** catálogo, carrito y checkout.
- **Mensajes y notificaciones**, y pantalla de **SOS** de emergencia.

## Arquitectura y stack

| Capa | Tecnología |
| --- | --- |
| UI y tema | `material_ui`, `HuTokens` (`ThemeExtension<HuTokens>`), `HuAccent`, tipografía **Poppins** |
| Estado y persistencia | `flutter_bloc`, `hydrated_bloc`, `equatable` |
| Navegación | `go_router` con `StatefulShellRoute.indexedStack` (Inicio, Citas, Mascotas, Mensajes, Perfil) |
| Inyección | `get_it` (`Clock`, `Toaster`) |
| Gráficos | Ilustraciones y avatares 3D, íconos SVG y `CustomPainter` (`IllustratedMap`, `WeightChart`, `HealthRing`, `PawBurst`) |
| Pruebas | `flutter_test`, `bloc_test`, `mocktail`, `fake_async`, `alchemist` |

### Estructura

```
lib/
├── app/         # DI, router, shell de navegación y raíz de la app
├── core/        # tema, dominio, datos demo, formato y widgets compartidos
└── features/    # auth, onboarding, pets, home, vets, booking, appointments,
                 # services, walk, chat, reminders, notifications, shop, sos, profile
```

## Ejecución

Requiere Flutter con Dart `^3.13.4`.

```bash
flutter pub get
flutter run
flutter test
```

> La app usa datos de demostración locales; no se conecta a ningún backend.

## Autor

**Michael Valdiviezo** — [@VMichael1999](https://github.com/VMichael1999)
