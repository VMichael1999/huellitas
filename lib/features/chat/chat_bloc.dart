import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/utils/clock.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.threads,
    this.activeThreadId = 'sofia',
    this.searchQuery = '',
    this.typingThreadId,
  });

  final List<ChatThread> threads;
  final String activeThreadId;
  final String searchQuery;
  final String? typingThreadId;

  int get totalUnread => threads.fold(0, (acc, t) => acc + t.unread);

  ChatThread? get activeThread {
    if (threads.isEmpty) return null;
    return threads.firstWhere(
      (t) => t.id == activeThreadId,
      orElse: () => threads.first,
    );
  }

  ChatState copyWith({
    List<ChatThread>? threads,
    String? activeThreadId,
    String? searchQuery,
    String? typingThreadId,
    bool clearTyping = false,
  }) =>
      ChatState(
        threads: threads ?? this.threads,
        activeThreadId: activeThreadId ?? this.activeThreadId,
        searchQuery: searchQuery ?? this.searchQuery,
        typingThreadId: clearTyping ? null : (typingThreadId ?? this.typingThreadId),
      );

  @override
  List<Object?> get props => [threads, activeThreadId, searchQuery, typingThreadId];
}

sealed class ChatEvent {
  const ChatEvent();
}

class ChatThreadOpened extends ChatEvent {
  const ChatThreadOpened(this.threadId);
  final String threadId;
}

class ChatSearchChanged extends ChatEvent {
  const ChatSearchChanged(this.query);
  final String query;
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({
    this.text = '',
    this.hasPhoto = false,
  });

  final String text;
  final bool hasPhoto;
}

class ChatReset extends ChatEvent {
  const ChatReset({required this.empty});
  final bool empty;
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required this.clock})
      : super(ChatState(threads: DemoData.mkThreads())) {
    on<ChatThreadOpened>((event, emit) {
      final targetId = state.threads.any((t) => t.id == event.threadId)
          ? event.threadId
          : (state.threads.isNotEmpty ? state.threads.first.id : 'sofia');
      final next = state.threads.map((t) {
        if (t.id != targetId) return t;
        return t.copyWith(unread: 0);
      }).toList();
      emit(state.copyWith(threads: next, activeThreadId: targetId));
    });

    on<ChatSearchChanged>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });

    on<ChatMessageSent>((event, emit) async {
      final active = state.activeThread;
      if (active == null) return;
      final nowLabel = HuFormat.hm(clock.nowMinutes);
      final userMsg = ChatMessage(
        fromMe: true,
        text: event.text,
        hasPhoto: event.hasPhoto,
        time: nowLabel,
      );
      final withUserMsg = state.threads.map((t) {
        if (t.id != active.id) return t;
        return t.copyWith(messages: [...t.messages, userMsg]);
      }).toList();
      emit(state.copyWith(threads: withUserMsg, typingThreadId: active.id));

      await Future<void>.delayed(const Duration(milliseconds: 1600));
      final replyText = event.hasPhoto
          ? 'Gracias por la foto. Se ve bien; lo revisamos con calma en la consulta.'
          : switch (active.who) {
              'walker' => '¡Listo! Cualquier cosa me escribes por aquí.',
              'clinic' =>
                'Recibido. Te responderemos en unos minutos en horario de atención.',
              _ =>
                'Gracias por contarme. Si notas decaimiento, vómitos o que no come en 24 horas, agenda una consulta. Si es urgente, usa el botón de emergencia.',
            };
      final replyMsg = ChatMessage(
        fromMe: false,
        text: replyText,
        time: HuFormat.hm(clock.nowMinutes),
      );
      final withReply = state.threads.map((t) {
        if (t.id != active.id) return t;
        return t.copyWith(messages: [...t.messages, replyMsg]);
      }).toList();
      emit(state.copyWith(threads: withReply, clearTyping: true));
    });

    on<ChatReset>((event, emit) {
      emit(state.copyWith(
        threads: event.empty ? [] : DemoData.mkThreads(),
        clearTyping: true,
      ));
    });
  }

  final Clock clock;
}
