import 'dart:async';
import 'package:material_ui/material_ui.dart';

import '../theme/hu_tokens.dart';

class ToastData {
  const ToastData({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
}

class Toaster extends ChangeNotifier {
  ToastData? _current;
  Timer? _timer;

  ToastData? get current => _current;

  void show(String message, {String? actionLabel, VoidCallback? onAction}) {
    _timer?.cancel();
    _current = ToastData(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    notifyListeners();
    final duration = actionLabel != null
        ? const Duration(milliseconds: 3800)
        : const Duration(milliseconds: 2600);
    _timer = Timer(duration, hide);
  }

  void hide() {
    _timer?.cancel();
    if (_current != null) {
      _current = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HuToastHost extends StatelessWidget {
  const HuToastHost({super.key, required this.toaster});
  final Toaster toaster;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return ListenableBuilder(
      listenable: toaster,
      builder: (context, _) {
        final d = toaster.current;
        return Positioned(
          left: 20,
          right: 20,
          top: HuLayout.top(context, 60),
          child: IgnorePointer(
            ignoring: d == null,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: d == null ? const Offset(0, -0.3) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: d == null ? 0 : 1,
                child: Semantics(
                  liveRegion: true,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: t.ink,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99000000),
                            offset: Offset(0, 16),
                            blurRadius: 30,
                            spreadRadius: -18,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              d?.message ?? '',
                              style: t.style(14, FontWeight.w500, Colors.white, 1.35),
                            ),
                          ),
                          if (d != null && d.actionLabel != null) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final cb = d.onAction;
                                toaster.hide();
                                cb?.call();
                              },
                              child: Text(
                                d.actionLabel!,
                                style: t.style(
                                  14,
                                  FontWeight.w600,
                                  const Color(0xFF8FE3D7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
