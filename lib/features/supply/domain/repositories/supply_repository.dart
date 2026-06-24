import 'package:art_mobile/features/supply/data/models/product_model.dart';

abstract class ISupplyRepository {
  Future<List<Product>> getProducts();
}
