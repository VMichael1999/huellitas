import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/domain/rules.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../pets/pets_bloc.dart';
import 'cart_bloc.dart';
import 'checkout_bloc.dart';
import 'shop_cubit.dart';

/// Pantalla 23: Tienda (`s-shop`).
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final shopState = context.watch<ShopCubit>().state;
    final cartState = context.watch<CartBloc>().state;
    final list = shopState.filteredProducts;

    const speciesTabs = [
      ('all', 'Todos'),
      ('dog', 'Perros'),
      ('cat', 'Gatos'),
    ];

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Tienda',
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: 'i-cart',
          label: 'Carrito',
          badgeCount: cartState.totalQty,
          onTap: () => context.push('/cart'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buscador .srch
            Container(
              height: 52,
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
                      onChanged: (v) => context.read<ShopCubit>().setQuery(v),
                      style: t.style(15, FontWeight.w600, t.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Busca alimento, juguetes…',
                        hintStyle: t.style(15, FontWeight.w500, t.ink3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Todos / Perros / Gatos
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 10),
              child: Row(
                children: [
                  for (final (idx, sp) in speciesTabs.indexed) ...[
                    if (idx > 0) const SizedBox(width: 10),
                    Expanded(
                      child: HuPressable(
                        onTap: () => context.read<ShopCubit>().setSpecies(sp.$1),
                        selected: shopState.speciesFilter == sp.$1,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: shopState.speciesFilter == sp.$1
                                ? t.tealSoft
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: shopState.speciesFilter == sp.$1
                                  ? t.teal
                                  : t.line,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            sp.$2,
                            style: t.style(
                              14.5,
                              FontWeight.w600,
                              shopState.speciesFilter == sp.$1
                                  ? t.tealDeep
                                  : t.ink2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Categorías
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (k, label) in DemoData.productCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 14),
                      child: HuChip(
                        label: label,
                        selected: shopState.categoryFilter == k,
                        onTap: () => context.read<ShopCubit>().setCategory(k),
                      ),
                    ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: HuInfoBox(
                icon: 'i-truck',
                text: 'Envío gratis en pedidos desde \$50.',
              ),
            ),

            if (list.isEmpty)
              const Center(
                child: EmptyState(
                  artKey: 'a-cat',
                  title: 'Sin resultados',
                  subtitle: 'Prueba con otra palabra o categoría.',
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 254,
                ),
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  final p = list[idx];
                  final defaultVarIdx = p.variants.length - 1;
                  final price = p.variants[defaultVarIdx].$2;
                  return HuCard(
                    padding: const EdgeInsets.all(10),
                    onTap: () {
                      context.read<ShopCubit>().selectProduct(p.id);
                      context.push('/product');
                    },
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: t.bg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: HuArt(p.artKey, width: 104, height: 104),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                height: 35,
                                child: Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.style(
                                    14,
                                    FontWeight.w600,
                                    t.ink,
                                    1.25,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                '${p.brand}${p.variants.length > 1 ? ' · ${p.variants.length} opciones' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.style(12, FontWeight.w600, t.ink2),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Money.usd2(price),
                                    style: t.style(16, FontWeight.w600, t.ink),
                                  ),
                                  HuPressable(
                                    onTap: () {
                                      context.read<CartBloc>().add(
                                            CartItemAdded(
                                              productId: p.id,
                                              variantIndex: defaultVarIdx,
                                            ),
                                          );
                                      getIt<Toaster>().show(
                                        'Agregaste ${p.name}.',
                                        actionLabel: 'Ver carrito',
                                        onAction: () => context.push('/cart'),
                                      );
                                    },
                                    semanticLabel: 'Agregar ${p.name}',
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: t.teal,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const HuIcon(
                                        'i-plus',
                                        size: 18,
                                        color: Colors.white,
                                        strokeWidth: 2.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (p.rating >= 4.9)
                          const Positioned(
                            top: 6,
                            left: 6,
                            child: StatusTag(
                              '★ Favorito',
                              accent: HuAccent.sun,
                            ),
                          ),
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

/// Pantalla 24: Producto (`s-product`).
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? _loadedProductId;
  int _variantIdx = 0;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final shopState = context.watch<ShopCubit>().state;
    final cartState = context.watch<CartBloc>().state;
    final pets = context.watch<PetsBloc>().state.pets;
    final p = DemoData.productById(shopState.selectedProductId);

    if (_loadedProductId != p.id) {
      _loadedProductId = p.id;
      _variantIdx = p.variants.length - 1;
      _qty = 1;
    }

    final unitPrice = p.variants[_variantIdx].$2;
    final hasChickenAllergy =
        pets.any((x) => x.allergies.contains('Pollo')) &&
            p.category == 'food' &&
            p.species.contains(PetSpecies.dog);

    return HuScaffold(
      showVeil: false,
      topBar: HuTopBar(
        title: '',
        clear: true,
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: 'i-cart',
          label: 'Carrito',
          badgeCount: cartState.totalQty,
          onTap: () => context.push('/cart'),
        ),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.bg.withValues(alpha: 0.0), t.bg],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: t.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  _QtyStepBtn(
                    icon: 'i-minus',
                    label: 'Menos',
                    onTap: () =>
                        setState(() => _qty = math.max(1, _qty - 1)),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$_qty',
                      textAlign: TextAlign.center,
                      style: t.style(15, FontWeight.w600, t.ink),
                    ),
                  ),
                  _QtyStepBtn(
                    icon: 'i-plus',
                    label: 'Más',
                    onTap: () =>
                        setState(() => _qty = math.min(9, _qty + 1)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HuButton(
                label: 'Agregar · ${Money.usd2(unitPrice * _qty)}',
                onPressed: () {
                  context.read<CartBloc>().add(CartItemAdded(
                        productId: p.id,
                        variantIndex: _variantIdx,
                        qty: _qty,
                      ));
                  getIt<Toaster>().show(
                    'Agregaste $_qty × ${p.name}.',
                    actionLabel: 'Ver carrito',
                    onAction: () => context.push('/cart'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, t.tealSoft],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(38),
                ),
              ),
              alignment: Alignment.center,
              child: HuArt(p.artKey, width: 210, height: 210),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(p.brand, style: t.style(13, FontWeight.w500, t.ink2)),
                  const SizedBox(height: 4),
                  Text(p.name, style: t.h1Large),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      HuStars(p.rating, size: 15),
                      const SizedBox(width: 8),
                      Text(
                        '${p.rating}',
                        style: t.style(13.5, FontWeight.w700, t.ink),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${p.reviews} reseñas)',
                        style: t.style(13, FontWeight.w600, t.ink2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    Money.usd2(unitPrice),
                    style: t.style(30, FontWeight.w600, t.ink),
                  ),

                  if (p.variants.length > 1) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Presentación',
                      style: t.style(13, FontWeight.w600, t.ink2),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final (idx, v) in p.variants.indexed) ...[
                          if (idx > 0) const SizedBox(width: 10),
                          Expanded(
                            child: HuPressable(
                              onTap: () => setState(() => _variantIdx = idx),
                              selected: _variantIdx == idx,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _variantIdx == idx
                                      ? t.tealSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color:
                                        _variantIdx == idx ? t.teal : t.line,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  v.$1,
                                  style: t.style(
                                    14.5,
                                    FontWeight.w600,
                                    _variantIdx == idx ? t.tealDeep : t.ink2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  Text(
                    p.description,
                    style: t.style(14.5, FontWeight.w600, t.ink2, 1.55),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sp in p.species)
                        StatusTag(
                          'Para ${sp == PetSpecies.dog ? 'perros' : 'gatos'}',
                          icon: 'i-paw',
                          accent: sp == PetSpecies.dog
                              ? HuAccent.teal
                              : HuAccent.coral,
                        ),
                      const StatusTag(
                        'Llega en 2 a 3 días',
                        icon: 'i-truck',
                        accent: HuAccent.muted,
                      ),
                    ],
                  ),
                  if (hasChickenAllergy)
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: HuInfoBox(
                        icon: 'i-check',
                        text:
                            'No tiene pollo: apto para la alergia de Milo.',
                      ),
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

class _QtyStepBtn extends StatelessWidget {
  const _QtyStepBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: HuIcon(icon, size: 16, color: t.ink, strokeWidth: 2.6),
      ),
    );
  }
}

/// Pantalla 25: Carrito (`s-cart`).
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final cartState = context.watch<CartBloc>().state;
    final st = cartState.subtotal;
    final left = cartState.remainingForFreeShipping;
    final progress =
        (st / BookingPricingRules.freeShippingThreshold).clamp(0.0, 1.0);

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Tu carrito',
        onBack: () => context.pop(),
      ),
      bottomBar: cartState.lines.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [t.bg.withValues(alpha: 0.0), t.bg],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Column(
                      children: [
                        _SummaryPriceRow(
                          label: 'Subtotal (${cartState.totalQty})',
                          value: Money.usd2(st),
                        ),
                        _SummaryPriceRow(
                          label: 'Envío estándar',
                          value: left > 0 ? Money.usd2(4.99) : 'Gratis',
                        ),
                        _SummaryPriceRow(
                          label: 'Total',
                          value: Money.usd2(cartState.standardTotal),
                          isTotal: true,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  HuButton(
                    label: 'Ir a pagar',
                    variant: HuButtonVariant.pay,
                    onPressed: () {
                      context.read<CheckoutBloc>().add(const CheckoutReset());
                      context.push('/checkout');
                    },
                  ),
                ],
              ),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 220),
        child: cartState.lines.isEmpty
            ? Center(
                child: EmptyState(
                  artKey: 'a-bone',
                  title: 'Tu carrito está vacío',
                  subtitle:
                      'Mira alimento, juguetes y accesorios para tus mascotas.',
                  buttonLabel: 'Ir a la tienda',
                  onButtonPressed: () => context.push('/shop'),
                ),
              )
            : Column(
                children: [
                  // Barra de envío gratis .ship
                  HuCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (left > 0)
                          RichText(
                            text: TextSpan(
                              text: 'Te faltan ',
                              style: t.style(13.5, FontWeight.w500, t.ink),
                              children: [
                                TextSpan(
                                  text: Money.usd2(left),
                                  style: t.style(
                                    13.5,
                                    FontWeight.w700,
                                    t.tealDeep,
                                  ),
                                ),
                                const TextSpan(text: ' para el envío gratis'),
                              ],
                            ),
                          )
                        else
                          Text(
                            '¡Tienes envío gratis!',
                            style: t.style(13.5, FontWeight.w500, t.ink),
                          ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8,
                            width: double.infinity,
                            child: ColoredBox(
                              color: t.chip,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [t.teal, const Color(0xFF2BB3A2)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  for (final (idx, line) in cartState.lines.indexed)
                    Builder(
                      builder: (_) {
                        final p = DemoData.productById(line.productId);
                        final v = p.variants[
                            line.variantIndex.clamp(0, p.variants.length - 1)];
                        return HuCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: t.bg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: HuArt(p.artKey, width: 58, height: 58),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: t.style(
                                        14.5,
                                        FontWeight.w600,
                                        t.ink,
                                      ),
                                    ),
                                    Text(
                                      '${v.$1} · ${Money.usd2(v.$2)} c/u',
                                      style: t.style(
                                        12.5,
                                        FontWeight.w600,
                                        t.ink2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: t.bg,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            children: [
                                              _QtyStepBtn(
                                                icon: 'i-minus',
                                                label: 'Menos',
                                                onTap: () => context
                                                    .read<CartBloc>()
                                                    .add(
                                                      CartItemQtyDelta(
                                                        index: idx,
                                                        delta: -1,
                                                      ),
                                                    ),
                                              ),
                                              SizedBox(
                                                width: 26,
                                                child: Text(
                                                  '${line.qty}',
                                                  textAlign: TextAlign.center,
                                                  style: t.style(
                                                    14.5,
                                                    FontWeight.w600,
                                                    t.ink,
                                                  ),
                                                ),
                                              ),
                                              _QtyStepBtn(
                                                icon: 'i-plus',
                                                label: 'Más',
                                                onTap: () => context
                                                    .read<CartBloc>()
                                                    .add(
                                                      CartItemQtyDelta(
                                                        index: idx,
                                                        delta: 1,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          Money.usd2(
                                            cartState.lineTotal(line),
                                          ),
                                          style: t.style(
                                            15,
                                            FontWeight.w600,
                                            t.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              HuPressable(
                                onTap: () {
                                  final cartBloc = context.read<CartBloc>();
                                  cartBloc.add(CartItemRemoved(idx));
                                  getIt<Toaster>().show(
                                    'Quitaste ${p.name}.',
                                    actionLabel: 'Deshacer',
                                    onAction: () => cartBloc.add(
                                      CartItemRestored(
                                        index: idx,
                                        line: line,
                                      ),
                                    ),
                                  );
                                },
                                semanticLabel: 'Quitar',
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: HuIcon(
                                    'i-trash',
                                    size: 20,
                                    color: t.ink3,
                                  ),
                                ),
                              ),
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

class _SummaryPriceRow extends StatelessWidget {
  const _SummaryPriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isTotal;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: t.style(14.5, FontWeight.w600, t.ink2)),
          Text(
            value,
            style: t.style(isTotal ? 18 : 14.5, FontWeight.w600, t.ink),
          ),
        ],
      ),
    );
  }
}

/// Pantalla 26: Checkout (`s-checkout`).
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final cartState = context.watch<CartBloc>().state;
    final co = context.watch<CheckoutBloc>().state;

    final st = cartState.subtotal;
    final shipC = co.shippingFee(st);
    final tot = co.total(st);
    final card = DemoData.cards.first;

    final shippingOptions = [
      (
        'std',
        'Estándar',
        '2 a 3 días',
        st >= 50 ? 'Gratis' : Money.usd2(4.99),
        'i-bag',
        HuAccent.sun,
      ),
      (
        'exp',
        'Express',
        'Hoy, antes de las 8:00 p. m.',
        Money.usd2(9.99),
        'i-truck',
        HuAccent.coral,
      ),
    ];

    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (a, b) => a.phase != b.phase && b.phase == CheckoutPhase.paid,
      listener: (context, state) {
        final orderId = 'PED-${2200 + cartState.orders.length + 11}';
        final qty = cartState.totalQty;
        final order = Order(
          id: orderId,
          date: HuFormat.iso(today),
          items: qty,
          total: tot,
          status: 'Preparando',
        );
        context.read<CartBloc>().add(CartOrderPlaced(order));
        context.read<AppointmentsBloc>().add(
              AppointmentsDoneShown(
                DoneScreenData(
                  title: '¡Pedido confirmado!',
                  subtitle:
                      'Pagaste ${Money.usd2(tot)}. ${state.isExpress ? 'Llega hoy antes de las 8:00 p. m.' : 'Llega en 2 a 3 días.'}',
                  order: order,
                  isExpressOrder: state.isExpress,
                ),
              ),
            );
        context.go('/done');
      },
      child: HuScaffold(
        topBar: HuTopBar(
          title: 'Pagar pedido',
          onBack: () => context.pop(),
        ),
        bottomBar: Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [t.bg.withValues(alpha: 0.0), t.bg],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HuButton(
                variant: HuButtonVariant.pay,
                loading: co.phase == CheckoutPhase.paying,
                label: co.phase == CheckoutPhase.paying
                    ? 'Procesando pago…'
                    : 'Pagar ${Money.usd2(tot)}',
                onPressed: () =>
                    context.read<CheckoutBloc>().add(const CheckoutPayRequested()),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HuIcon('i-lock', size: 15, color: t.ink3),
                  const SizedBox(width: 7),
                  Text(
                    'Pago seguro y cifrado',
                    style: t.style(12.5, FontWeight.w600, t.ink3),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HuSectionHeader('Entregar en', topMargin: 4),
              for (final (idx, a) in DemoData.addresses.indexed)
                HuCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  selected: co.addressIndex == idx,
                  onTap: () => context
                      .read<CheckoutBloc>()
                      .add(CheckoutAddressSelected(idx)),
                  child: Row(
                    children: [
                      IconBox(
                        icon: idx == 0 ? 'i-house' : 'i-store',
                        accent: HuAccent.teal,
                        size: 42,
                        radius: 14,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: t.style(15.5, FontWeight.w600, t.ink),
                            ),
                            Text(
                              a.address,
                              style: t.style(13, FontWeight.w600, t.ink2),
                            ),
                          ],
                        ),
                      ),
                      _CheckoutRadio(selected: co.addressIndex == idx),
                    ],
                  ),
                ),

              const HuSectionHeader('Envío'),
              for (final opt in shippingOptions)
                HuCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  selected: co.shippingKind == opt.$1,
                  onTap: () => context
                      .read<CheckoutBloc>()
                      .add(CheckoutShippingSelected(opt.$1)),
                  child: Row(
                    children: [
                      IconBox(
                        icon: opt.$5,
                        accent: opt.$6,
                        size: 42,
                        radius: 14,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.$2,
                              style: t.style(15.5, FontWeight.w600, t.ink),
                            ),
                            Text(
                              opt.$3,
                              style: t.style(13, FontWeight.w600, t.ink2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        opt.$4,
                        style: t.style(15, FontWeight.w600, t.ink),
                      ),
                      const SizedBox(width: 12),
                      _CheckoutRadio(selected: co.shippingKind == opt.$1),
                    ],
                  ),
                ),

              const HuSectionHeader('Pago'),
              HuCard(
                selected: true,
                onTap: () => getIt<Toaster>()
                    .show('Aquí eliges u agregas otra tarjeta.'),
                child: Row(
                  children: [
                    const IconBox(
                      icon: 'i-card',
                      accent: HuAccent.lav,
                      size: 42,
                      radius: 14,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${card.brand} •••• ${card.last4}',
                            style: t.style(15.5, FontWeight.w600, t.ink),
                          ),
                          Text(
                            'Tarjeta guardada',
                            style: t.style(13, FontWeight.w600, t.ink2),
                          ),
                        ],
                      ),
                    ),
                    HuIcon('i-chev', size: 20, color: t.ink3),
                  ],
                ),
              ),

              const HuSectionHeader('Resumen'),
              HuCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Column(
                  children: [
                    _SummaryPriceRow(
                      label: 'Productos (${cartState.totalQty})',
                      value: Money.usd2(st),
                    ),
                    _SummaryPriceRow(
                      label: 'Envío',
                      value: shipC > 0 ? Money.usd2(shipC) : 'Gratis',
                    ),
                    _SummaryPriceRow(
                      label: 'Total',
                      value: Money.usd2(tot),
                      isTotal: true,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutRadio extends StatelessWidget {
  const _CheckoutRadio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? t.teal : t.line,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: t.teal,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
