import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import 'svg_data.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

final Map<String, String> _iconSvgCache = {};
final Map<String, String> _dqSvgCache = {};

/// Ícono de línea de `viewBox 0 0 24 24` del prototipo HTML.
class HuIcon extends StatelessWidget {
  const HuIcon(
    this.name, {
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 1.9,
    this.fill,
  });

  final String name;
  final double size;
  final Color? color;
  final double strokeWidth;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF1D2A44);
    final k = name.startsWith('i-') ? name : 'i-$name';
    final isFilledHeart = k == 'i-heartf';
    final fillHex = isFilledHeart
        ? 'currentColor'
        : (fill != null ? _hex(fill!) : 'none');
    final strokeAttr = isFilledHeart ? 'none' : 'currentColor';
    final cacheKey = '$k|$strokeWidth|$fillHex';
    final svg = _iconSvgCache.putIfAbsent(
      cacheKey,
      () =>
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="$fillHex" stroke="$strokeAttr" stroke-width="$strokeWidth" '
          'stroke-linecap="round" stroke-linejoin="round">${kHuIcons[k] ?? ''}</svg>',
    );
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: c),
    );
  }
}

/// Íconos a dos tonos (`DQ` en el prototipo HTML): accesos rápidos, salud, recordatorios y servicios.
class HuDqIcon extends StatelessWidget {
  const HuDqIcon(
    this.kind, {
    super.key,
    required this.color,
    this.size = 36,
  });

  final String kind;
  final Color color;
  final double size;

  static String _buildSvg(String kind, String c) {
    switch (kind) {
      case 'cal':
        final dots = [
          [10.0, 17.0],
          [16.0, 17.0],
          [22.0, 17.0],
          [10.0, 22.5],
          [16.0, 22.5],
          [22.0, 22.5],
        ]
            .map((p) =>
                '<rect x="${p[0] - 1.7}" y="${p[1] - 1.5}" width="3.4" height="3" rx="1" fill="#fff"/>')
            .join();
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect x="4" y="6" width="24" height="22" rx="5" fill="$c"/><rect x="4" y="6" width="24" height="7" rx="3" fill="$c" opacity=".55"/><rect x="9" y="3" width="3" height="7" rx="1.5" fill="$c"/><rect x="20" y="3" width="3" height="7" rx="1.5" fill="$c"/>$dots</svg>';
      case 'steth':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="$c" stroke-width="2.6" stroke-linecap="round"><path d="M8 4v8a6 6 0 0 0 12 0V4"/><path d="M14 18v3a6 6 0 0 0 12 0v-3"/><circle cx="26" cy="15" r="3" fill="#fff"/></svg>';
      case 'folder':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M3 9a3 3 0 0 1 3-3h7l3 3h10a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3z" fill="$c"/><path d="M3 12h26" stroke="#fff" stroke-opacity=".35" stroke-width="1.5"/><path d="M16 14.5v8M12 18.5h8" stroke="#fff" stroke-width="2.6" stroke-linecap="round"/></svg>';
      case 'scissors':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="$c" stroke-width="2.8" stroke-linecap="round"><circle cx="9" cy="24" r="4.2"/><circle cx="23" cy="24" r="4.2"/><path d="M11.5 20.6 24 4M20.5 20.6 8 4"/></svg>';
      case 'bell':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M16 4a8 8 0 0 0-8 8v5.5L5.5 22a1 1 0 0 0 .9 1.5h19.2a1 1 0 0 0 .9-1.5L24 17.5V12a8 8 0 0 0-8-8z" fill="$c"/><path d="M12.5 26a3.5 3.5 0 0 0 7 0z" fill="$c" opacity=".7"/></svg>';
      case 'bag':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M11 11V9a5 5 0 0 1 10 0v2" fill="none" stroke="$c" stroke-width="2.6" stroke-linecap="round"/><path d="M6.5 11h19l-1.3 15.2A2.5 2.5 0 0 1 21.7 28.5H10.3a2.5 2.5 0 0 1-2.5-2.3z" fill="$c"/><path d="M12 15.5a4 4 0 0 0 8 0" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity=".8"/></svg>';
      case 'paw':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="$c"><ellipse cx="9" cy="13" rx="2.6" ry="3.2"/><ellipse cx="14" cy="8.5" rx="2.6" ry="3.2"/><ellipse cx="20" cy="9.5" rx="2.6" ry="3.2"/><ellipse cx="24.5" cy="15" rx="2.4" ry="3"/><path d="M11 23c0-3.8 2.7-6.8 5.8-6.8S23 19.4 23 22.7c0 2.5-1.9 4-4.2 3.5-1.1-.3-1.6-.8-2.4-.8s-1.5.7-2.7.8C12.1 26.5 11 25.6 11 23z"/></svg>';
      case 'weight':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M8 8h16l3 18a2 2 0 0 1-2 2.3H7A2 2 0 0 1 5 26z" fill="$c"/><path d="M11 13a5 5 0 0 1 10 0" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/><path d="M16 13l2-2.5" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg>';
      case 'drop':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M16 3.5c4.5 6 9 11 9 16a9 9 0 0 1-18 0c0-5 4.5-10 9-16z" fill="$c"/><path d="M11.5 20a4.5 4.5 0 0 0 4.5 4.5" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity=".7"/></svg>';
      case 'smile':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><circle cx="16" cy="16" r="12.5" fill="$c"/><circle cx="11.8" cy="13.5" r="1.8" fill="#7A3A0A"/><circle cx="20.2" cy="13.5" r="1.8" fill="#7A3A0A"/><path d="M10.5 18.5a6 6 0 0 0 11 0" fill="none" stroke="#7A3A0A" stroke-width="2" stroke-linecap="round"/></svg>';
      case 'syringe':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect x="5" y="6" width="22" height="21" rx="6" fill="$c"/><path d="M11 21l8.5-8.5M17.5 10.5l4 4M20 8l4 4M12.5 19.5l-2 2" stroke="#fff" stroke-width="2.3" stroke-linecap="round"/></svg>';
      case 'pill':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect x="5" y="6" width="22" height="21" rx="6" fill="$c"/><g transform="rotate(-45 16 16.5)"><rect x="9" y="12.5" width="14" height="8" rx="4" fill="#fff"/><path d="M16 12.5v8" stroke="$c" stroke-width="1.6"/></g></svg>';
      case 'house':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><path d="M4 15 16 5l12 10v11a2 2 0 0 1-2 2h-6v-7h-8v7H6a2 2 0 0 1-2-2z" fill="$c"/><path d="M2.5 15.5 16 4.5l13.5 11" fill="none" stroke="$c" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" opacity=".6"/></svg>';
      case 'walker':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="$c" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="18" cy="5.5" r="2.8" fill="$c" stroke="none"/><path d="M15 11l-4 4v5M15 11l4 3 4 1M15 11l-1 8 5 4 1 6M14 19l-4 9"/></svg>';
      case 'lotus':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="$c" stroke-width="2.3" stroke-linejoin="round"><path d="M16 6c3 3.5 4 7 4 10s-1.6 6-4 8c-2.4-2-4-5-4-8s1-6.5 4-10z" fill="$c" fill-opacity=".18"/><path d="M8.5 11c3 .8 5.6 3.4 6.4 7.6.5 2.6.4 4.8 1.1 5.6-3.8.3-7.4-1.4-8.6-5.6-.7-2.4 0-5 1.1-7.6zM23.5 11c-3 .8-5.6 3.4-6.4 7.6-.5 2.6-.4 4.8-1.1 5.6 3.8.3 7.4-1.4 8.6-5.6.7-2.4 0-5-1.1-7.6z"/><path d="M4 18c2 4 6 6.5 12 6.5S26 22 28 18"/></svg>';
      case 'clipper':
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="$c" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M21 4.5 25.5 9 12 22.5 8 26.5a2.4 2.4 0 0 1-3.4-3.4L8.6 19 22 5.5z" fill="$c" fill-opacity=".18"/><path d="M8.6 19l4.4 4.4M17 9.5l5 5"/></svg>';
      default:
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><circle cx="16" cy="16" r="12" fill="$c"/></svg>';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cHex = _hex(color);
    final key = '$kind|$cHex';
    final svg = _dqSvgCache.putIfAbsent(key, () => _buildSvg(kind, cHex));
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// Ilustración 3D (o respaldo SVG para `a-board`), idéntica a `art(id)` del HTML.
class HuArt extends StatelessWidget {
  const HuArt(
    this.artKey, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String artKey;
  final double? width;
  final double? height;
  final BoxFit fit;

  static const Set<String> _has3d = {
    'a-bed',
    'a-bone',
    'a-bunny',
    'a-cat',
    'a-catfood',
    'a-collar',
    'a-dog',
    'a-food',
    'a-groom',
    'a-litter',
    'a-nails',
    'a-shampoo',
    'a-spa',
    'a-treats',
    'a-vet',
    'a-walk',
  };

  @override
  Widget build(BuildContext context) {
    final normalized = artKey.startsWith('a-') ? artKey : 'a-$artKey';
    if (artKey == 'logo') {
      return Image.asset(
        'assets/logo/huellitas-logo-cola.png',
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      );
    }
    if (_has3d.contains(normalized)) {
      return Image.asset(
        'assets/illustrations-3d/$normalized.png',
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      );
    }
    final svg = kHuArts[normalized] ?? kHuArts['a-dog']!;
    return SvgPicture.string(
      svg,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// Avatar de persona (3D para veterinarios/paseadores en `IMGS`, SVG para `yo` Michael Dev).
class HuPersonAvatar extends StatelessWidget {
  const HuPersonAvatar(
    this.avatarId, {
    super.key,
    this.size = 54,
    this.height,
    this.borderRadius,
    this.alignment = Alignment.center,
  });

  final String avatarId;
  final double size;
  final double? height;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  static const Set<String> _has3d = {
    'andres',
    'camila',
    'diego',
    'lucia',
    'mateo',
    'me',
    'sofia',
  };

  @override
  Widget build(BuildContext context) {
    final id = avatarId.startsWith('p-') ? avatarId.substring(2) : avatarId;
    final h = height ?? size;
    final br = borderRadius ?? BorderRadius.circular(size);
    Widget inner;
    if (_has3d.contains(id)) {
      inner = Image.asset(
        'assets/avatars-3d/p-$id.png',
        width: size,
        height: h,
        fit: BoxFit.cover,
        alignment: alignment,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      );
    } else {
      final svg = kHuAvatarsSvg[id] ?? kHuAvatarsSvg['yo']!;
      inner = SvgPicture.string(
        svg,
        width: size,
        height: h,
        fit: BoxFit.cover,
      );
    }
    return ClipRRect(
      borderRadius: br,
      child: SizedBox(
        width: size,
        height: h,
        child: inner,
      ),
    );
  }
}

class HuShieldSvg extends StatelessWidget {
  const HuShieldSvg({super.key, this.width = 96, this.height = 80});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(kShieldSvg, width: width, height: height);
}
