import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../pets/pets_bloc.dart';
import 'chat_bloc.dart';

({String name, String subtitle, Widget avatar54, Widget avatar34}) _threadWho(
  ChatThread t,
) {
  if (t.who == 'vet') {
    final v = DemoData.vetById(t.refId);
    return (
      name: v.name,
      subtitle: v.specialty,
      avatar54: HuPersonAvatar(
        v.avatarKey,
        size: 54,
        borderRadius: BorderRadius.circular(18),
      ),
      avatar34: HuPersonAvatar(
        v.avatarKey,
        size: 34,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  if (t.who == 'walker') {
    final w = DemoData.walkerById(t.refId);
    return (
      name: w.name,
      subtitle: 'Paseador',
      avatar54: HuPersonAvatar(
        w.avatarKey,
        size: 54,
        borderRadius: BorderRadius.circular(18),
      ),
      avatar34: HuPersonAvatar(
        w.avatarKey,
        size: 34,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  final c = DemoData.clinicById(t.refId);
  return (
    name: c.name,
    subtitle: 'Recepción',
    avatar54: const IconBox(
      icon: 'i-steth',
      accent: HuAccent.teal,
      size: 54,
      radius: 18,
    ),
    avatar34: const IconBox(
      icon: 'i-steth',
      accent: HuAccent.teal,
      size: 34,
      radius: 12,
      iconSize: 18,
    ),
  );
}

/// Pantalla 19: Mensajes (`s-msgs`).
class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final chatState = context.watch<ChatBloc>().state;
    final q = HuFormat.norm(chatState.searchQuery.trim());
    final list = chatState.threads
        .where((th) => q.isEmpty || HuFormat.norm(_threadWho(th).name).contains(q))
        .toList();

    return HuScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 62), 22, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Mensajes', style: t.h1Large),
            const SizedBox(height: 16),

            // Buscador .srch
            Container(
              height: 52,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: t.border),
                boxShadow: HuTokens.cardShadow,
              ),
              child: Row(
                children: [
                  HuIcon('i-search', size: 22, color: t.ink3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          context.read<ChatBloc>().add(ChatSearchChanged(v)),
                      style: t.style(15, FontWeight.w600, t.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Buscar conversación',
                        hintStyle: t.style(15, FontWeight.w500, t.ink3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (list.isEmpty)
              const Center(
                child: EmptyState(
                  artKey: 'a-cat',
                  title: 'Sin conversaciones',
                  subtitle:
                      'Escribe a tu vet desde la ficha de tu mascota o desde una cita.',
                ),
              )
            else
              for (final th in list)
                Builder(
                  builder: (_) {
                    final who = _threadWho(th);
                    final last = th.messages.last;
                    final preview =
                        '${last.fromMe ? 'Tú: ' : ''}${last.hasPhoto ? '📷 Foto' : last.text}';
                    return HuCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      onTap: () {
                        context.read<ChatBloc>().add(ChatThreadOpened(th.id));
                        context.push('/chat');
                      },
                      child: Row(
                        children: [
                          who.avatar54,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        who.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.style(
                                          15,
                                          FontWeight.w600,
                                          t.ink,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      last.time,
                                      style: t.style(
                                        12,
                                        FontWeight.w500,
                                        t.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  preview,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.style(13, FontWeight.w600, t.ink2),
                                ),
                              ],
                            ),
                          ),
                          if (th.unread > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 22,
                                minHeight: 22,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: t.coral,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${th.unread}',
                                style: t.style(
                                  12,
                                  FontWeight.w600,
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla 20: Chat (`s-chat`).
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final txt = _inputCtrl.text.trim();
    if (txt.isEmpty) return;
    _inputCtrl.clear();
    context.read<ChatBloc>().add(ChatMessageSent(text: txt));
  }

  void _openAttachSheet(BuildContext context) {
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adjuntar',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              'Una foto ayuda a tu vet a entender mejor.',
              style: t.style(14.5, FontWeight.w400, t.ink2),
            ),
            const SizedBox(height: 16),
            HuCard(
              margin: const EdgeInsets.only(bottom: 10),
              onTap: () {
                Navigator.of(ctx).pop();
                context
                    .read<ChatBloc>()
                    .add(const ChatMessageSent(hasPhoto: true));
              },
              child: Row(
                children: [
                  const IconBox(
                    icon: 'i-camera',
                    accent: HuAccent.teal,
                    size: 42,
                    radius: 14,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Tomar foto',
                    style: t.style(15.5, FontWeight.w600, t.ink),
                  ),
                ],
              ),
            ),
            HuCard(
              onTap: () {
                Navigator.of(ctx).pop();
                context
                    .read<ChatBloc>()
                    .add(const ChatMessageSent(hasPhoto: true));
              },
              child: Row(
                children: [
                  const IconBox(
                    icon: 'i-doc',
                    accent: HuAccent.lav,
                    size: 42,
                    radius: 14,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Elegir de la galería',
                    style: t.style(15.5, FontWeight.w600, t.ink),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final chatState = context.watch<ChatBloc>().state;
    final petsState = context.watch<PetsBloc>().state;
    final thread = chatState.activeThread;
    if (thread == null) {
      return HuScaffold(
        topBar: HuTopBar(title: 'Chat', onBack: () => context.pop()),
        body: const SizedBox.shrink(),
      );
    }

    final who = _threadWho(thread);
    final pet = petsState.byId(thread.petId) ?? petsState.pets.firstOrNull;
    final isTyping = chatState.typingThreadId == thread.id;

    return HuScaffold(
      showVeil: false,
      topBar: Container(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 60), 22, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.80, 1.0],
            colors: [
              Colors.white,
              Colors.white,
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Row(
          children: [
            HuHeaderCircleButton(
              icon: 'i-back',
              label: 'Volver',
              onTap: () => context.pop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  who.avatar34,
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          who.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.style(17, FontWeight.w600, t.ink),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: t.ok,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'En línea',
                              style: t.style(12, FontWeight.w700, t.ok),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            HuHeaderCircleButton(
              icon: 'i-phone',
              label: 'Llamar',
              onTap: () => getIt<Toaster>().show('Llamando…'),
            ),
          ],
        ),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 34),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12324A).withValues(alpha: 0.20),
              offset: const Offset(0, -10),
              blurRadius: 30,
              spreadRadius: -24,
            ),
          ],
        ),
        child: Row(
          children: [
            HuPressable(
              onTap: () => _openAttachSheet(context),
              semanticLabel: 'Adjuntar foto',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: t.bg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: HuIcon('i-camera', size: 22, color: t.ink),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: t.bg,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _inputCtrl,
                  onSubmitted: (_) => _send(),
                  style: t.style(15, FontWeight.w600, t.ink),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Escribe un mensaje…',
                    hintStyle: t.style(15, FontWeight.w500, t.ink3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            HuPressable(
              onTap: _send,
              semanticLabel: 'Enviar',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: t.teal,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const HuIcon('i-send', size: 22, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.fromLTRB(18, HuLayout.top(context, 120), 18, 120),
        child: Column(
          children: [
            if (thread.who != 'walker')
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: t.badSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const HuIcon(
                      'i-alert',
                      size: 18,
                      color: Color(0xFFA3271C),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¿Es una emergencia? No esperes respuesta por chat.',
                        style: t.style(
                          12.5,
                          FontWeight.w500,
                          const Color(0xFFA3271C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HuPressable(
                      onTap: () => context.push('/sos'),
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: t.bad,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Emergencia',
                          style: t.style(12, FontWeight.w600, Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            for (final m in thread.messages)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: m.fromMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!m.fromMe) ...[
                      who.avatar34,
                      const SizedBox(width: 8),
                    ],
                    Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: m.fromMe ? t.teal : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(m.fromMe ? 20 : 6),
                          bottomRight: Radius.circular(m.fromMe ? 6 : 20),
                        ),
                        border: m.fromMe ? null : Border.all(color: t.border),
                        boxShadow: m.fromMe ? null : HuTokens.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: m.fromMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (m.hasPhoto && pet != null)
                            Container(
                              width: 200,
                              height: 140,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: pet.accent.bg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: HuArt(pet.artKey, width: 120, height: 120),
                            ),
                          if (m.text.isNotEmpty)
                            Text(
                              m.text,
                              style: t.style(
                                14.5,
                                FontWeight.w400,
                                m.fromMe ? Colors.white : t.ink,
                                1.45,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '${m.time}${m.fromMe ? ' ✓✓' : ''}',
                            style: t.style(
                              11,
                              FontWeight.w500,
                              m.fromMe
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : t.ink3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (isTyping)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  who.avatar34,
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: t.border),
                      boxShadow: HuTokens.cardShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < 3; i++)
                          Container(
                            width: 7,
                            height: 7,
                            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: t.ink3,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

