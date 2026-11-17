import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';

class SessionState extends Equatable {
  const SessionState({
    this.user = DemoData.defaultUser,
    this.onboardingSeen = false,
    this.loggedIn = true,
    this.prefReminders = true,
    this.prefChat = true,
    this.prefPromo = false,
    this.simNewAccount = false,
  });

  final UserProfile user;
  final bool onboardingSeen;
  final bool loggedIn;
  final bool prefReminders;
  final bool prefChat;
  final bool prefPromo;
  final bool simNewAccount;

  SessionState copyWith({
    UserProfile? user,
    bool? onboardingSeen,
    bool? loggedIn,
    bool? prefReminders,
    bool? prefChat,
    bool? prefPromo,
    bool? simNewAccount,
  }) =>
      SessionState(
        user: user ?? this.user,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
        loggedIn: loggedIn ?? this.loggedIn,
        prefReminders: prefReminders ?? this.prefReminders,
        prefChat: prefChat ?? this.prefChat,
        prefPromo: prefPromo ?? this.prefPromo,
        simNewAccount: simNewAccount ?? this.simNewAccount,
      );

  @override
  List<Object?> get props => [
        user,
        onboardingSeen,
        loggedIn,
        prefReminders,
        prefChat,
        prefPromo,
        simNewAccount,
      ];
}

sealed class SessionEvent {
  const SessionEvent();
}

class SessionOnboardingCompleted extends SessionEvent {
  const SessionOnboardingCompleted();
}

class SessionLoggedIn extends SessionEvent {
  const SessionLoggedIn({this.mail});
  final String? mail;
}

class SessionRegistered extends SessionEvent {
  const SessionRegistered({
    required this.name,
    required this.phone,
    required this.mail,
  });
  final String name;
  final String phone;
  final String mail;
}

class SessionLoggedOut extends SessionEvent {
  const SessionLoggedOut();
}

class SessionPreferenceToggled extends SessionEvent {
  const SessionPreferenceToggled(this.key);
  final String key; // 'rem' | 'chat' | 'promo'
}

class SessionSimNewAccountSet extends SessionEvent {
  const SessionSimNewAccountSet(this.enabled);
  final bool enabled;
}

class SessionBloc extends HydratedBloc<SessionEvent, SessionState> {
  SessionBloc() : super(const SessionState()) {
    on<SessionOnboardingCompleted>((event, emit) {
      emit(state.copyWith(onboardingSeen: true));
    });
    on<SessionLoggedIn>((event, emit) {
      emit(state.copyWith(
        loggedIn: true,
        onboardingSeen: true,
        user: DemoData.defaultUser,
        simNewAccount: false,
      ));
    });
    on<SessionRegistered>((event, emit) {
      emit(state.copyWith(
        loggedIn: true,
        onboardingSeen: true,
        user: UserProfile(
          name: event.name,
          mail: event.mail,
          phone: event.phone,
          avatarKey: 'yo',
        ),
      ));
    });
    on<SessionLoggedOut>((event, emit) {
      emit(state.copyWith(loggedIn: false));
    });
    on<SessionPreferenceToggled>((event, emit) {
      switch (event.key) {
        case 'rem':
          emit(state.copyWith(prefReminders: !state.prefReminders));
        case 'chat':
          emit(state.copyWith(prefChat: !state.prefChat));
        case 'promo':
          emit(state.copyWith(prefPromo: !state.prefPromo));
      }
    });
    on<SessionSimNewAccountSet>((event, emit) {
      emit(state.copyWith(
        simNewAccount: event.enabled,
        user: event.enabled
            ? const UserProfile(
                name: 'Michael Dev',
                mail: 'michaeldev@gmail.com',
                phone: '987 654 321',
                avatarKey: 'yo',
              )
            : DemoData.defaultUser,
      ));
    });
  }

  @override
  SessionState? fromJson(Map<String, dynamic> json) {
    try {
      return SessionState(
        user: json['user'] != null
            ? UserProfile.fromJson(Map<String, dynamic>.from(json['user'] as Map))
            : DemoData.defaultUser,
        onboardingSeen: (json['onboardingSeen'] as bool?) ?? false,
        loggedIn: (json['loggedIn'] as bool?) ?? true,
        prefReminders: (json['prefReminders'] as bool?) ?? true,
        prefChat: (json['prefChat'] as bool?) ?? true,
        prefPromo: (json['prefPromo'] as bool?) ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SessionState state) => {
        'user': state.user.toJson(),
        'onboardingSeen': state.onboardingSeen,
        'loggedIn': state.loggedIn,
        'prefReminders': state.prefReminders,
        'prefChat': state.prefChat,
        'prefPromo': state.prefPromo,
      };
}
