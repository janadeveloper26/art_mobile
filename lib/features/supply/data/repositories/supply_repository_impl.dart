import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/supply/data/models/product_model.dart';
import 'package:art_mobile/features/supply/domain/repositories/supply_repository.dart';

class SupplyRepositoryImpl implements ISupplyRepository {
  final ApiClient apiClient;

  SupplyRepositoryImpl({required this.apiClient});

  @override
  Future<List<Product>> getProducts() async {
    final response = await apiClient.get('supply/products');
    if (response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Invalid data format from API');
  }
}
