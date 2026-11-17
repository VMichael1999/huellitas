import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../format/hu_format.dart';
import '../theme/hu_tokens.dart';
import 'hu_icon.dart';

/// Detecta toques con leve reducción de escala (`.btn:active { transform: scale(.985) }`).
class HuPressable extends StatefulWidget {
  const HuPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.985,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;
  final HitTestBehavior behavior;

  @override
  State<HuPressable> createState() => _HuPressableState();
}

class _HuPressableState extends State<HuPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: widget.toggled == null,
      enabled: enabled,
      label: widget.semanticLabel,
      selected: widget.selected,
      toggled: widget.toggled,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}

/// `HuScaffold`: fondo `bg`, barra de estado oscura o clara y velo blanco degradado arriba.
class HuScaffold extends StatelessWidget {
  const HuScaffold({
    super.key,
    required this.body,
    this.topBar,
    this.bottomBar,
    this.showVeil = true,
    this.lightStatusBar = false,
    this.backgroundColor,
  });

  final Widget body;
  final Widget? topBar;
  final Widget? bottomBar;
  final bool showVeil;
  final bool lightStatusBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final bg = backgroundColor ?? t.bg;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: lightStatusBar
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            Positioned.fill(child: body),
            if (showVeil && topBar == null)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 80,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.675, 1.0],
                        colors: [
                          bg,
                          bg,
                          bg.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (topBar != null)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: topBar!,
              ),
            if (bottomBar != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Botón circular de cabecera de 46x46 (`.ib` / `.ib2`).
class HuHeaderCircleButton extends StatelessWidget {
  const HuHeaderCircleButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.ghost = false,
    this.tealSoft = false,
    this.fillColor,
    this.iconColor,
    this.badgeCount = 0,
    this.showDot = false,
    this.size = 46,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool ghost;
  final bool tealSoft;
  final Color? fillColor;
  final Color? iconColor;
  final int badgeCount;
  final bool showDot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final bg = fillColor ??
        (tealSoft
            ? t.tealSoft
            : ghost
                ? Colors.transparent
                : Colors.white);
    final fg = iconColor ?? (tealSoft ? t.teal : t.ink);
    final radius = tealSoft ? 14.0 : size / 2;

    return HuPressable(
      onTap: onTap,
      semanticLabel: label,
      scale: 0.94,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius),
                border: (ghost || tealSoft || fillColor != null)
                    ? null
                    : Border.all(color: t.border, width: 1),
                boxShadow: (ghost || tealSoft) ? null : HuTokens.headerButtonShadow,
              ),
              alignment: Alignment.center,
              child: HuIcon(icon, size: 22, color: fg, strokeWidth: 2.1),
            ),
            if (showDot)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: t.coral,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: t.coral,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.bg, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$badgeCount',
                    style: t.style(11, FontWeight.w600, Colors.white, 1.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `HuTopBar`: soporta estilo `.top` (centrado) y `.top2` (título `title` 23px a la derecha del botón atrás,
/// o centrado en perfil de mascota con avatar a la derecha).
class HuTopBar extends StatelessWidget {
  const HuTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.centered = true,
    this.clear = false,
    this.hideBack = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool centered;
  final bool clear;
  final bool hideBack;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final topPad = HuLayout.top(context, 60);
    return Container(
      padding: EdgeInsets.fromLTRB(22, topPad, 22, clear ? 12 : 16),
      decoration: clear
          ? null
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.90, 1.0],
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
      child: Row(
        children: [
          if (hideBack)
            const SizedBox(width: 46, height: 46)
          else
            HuHeaderCircleButton(
              icon: 'i-back',
              label: 'Volver',
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          SizedBox(width: centered ? 10 : 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    textAlign: centered ? TextAlign.center : TextAlign.start,
                    style: centered ? t.topTitle : t.title,
                  ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      style: t.style(
                        centered ? 12.5 : 13.5,
                        FontWeight.w400,
                        t.ink2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (centered || trailing != null) ...[
            SizedBox(width: centered ? 10 : 12),
            trailing ?? const SizedBox(width: 46, height: 46),
          ],
        ],
      ),
    );
  }
}

enum HuButtonVariant { primary, pay, line, soft, danger, link, linkMuted }

/// `HuButton`: variantes `primary`, `pay` (coral), `line`, `soft`, `danger`, `link` y `loading`.
class HuButton extends StatelessWidget {
  const HuButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = HuButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.small = false,
    this.height,
    this.radius,
    this.expand = true,
    this.customTextColor,
    this.customBorderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final HuButtonVariant variant;
  final String? icon;
  final bool loading;
  final bool small;
  final double? height;
  final double? radius;
  final bool expand;
  final Color? customTextColor;
  final Color? customBorderColor;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    if (variant == HuButtonVariant.link || variant == HuButtonVariant.linkMuted) {
      final col = customTextColor ??
          (variant == HuButtonVariant.linkMuted ? t.ink2 : t.teal);
      return HuPressable(
        onTap: loading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: t.style(14, FontWeight.w600, col),
          ),
        ),
      );
    }

    final disabled = onPressed == null || loading;
    final h = height ?? (small ? 44.0 : 56.0);
    final r = radius ?? (small ? 14.0 : 16.0);
    final fs = small ? 14.5 : 16.0;

    final (Color bg, Color fg, BoxBorder? border, List<BoxShadow>? shadow) =
        switch (variant) {
      HuButtonVariant.primary => (
          disabled ? const Color(0xFFB9D6D1) : t.teal,
          Colors.white,
          null,
          disabled ? null : HuTokens.primaryButtonShadow,
        ),
      HuButtonVariant.pay => (
          disabled ? const Color(0xFFEFC1B7) : t.coral,
          Colors.white,
          null,
          disabled ? null : HuTokens.coralButtonShadow,
        ),
      HuButtonVariant.line => (
          Colors.transparent,
          customTextColor ?? t.teal,
          Border.all(color: customBorderColor ?? t.teal, width: 2),
          null,
        ),
      HuButtonVariant.soft => (
          t.tealSoft,
          customTextColor ?? t.tealDeep,
          null,
          null,
        ),
      HuButtonVariant.danger => (
          disabled ? t.bad.withValues(alpha: 0.45) : t.bad,
          Colors.white,
          null,
          null,
        ),
      _ => (t.teal, Colors.white, null, null),
    };

    return HuPressable(
      onTap: disabled ? null : onPressed,
      child: Container(
        height: h,
        width: expand ? double.infinity : null,
        padding: expand ? const EdgeInsets.symmetric(horizontal: 16) : const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(r),
          border: border,
          boxShadow: shadow,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              HuIcon(icon!, size: 20, color: fg),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.style(fs, FontWeight.w600, fg, 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `HuCard`: superficie blanca, radio 20-22, borde `border` y sombra suave; `selected` con borde 2 `teal`.
class HuCard extends StatelessWidget {
  const HuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.radius = 20,
    this.selected = false,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (selected ? const Color(0xFFF7FDFC) : t.surface),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? t.teal : t.border,
          width: selected ? 2 : 1,
        ),
        boxShadow: HuTokens.cardShadow,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return HuPressable(
      onTap: onTap,
      selected: selected,
      child: box,
    );
  }
}

/// `IconBox` (`qic` en HTML): ícono en caja redondeada con `HuAccent`.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    this.accent = HuAccent.teal,
    this.size = 46,
    this.radius = 15,
    this.iconSize = 22,
  });

  final String icon;
  final HuAccent accent;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: HuIcon(icon, size: iconSize, color: accent.fg),
    );
  }
}

/// `PetAvatar` (`petImg` en HTML): ilustración 3D sobre el fondo `Soft` del color de la mascota.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.artKey,
    this.accent = HuAccent.teal,
    this.size = 64,
    this.radius = 18,
    this.circular = false,
    this.showBackground = true,
  });

  final String artKey;
  final HuAccent accent;
  final double size;
  final double radius;
  final bool circular;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final br = circular
        ? BorderRadius.circular(size)
        : BorderRadius.circular(radius);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: showBackground ? accent.bg : Colors.transparent,
        borderRadius: br,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: HuArt(artKey, width: size, height: size),
    );
  }
}

/// `PetCard` (`pc2` en HTML): tarjeta de 192×268 del inicio.
class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.name,
    required this.breedAndAge,
    required this.artKey,
    required this.accent,
    required this.healthLabel,
    required this.onTap,
    required this.onMenuTap,
  });

  final String name;
  final String breedAndAge;
  final String artKey;
  final HuAccent accent;
  final String healthLabel;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        width: 192,
        height: 268,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8C1D2A44),
              offset: Offset(0, 14),
              blurRadius: 26,
              spreadRadius: -18,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 178,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: accent.petCardTopGradient,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: -2,
                      height: 168,
                      child: HuArt(artKey, width: 172, height: 168),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: HuPressable(
                        onTap: onMenuTap,
                        semanticLabel: 'Opciones de $name',
                        scale: 0.92,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: HuIcon('i-dots', size: 18, color: t.ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 104,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: accent.petCardBottomBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.petName,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      breedAndAge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.style(
                        12.5,
                        FontWeight.w400,
                        Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 27,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HuIcon(
                            'i-heartf',
                            size: 14,
                            color: accent.petCardPillFg,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            healthLabel,
                            style: t.style(
                              12.5,
                              FontWeight.w500,
                              accent.petCardPillFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta punteada «Agregar mascota» (`pc2.add`).
class AddPetCard extends StatelessWidget {
  const AddPetCard({
    super.key,
    required this.label,
    required this.onTap,
    this.horizontal = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFCDE9E4),
          radius: 24,
        ),
        child: Container(
          width: horizontal ? double.infinity : 132,
          height: horizontal ? 96 : 268,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Flex(
            direction: horizontal ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: t.tealSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: HuIcon('i-plus', size: 22, color: t.teal),
              ),
              const SizedBox(width: 10, height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: t.style(13.5, FontWeight.w500, t.ink2, 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final next = math.min(d + 7, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

/// `QuickAction` (`qa2` en HTML): tarjeta blanca de 112 de alto con ícono a dos tonos de 36 y etiqueta.
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.dqIcon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final String dqIcon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
          boxShadow: HuTokens.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HuDqIcon(dqIcon, color: iconColor, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: t.label,
            ),
          ],
        ),
      ),
    );
  }
}

/// `DateBox` (`db` en HTML): caja de fecha con mes en franja superior y día grande.
class DateBox extends StatelessWidget {
  const DateBox({
    super.key,
    required this.isoDate,
    this.stripColor,
  });

  final String isoDate;
  final Color? stripColor;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final d = HuFormat.fromIso(isoDate);
    final topColor = stripColor ?? t.coral;
    return Container(
      width: 52,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D1D2A44),
            offset: Offset(0, 4),
            blurRadius: 10,
            spreadRadius: -6,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 20,
            width: double.infinity,
            color: topColor,
            alignment: Alignment.center,
            child: Text(
              HuFormat.mon[d.month - 1].toUpperCase(),
              style: t.style(10.5, FontWeight.w600, Colors.white, 1.0, 0.5),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${d.day}',
                style: t.style(22, FontWeight.w600, t.ink, 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `TaskRow` (`task2` en HTML): caja de fecha, título, «Mascota • hora» y cabeza 3D a la derecha.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.isoDate,
    required this.title,
    required this.subtitle,
    required this.petArtKey,
    required this.onTap,
    this.useTealStrip = false,
  });

  final String isoDate;
  final String title;
  final String subtitle;
  final String petArtKey;
  final VoidCallback onTap;
  final bool useTealStrip;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.border),
          boxShadow: HuTokens.cardShadow,
        ),
        child: Row(
          children: [
            DateBox(
              isoDate: isoDate,
              stripColor: useTealStrip ? t.teal : t.coral,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: t.style(13.5, FontWeight.w400, t.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 62,
              height: 62,
              child: HuArt(petArtKey, width: 62, height: 62),
            ),
          ],
        ),
      ),
    );
  }
}

/// `VaccineBanner` (`vxb` en HTML): tarjeta degradada teal con escudo o coral para paseo en vivo.
class VaccineBanner extends StatelessWidget {
  const VaccineBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLiveWalk = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLiveWalk;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLiveWalk
                ? const [Color(0xFFF79A84), Color(0xFFF2775E), Color(0xFFE3654C)]
                : const [Color(0xFF3FB6A6), Color(0xFF1F9E8F), Color(0xFF18887B)],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -58,
              bottom: -78,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLiveWalk)
                        Container(
                          height: 26,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'En vivo',
                                style: t.style(12, FontWeight.w600, Colors.white),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        title,
                        style: t.style(18, FontWeight.w600, Colors.white, 1.25),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: t.style(
                          13,
                          FontWeight.w400,
                          Colors.white.withValues(alpha: 0.90),
                          1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isLiveWalk)
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: HuArt('a-walk', width: 84, height: 84),
                  )
                else
                  const HuShieldSvg(width: 96, height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// `HealthTile` (`hov4` item en HTML): ícono a dos tonos, etiqueta, cifra, estado y barra.
class HealthTile extends StatelessWidget {
  const HealthTile({
    super.key,
    required this.dqIcon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
    required this.status,
    required this.progress,
    required this.barColor,
    this.smallValueText = false,
  });

  final String dqIcon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;
  final String status;
  final double progress;
  final Color barColor;
  final bool smallValueText;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D1D2A44),
            offset: Offset(0, 6),
            blurRadius: 14,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          HuDqIcon(dqIcon, color: iconColor, size: 26),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.style(12.5, FontWeight.w400, t.ink),
          ),
          SizedBox(height: smallValueText ? 7 : 6),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: value,
              style: t.style(
                smallValueText ? 15.5 : 19,
                FontWeight.w600,
                t.ink,
                smallValueText ? 1.5 : 1.3,
              ),
              children: [
                if (unit != null)
                  TextSpan(
                    text: unit,
                    style: t.style(12, FontWeight.w500, t.ink),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.isEmpty ? ' ' : status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.style(12, FontWeight.w400, t.ink2),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              width: double.infinity,
              child: ColoredBox(
                color: t.border,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `PickerCard` (`pick` en HTML): tarjeta con avatar o ícono, título, detalle y chevron abajo.
class PickerCard extends StatelessWidget {
  const PickerCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.extraLine,
    this.onTap,
    this.enabled = true,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? extraLine;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
          boxShadow: HuTokens.cardShadow,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.cardTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: t.style(13.5, FontWeight.w400, t.ink2)),
                  if (extraLine != null) ...[
                    const SizedBox(height: 2),
                    extraLine!,
                  ],
                ],
              ),
            ),
            if (enabled) ...[
              const SizedBox(width: 8),
              HuIcon('i-down', size: 22, color: t.ink),
            ],
          ],
        ),
      ),
    );
  }
}

/// `HealthRing` (`ring` en HTML): anillo con `CustomPainter` y puntaje en el centro.
class HealthRing extends StatelessWidget {
  const HealthRing({
    super.key,
    required this.score,
    this.size = 50,
    this.strokeWidth = 4.5,
    this.color,
    this.showLabel = true,
  });

  final int score;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final fg = color ??
        (score >= 85
            ? t.teal
            : score >= 70
                ? t.sun
                : t.bad);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HealthRingPainter(
          score: score,
          color: fg,
          trackColor: t.chip,
          strokeWidth: strokeWidth,
        ),
        child: showLabel
            ? Center(
                child: Text(
                  '$score',
                  style: t.style(12.5, FontWeight.w600, t.ink),
                ),
              )
            : null,
      ),
    );
  }
}

class _HealthRingPainter extends CustomPainter {
  _HealthRingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final int score;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - strokeWidth;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final sweep = 2 * math.pi * (score.clamp(0, 100) / 100.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthRingPainter oldDelegate) =>
      oldDelegate.score != score || oldDelegate.color != color;
}

/// `StatusTag` (`tag` en HTML): pastilla de estado.
class StatusTag extends StatelessWidget {
  const StatusTag(
    this.text, {
    super.key,
    this.accent = HuAccent.teal,
    this.icon,
    this.height = 24,
    this.whiteBg = false,
  });

  final String text;
  final HuAccent accent;
  final String? icon;
  final double height;
  final bool whiteBg;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final bg = whiteBg ? Colors.white.withValues(alpha: 0.94) : accent.bg;
    final fg = whiteBg ? t.tealDeep : accent.tagFg;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            HuIcon(icon!, size: 13, color: fg, strokeWidth: 2.4),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: t.style(12, FontWeight.w500, fg, 1.0),
          ),
        ],
      ),
    );
  }
}

/// `ChipGroup`: chips de selección con scroll horizontal o wrap.
class HuChip extends StatelessWidget {
  const HuChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.small = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final h = small ? 34.0 : 40.0;
    final px = small ? 13.0 : 16.0;
    final fs = small ? 13.0 : 14.0;
    final fg = selected ? Colors.white : t.ink2;
    return HuPressable(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: h,
        padding: EdgeInsets.symmetric(horizontal: px),
        decoration: BoxDecoration(
          color: selected ? t.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? t.teal : t.line,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              HuIcon(icon!, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(label, style: t.style(fs, FontWeight.w500, fg)),
          ],
        ),
      ),
    );
  }
}

/// `SegmentedTabs` (`seg` y `tabs2` en HTML).
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<(T, String)> items;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.chip,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: HuPressable(
                onTap: () => onChanged(item.$1),
                selected: item.$1 == selected,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.$1 == selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: item.$1 == selected
                        ? const [
                            BoxShadow(
                              color: Color(0x591D2A44),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: -6,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.$2,
                    style: t.style(
                      14,
                      FontWeight.w500,
                      item.$1 == selected ? t.ink : t.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `MonthCalendar` (`cal2` en HTML): calendario mensual con días desde lunes, días fuera de mes en gris claro,
/// y seleccionado en círculo `teal`.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.displayMonth,
    required this.selectedIsoDate,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.isDayEnabled,
    required this.onSelectDate,
  });

  final DateTime displayMonth;
  final String? selectedIsoDate;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final bool Function(String isoDate) isDayEnabled;
  final ValueChanged<String> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final y = displayMonth.year;
    final mo = displayMonth.month;
    final firstOfMonth = DateTime(y, mo, 1);
    final lead = (HuFormat.jsDay(firstOfMonth) + 6) % 7;
    final nd = DateTime(y, mo + 1, 0).day;
    final pnd = DateTime(y, mo, 0).day;
    final tail = (7 - (lead + nd) % 7) % 7;

    final cells = <Widget>[];
    for (int k = lead - 1; k >= 0; k--) {
      cells.add(
        Center(
          child: Text(
            '${pnd - k}',
            style: t.style(15.5, FontWeight.w400, const Color(0xFFC4CBD4)),
          ),
        ),
      );
    }
    for (int d = 1; d <= nd; d++) {
      final di = HuFormat.iso(DateTime(y, mo, d));
      final ok = isDayEnabled(di);
      final isSelected = di == selectedIsoDate;
      cells.add(
        Center(
          child: HuPressable(
            onTap: ok ? () => onSelectDate(di) : null,
            semanticLabel: HuFormat.fLong(di),
            selected: isSelected,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? t.teal : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0xD9157A6F),
                          offset: Offset(0, 8),
                          blurRadius: 16,
                          spreadRadius: -8,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$d',
                style: t.style(
                  15.5,
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  isSelected
                      ? Colors.white
                      : ok
                          ? t.ink
                          : const Color(0xFFC4CBD4),
                ),
              ),
            ),
          ),
        ),
      );
    }
    for (int k = 1; k <= tail; k++) {
      cells.add(
        Center(
          child: Text(
            '$k',
            style: t.style(15.5, FontWeight.w400, const Color(0xFFC4CBD4)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.border),
        boxShadow: HuTokens.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HuPressable(
                  onTap: canGoPrev ? onPrevMonth : null,
                  semanticLabel: 'Mes anterior',
                  child: Opacity(
                    opacity: canGoPrev ? 1.0 : 0.3,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: Center(
                        child: Transform.rotate(
                          angle: math.pi,
                          child: HuIcon('i-chev', size: 22, color: t.ink),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${HuFormat.cap(HuFormat.monLong[mo - 1])} $y',
                  style: t.style(16.5, FontWeight.w500, t.ink),
                ),
                HuPressable(
                  onTap: canGoNext ? onNextMonth : null,
                  semanticLabel: 'Mes siguiente',
                  child: Opacity(
                    opacity: canGoNext ? 1.0 : 0.3,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: Center(
                        child: HuIcon('i-chev', size: 22, color: t.ink),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (final w in HuFormat.wdn)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      w.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: t.style(11.5, FontWeight.w500, const Color(0xFF8A94A3)),
                    ),
                  ),
                ),
            ],
          ),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            childAspectRatio: 1.0,
            children: cells,
          ),
        ],
      ),
    );
  }
}

/// `SlotGrid` (`slots2` en reserva de citas): 3 columnas, 6 horas repartidas y «Ver todas las horas (n)».
class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.freeSlotsMinutes,
    required this.selectedTime,
    required this.showAll,
    required this.onSelectTime,
    required this.onToggleShowAll,
  });

  final List<int> freeSlotsMinutes;
  final String? selectedTime;
  final bool showAll;
  final ValueChanged<String> onSelectTime;
  final VoidCallback onToggleShowAll;

  static List<int> visibleSlots(List<int> allFree, String? selectedTime, bool showAll) {
    if (showAll || allFree.length <= 6) return allFree;
    final idx = <int>{
      for (int i = 0; i < 6; i++) ((i * (allFree.length - 1)) / 5).round(),
    };
    if (selectedTime != null) {
      final k = allFree.indexWhere((t) => HuFormat.hm(t) == selectedTime);
      if (k >= 0 && !idx.contains(k)) {
        final sorted = idx.toList()
          ..sort((a, b) => (a - k).abs().compareTo((b - k).abs()));
        idx.remove(sorted.first);
        idx.add(k);
      }
    }
    return [
      for (int i = 0; i < allFree.length; i++)
        if (idx.contains(i)) allFree[i],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    if (freeSlotsMinutes.isEmpty) {
      return Text(
        'No quedan horas este día. Elige otra fecha.',
        style: t.style(14.5, FontWeight.w400, t.ink2),
      );
    }
    final visible = visibleSlots(freeSlotsMinutes, selectedTime, showAll);
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 50,
          ),
          itemCount: visible.length,
          itemBuilder: (context, i) {
            final hm = HuFormat.hm(visible[i]);
            final isOn = hm == selectedTime;
            return HuPressable(
              onTap: () => onSelectTime(hm),
              selected: isOn,
              child: Container(
                decoration: BoxDecoration(
                  color: isOn ? t.teal : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isOn ? t.teal : t.border),
                  boxShadow: isOn
                      ? const [
                          BoxShadow(
                            color: Color(0xE6157A6F),
                            offset: Offset(0, 10),
                            blurRadius: 18,
                            spreadRadius: -12,
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x331D2A44),
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: -8,
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Text(
                  HuFormat.ampm(hm),
                  style: t.style(
                    14.5,
                    FontWeight.w500,
                    isOn ? Colors.white : t.ink,
                  ),
                ),
              ),
            );
          },
        ),
        if (freeSlotsMinutes.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: HuButton(
              label: showAll
                  ? 'Ver menos horas'
                  : 'Ver todas las horas (${freeSlotsMinutes.length})',
              variant: HuButtonVariant.link,
              onPressed: onToggleShowAll,
            ),
          ),
      ],
    );
  }
}

/// `DayStrip` (`days` en flujo de servicios): tira horizontal de 14 días.
class DayStrip extends StatelessWidget {
  const DayStrip({
    super.key,
    required this.today,
    required this.days,
    this.selectedDate,
    this.endDate,
    this.isEnabled,
    required this.onSelect,
  });

  final DateTime today;
  final List<String> days;
  final String? selectedDate;
  final String? endDate;
  final bool Function(String)? isEnabled;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = days[i];
          final dt = HuFormat.fromIso(d);
          final enabled = isEnabled?.call(d) ?? true;
          final isOn = d == selectedDate || d == endDate;
          final inRange = selectedDate != null &&
              endDate != null &&
              d.compareTo(selectedDate!) > 0 &&
              d.compareTo(endDate!) < 0;
          final dayLabel = HuFormat.daysFrom(today, d) == 0
              ? 'Hoy'
              : HuFormat.cap(HuFormat.dow[HuFormat.jsDay(dt)]);

          return Opacity(
            opacity: enabled ? 1.0 : 0.4,
            child: HuPressable(
              onTap: enabled ? () => onSelect(d) : null,
              selected: isOn,
              child: Container(
                width: 58,
                height: 78,
                decoration: BoxDecoration(
                  color: isOn
                      ? t.teal
                      : inRange
                          ? t.tealSoft
                          : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isOn
                        ? t.teal
                        : inRange
                            ? t.mint
                            : t.line,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel,
                      style: t.style(
                        12,
                        FontWeight.w600,
                        isOn ? Colors.white.withValues(alpha: 0.9) : t.ink2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dt.day}',
                      style: t.style(
                        21,
                        FontWeight.w600,
                        isOn ? Colors.white : t.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Interruptor (`tog` en HTML).
class HuSwitch extends StatelessWidget {
  const HuSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      semanticLabel: semanticLabel,
      toggled: value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? t.teal : const Color(0xFFD5E2DF),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `ToggleRow` (`tgrow` y `tg` en HTML).
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
    this.boxed = true,
  });

  final String icon;
  final HuAccent accent;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    if (boxed) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border),
          boxShadow: HuTokens.cardShadow,
        ),
        child: _buildInner(t),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: t.line)),
      ),
      child: _buildInner(t),
    );
  }

  Widget _buildInner(HuTokens t) {
    return Row(
      children: [
        IconBox(
          icon: icon,
          accent: accent,
          size: boxed ? 40 : 38,
          radius: boxed ? 13 : 12,
          iconSize: boxed ? 20 : 19,
        ),
        SizedBox(width: boxed ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.style(
                  15,
                  boxed ? FontWeight.w600 : FontWeight.w500,
                  t.ink,
                ),
              ),
              Text(subtitle, style: t.style(12.5, FontWeight.w600, t.ink2)),
            ],
          ),
        ),
        HuSwitch(value: value, onChanged: onChanged, semanticLabel: title),
      ],
    );
  }
}

/// `SummaryBar` (`sum` en HTML): resumen fijo encima del botón principal en Servicios.
class SummaryBar extends StatelessWidget {
  const SummaryBar({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.totalText,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
        boxShadow: HuTokens.cardShadow,
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.style(14, FontWeight.w600, t.ink),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.style(13, FontWeight.w600, t.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(totalText, style: t.style(16, FontWeight.w600, t.ink)),
        ],
      ),
    );
  }
}

/// `HuSheet` (`sheet` en HTML): hoja inferior con asa `#CFE0DB`, fondo oscurecido y radio 32.
Future<T?> showHuSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x6B12324A),
    elevation: 0,
    builder: (ctx) {
      final t = ctx.hu;
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
      final maxH = MediaQuery.sizeOf(ctx).height * 0.88;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Container(
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCFE0DB),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    builder(ctx),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// `Skeleton` (`sk` en HTML): placeholder con brillo.
class HuSkeleton extends StatefulWidget {
  const HuSkeleton({super.key, this.height = 104, this.radius = 18});
  final double height;
  final double radius;

  @override
  State<HuSkeleton> createState() => _HuSkeletonState();
}

class _HuSkeletonState extends State<HuSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F0ED),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final shift = -1.0 + 2.0 * _ctrl.value;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(shift - 1, 0),
              end: Alignment(shift + 1, 0),
              colors: const [
                Color(0xFFE6F0ED),
                Color(0xFFF2F8F6),
                Color(0xFFE6F0ED),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// `EmptyState` (`empty` en HTML): ilustración de 120×120, título, texto y botón opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.artKey,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
  });

  final String artKey;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: HuArt(artKey, width: 120, height: 120),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: t.style(22, FontWeight.w600, t.ink),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: t.style(14.5, FontWeight.w600, t.ink2, 1.4),
            ),
          ),
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: HuButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Cabecera de sección (`.sec` en HTML): título `h3` y botón de acción a la derecha.
class HuSectionHeader extends StatelessWidget {
  const HuSectionHeader(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
    this.trailingText,
    this.topMargin = 26,
    this.bottomMargin = 14,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? trailingText;
  final double topMargin;
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Padding(
      padding: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: t.h3)),
          if (actionLabel != null && onAction != null)
            HuPressable(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  actionLabel!,
                  style: t.style(14, FontWeight.w500, t.teal),
                ),
              ),
            )
          else if (trailingText != null)
            Text(
              trailingText!,
              style: t.style(13, FontWeight.w500, t.ink2),
            ),
        ],
      ),
    );
  }
}

/// Estrellas de calificación (`stars` en HTML).
class HuStars extends StatelessWidget {
  const HuStars(this.rating, {super.key, this.size = 14});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int k = 1; k <= 5; k++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: HuIcon(
              'i-star',
              size: size,
              color: rating >= k - 0.25 ? t.sun : const Color(0xFFDCE6E3),
              fill: rating >= k - 0.25 ? t.sun : const Color(0xFFDCE6E3),
              strokeWidth: 0,
            ),
          ),
      ],
    );
  }
}

/// Caja informativa (`infobox` en HTML).
class HuInfoBox extends StatelessWidget {
  const HuInfoBox({
    super.key,
    required this.icon,
    required this.text,
    this.accent = HuAccent.teal,
    this.cardStyle = false,
  });

  final String icon;
  final String text;
  final HuAccent accent;
  final bool cardStyle;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final bg = cardStyle ? Colors.white : accent.bg;
    final fg = cardStyle
        ? t.ink2
        : switch (accent) {
            HuAccent.sun => const Color(0xFF8A5B08),
            HuAccent.bad => const Color(0xFFA3271C),
            _ => t.tealDeep,
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: cardStyle ? Border.all(color: t.border) : null,
        boxShadow: cardStyle ? HuTokens.cardShadow : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: HuIcon(icon, size: 20, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: t.style(13.5, FontWeight.w600, fg, 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de texto redondeado con icono, foco reactivo y estados de error (`HuTextField`).
class HuTextField extends StatefulWidget {
  const HuTextField({
    super.key,
    required this.controller,
    this.prefixIcon,
    this.placeholder,
    this.suffix,
    this.suffixText,
    this.obscureText = false,
    this.hasError = false,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String? prefixIcon;
  final String? placeholder;
  final Widget? suffix;
  final String? suffixText;
  final bool obscureText;
  final bool hasError;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<HuTextField> createState() => _HuTextFieldState();
}

class _HuTextFieldState extends State<HuTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final borderColor = widget.hasError
        ? t.bad
        : _focused
            ? t.teal
            : t.line;
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            HuIcon(widget.prefixIcon!, size: 22, color: t.ink3),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              style: t.style(15.5, FontWeight.w600, t.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: t.style(15.5, FontWeight.w500, t.ink3),
              ),
            ),
          ),
          if (widget.suffixText != null)
            Text(
              widget.suffixText!,
              style: t.style(15.5, FontWeight.w500, t.ink2),
            ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );
  }
}
