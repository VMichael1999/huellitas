import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme/hu_tokens.dart';
import '../core/utils/clock.dart';
import '../core/widgets/hu_icon.dart';
import '../core/widgets/hu_widgets.dart';
import '../features/appointments/appointments_bloc.dart';
import '../features/chat/chat_bloc.dart';
import 'di.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    ('home', 'i-home', 'Inicio'),
    ('appts', 'i-cal', 'Citas'),
    ('pets', 'i-paw', 'Mascotas'),
    ('msgs', 'i-chat', 'Mensajes'),
    ('profile', 'i-user', 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final upcomingCount =
        context.watch<AppointmentsBloc>().state.upcoming(today).length;
    final unreadMessages = context.watch<ChatBloc>().state.totalUnread;

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 92,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: t.border, width: 1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x661D2A44),
                    offset: Offset(0, -12),
                    blurRadius: 30,
                    spreadRadius: -24,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (idx, tab) in _tabs.indexed)
                    Builder(
                      builder: (_) {
                        final isOn = navigationShell.currentIndex == idx;
                        final badge = idx == 1
                            ? upcomingCount
                            : idx == 3
                                ? unreadMessages
                                : 0;
                        final Color? fill = isOn
                            ? (idx == 0 || idx == 2 ? t.teal : t.tealSoft)
                            : null;
                        return HuPressable(
                          onTap: () => navigationShell.goBranch(
                            idx,
                            initialLocation: idx == navigationShell.currentIndex,
                          ),
                          selected: isOn,
                          child: SizedBox(
                            width: 76,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HuIcon(
                                      tab.$2,
                                      size: 25,
                                      color: isOn
                                          ? t.teal
                                          : const Color(0xFF8A94A3),
                                      fill: fill,
                                      strokeWidth: 1.7,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      tab.$3,
                                      style: t.style(
                                        11.5,
                                        isOn ? FontWeight.w600 : FontWeight.w500,
                                        isOn
                                            ? t.teal
                                            : const Color(0xFF8A94A3),
                                      ),
                                    ),
                                  ],
                                ),
                                if (badge > 0)
                                  Positioned(
                                    top: -6,
                                    left: 44,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.coral,
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$badge',
                                        style: t.style(
                                          10.5,
                                          FontWeight.w600,
                                          Colors.white,
                                          1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
