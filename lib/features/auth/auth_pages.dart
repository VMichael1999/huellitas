import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../chat/chat_bloc.dart';
import '../notifications/notifications_cubit.dart';
import '../pets/pet_wizard_bloc.dart';
import '../pets/pets_bloc.dart';
import '../reminders/reminders_bloc.dart';
import 'session_bloc.dart';

bool _isValidEmail(String s) => RegExp(r'^\S+@\S+\.\S+$').hasMatch(s.trim());

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mailCtrl = TextEditingController(text: 'michaeldev@gmail.com');
  final _passCtrl = TextEditingController(text: 'huellitas26');
  bool _obscure = true;
  bool _mailErr = false;
  bool _passErr = false;
  bool _loading = false;

  @override
  void dispose() {
    _mailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final m = _mailCtrl.text.trim();
    final p = _passCtrl.text;
    setState(() {
      _mailErr = !_isValidEmail(m);
      _passErr = p.length < 6;
    });
    if (_mailErr || _passErr) {
      getIt<Toaster>().show('Revisa tu correo y tu contraseña.');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<SessionBloc>().add(SessionLoggedIn(mail: m));
    final firstName = context.read<SessionBloc>().state.user.firstName;
    context.go('/home');
    getIt<Toaster>().show('¡Hola, $firstName!');
  }

  void _openForgotSheet() {
    final forgotCtrl = TextEditingController(text: _mailCtrl.text.trim());
    bool err = false;
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recupera tu contraseña',
                  style: t.style(23, FontWeight.w600, t.ink, 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Te enviamos un enlace a tu correo para crear una nueva.',
                  style: t.style(14.5, FontWeight.w400, t.ink2),
                ),
                const SizedBox(height: 16),
                HuTextField(
                  controller: forgotCtrl,
                  prefixIcon: 'i-mail',
                  placeholder: 'Correo',
                  keyboardType: TextInputType.emailAddress,
                  hasError: err,
                ),
                const SizedBox(height: 4),
                HuButton(
                  label: 'Enviar enlace',
                  onPressed: () {
                    final m = forgotCtrl.text.trim();
                    if (!_isValidEmail(m)) {
                      setSheetState(() => err = true);
                      getIt<Toaster>().show('Escribe un correo válido.');
                      return;
                    }
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show('Te enviamos el enlace a $m.');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera ilustrada .auth-h
            Container(
              height: 290,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7AD4C8), Color(0xFF1F9E8F)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned(
                    right: -60,
                    top: -60,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    top: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const HuIcon(
                          'i-paw',
                          size: 30,
                          color: Colors.white,
                          fill: Colors.white,
                          strokeWidth: 0,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Huellitas',
                          style: t.style(30, FontWeight.w700, Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: -10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        HuArt('a-dog', width: 150, height: 150),
                        HuArt('a-cat', width: 150, height: 150),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola de nuevo!', style: t.h1Large),
                  const SizedBox(height: 4),
                  Text(
                    'Entra para ver a tus mascotas y sus citas.',
                    style: t.style(14.5, FontWeight.w400, t.ink2),
                  ),
                  const SizedBox(height: 20),
                  HuTextField(
                    controller: _mailCtrl,
                    prefixIcon: 'i-mail',
                    placeholder: 'Correo',
                    keyboardType: TextInputType.emailAddress,
                    hasError: _mailErr,
                  ),
                  HuTextField(
                    controller: _passCtrl,
                    prefixIcon: 'i-lock',
                    placeholder: 'Contraseña',
                    obscureText: _obscure,
                    hasError: _passErr,
                    suffix: HuPressable(
                      onTap: () => setState(() => _obscure = !_obscure),
                      semanticLabel: 'Mostrar contraseña',
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: HuIcon(
                          _obscure ? 'i-eye' : 'i-eyeoff',
                          size: 22,
                          color: t.ink3,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: HuButton(
                      label: '¿Olvidaste tu contraseña?',
                      variant: HuButtonVariant.link,
                      onPressed: _openForgotSheet,
                    ),
                  ),
                  const SizedBox(height: 4),
                  HuButton(
                    label: _loading ? 'Entrando…' : 'Iniciar sesión',
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: t.line, height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'o continúa con',
                            style: t.style(13, FontWeight.w500, t.ink3),
                          ),
                        ),
                        Expanded(child: Divider(color: t.line, height: 1)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      for (final provider in ['Google', 'Apple']) ...[
                        if (provider == 'Apple') const SizedBox(width: 12),
                        Expanded(
                          child: HuPressable(
                            onTap: () {
                              context
                                  .read<SessionBloc>()
                                  .add(const SessionLoggedIn());
                              context.go('/home');
                              getIt<Toaster>().show('Entraste con $provider.');
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: t.line, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/brands/${provider.toLowerCase()}.png',
                                    height: 20,
                                    semanticLabel: provider,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    provider,
                                    style:
                                        t.style(14.5, FontWeight.w600, t.ink),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Primera vez? ',
                        style: t.style(14, FontWeight.w600, t.ink2),
                      ),
                      HuButton(
                        label: 'Crea tu cuenta',
                        variant: HuButtonVariant.link,
                        onPressed: () => context.push('/signup'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _nameErr = false;
  bool _phoneErr = false;
  bool _mailErr = false;
  bool _passErr = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _mailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final n = _nameCtrl.text.trim();
    final ph = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final m = _mailCtrl.text.trim();
    final p = _passCtrl.text;

    final badName = n.split(' ').where((w) => w.isNotEmpty).length < 2;
    final badPhone = ph.length < 7;
    final badMail = !_isValidEmail(m);
    final badPass = p.length < 8;

    setState(() {
      _nameErr = badName;
      _phoneErr = badPhone;
      _mailErr = badMail;
      _passErr = badPass;
    });

    if (badName || badPhone || badMail || badPass) {
      if (badPass && !badName && !badMail) {
        getIt<Toaster>().show('La contraseña necesita al menos 8 caracteres.');
      } else {
        getIt<Toaster>().show('Completa los campos marcados.');
      }
      return;
    }

    context.read<SessionBloc>().add(SessionRegistered(
          name: n,
          phone: _phoneCtrl.text.trim(),
          mail: m,
        ));
    context.read<PetsBloc>().add(const PetsReset(empty: true));
    context.read<AppointmentsBloc>().add(const AppointmentsReset(empty: true));
    context.read<RemindersBloc>().add(const RemindersReset(empty: true));
    context.read<ChatBloc>().add(const ChatReset(empty: true));
    context.read<NotificationsCubit>().reset(empty: true);
    context.read<PetWizardBloc>().add(const PetWizardStarted(isFirstPet: true));
    context.push('/pet/new');
    getIt<Toaster>().show('Cuenta creada. ¡Bienvenido, ${n.split(' ').first}!');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuScaffold(
      topBar: HuTopBar(
        title: '',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crea tu cuenta', style: t.h1Large),
            const SizedBox(height: 4),
            Text(
              'Después registramos a tu primera mascota.',
              style: t.style(14.5, FontWeight.w400, t.ink2),
            ),
            const SizedBox(height: 20),
            HuTextField(
              controller: _nameCtrl,
              prefixIcon: 'i-user',
              placeholder: 'Nombre y apellido',
              hasError: _nameErr,
            ),
            HuTextField(
              controller: _phoneCtrl,
              prefixIcon: 'i-phone',
              placeholder: 'Celular',
              keyboardType: TextInputType.phone,
              hasError: _phoneErr,
            ),
            HuTextField(
              controller: _mailCtrl,
              prefixIcon: 'i-mail',
              placeholder: 'Correo',
              keyboardType: TextInputType.emailAddress,
              hasError: _mailErr,
            ),
            HuTextField(
              controller: _passCtrl,
              prefixIcon: 'i-lock',
              placeholder: 'Contraseña (8 caracteres o más)',
              obscureText: _obscure,
              hasError: _passErr,
              suffix: HuPressable(
                onTap: () => setState(() => _obscure = !_obscure),
                semanticLabel: 'Mostrar contraseña',
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: HuIcon(
                    _obscure ? 'i-eye' : 'i-eyeoff',
                    size: 22,
                    color: t.ink3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            HuButton(
              label: 'Crear cuenta',
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta? ',
                  style: t.style(14, FontWeight.w600, t.ink2),
                ),
                HuButton(
                  label: 'Inicia sesión',
                  variant: HuButtonVariant.link,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
