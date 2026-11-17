import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';

class ShopState extends Equatable {
  const ShopState({
    this.speciesFilter = 'all', // 'all' | 'dog' | 'cat'
    this.categoryFilter = 'all', // 'all' | 'food' | 'toys' | 'hyg' | 'acc'
    this.query = '',
    this.selectedProductId = 'p1',
  });

  final String speciesFilter;
  final String categoryFilter;
  final String query;
  final String selectedProductId;

  List<Product> get filteredProducts {
    final q = HuFormat.norm(query.trim());
    return DemoData.products.where((p) {
      if (categoryFilter != 'all' && p.category != categoryFilter) return false;
      if (speciesFilter != 'all') {
        final sp = PetSpecies.fromKey(speciesFilter);
        if (!p.species.contains(sp)) return false;
      }
      if (q.isNotEmpty && !HuFormat.norm('${p.name} ${p.brand}').contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  ShopState copyWith({
    String? speciesFilter,
    String? categoryFilter,
    String? query,
    String? selectedProductId,
  }) =>
      ShopState(
        speciesFilter: speciesFilter ?? this.speciesFilter,
        categoryFilter: categoryFilter ?? this.categoryFilter,
        query: query ?? this.query,
        selectedProductId: selectedProductId ?? this.selectedProductId,
      );

  @override
  List<Object?> get props => [speciesFilter, categoryFilter, query, selectedProductId];
}

class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(const ShopState());

  void setSpecies(String species) =>
      emit(state.copyWith(speciesFilter: species));

  void setCategory(String category) =>
      emit(state.copyWith(categoryFilter: category));

  void setQuery(String query) => emit(state.copyWith(query: query));

  void selectProduct(String productId) =>
      emit(state.copyWith(selectedProductId: productId));
}
