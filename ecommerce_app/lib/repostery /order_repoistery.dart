// lib/features/orders/data/order_repository.dart

import 'package:ecommerce_app/constants/api_routes.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/services/check_connecctivity.dart';
import 'package:ecommerce_app/services/get_services.dart';
import 'package:ecommerce_app/services/post_services.dart';
import 'package:ecommerce_app/services/sql/order_local.dart'
    show OrderLocalDataSource;

/// -----------------------------
/// ORDER REPOSITORY CONTRACT
/// -----------------------------
abstract class OrderRepository {
  /// يرسل طلب جديد إلى الـ API
  Future<bool> sendOrder(OrderModel order,int cartId);

  /// يجلب كل الطلبات (أونلاين / أوفلاين)
  Future<List<OrderModel>> fetchAll();

  /// تحميل الطلبات من SQLite فقط
  Future<List<OrderModel>> loadSql();

  /// حفظ الطلبات في SQLite فقط
  Future<void> saveDataSql(List<OrderModel> orders);
}

/// --------------------------------------
/// API ORDER REPOSITORY IMPLEMENTATION
/// --------------------------------------
class ApiOrderRepository implements OrderRepository {
  final OrderLocalDataSource _local = OrderLocalDataSource.instance;

  @override
  Future<List<OrderModel>> fetchAll() async {
    // 1) لو ما في إنترنت → رجّع البيانات من SQLite
    if (!await checkConnectivity()) {
      return loadSql();
    }

    // 2) في إنترنت → حاول تجيب من الـ API
    final result =
        await GetService.I.getList(orders, options: authOptions);

    if (result.isEmpty) {
      // ريسبونس null → استخدم الكاش
      return loadSql();
    }

    // بعض الـ APIs ترجع { status, message, data: [...] }
    dynamic listSource = result;
    if (result['data'] is List) {
      listSource = result['data'];
    }

    if (listSource is! List) {
      // فورمات غريب → استخدم الكاش أو ارمي خطأ
      final cached = await loadSql();
      if (cached.isNotEmpty) return cached;
      throw const FormatException('Unexpected orders response format');
    }

    final list = listSource
        .map<OrderModel>(
          (e) => OrderModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    // 3) لو السيرفر رجّع بيانات → خزّنها في SQLite وارجعها
    if (list.isNotEmpty) {
      await saveDataSql(list);
      return list;
    }

    // 4) لو السيرفر رجّع ليست فاضية → جرب الكاش
    final cached = await loadSql();
    return cached;
  }

  @override
  Future<bool> sendOrder(OrderModel order,int cartId) async {
    // نبني List من المنتجات في الطلب
    final List<Map<String, dynamic>> products = [];
    for (final item in order.items) {
      products.add({
        "product_id": item.productId,
        "size_id": item.size?.id,
        "quantity": item.quantity,
        'total_price':item.price * item.quantity,
        'additionals_id':item.additionalModel,
        "colors":   [item.color]
      });
    }
final double sumTotal = products.fold<double>(
  0.0,
  (sum, e) => sum + ((e["total_price"] ?? 0) as num).toDouble(),
);    final Map<String, dynamic> body = {
      "products": products,
      "address": order.address,
      "street_name": order.streetName,
      "building_number": order.buildingNumber,
      "lat": order.lat,
      "total_price":sumTotal,
      "long": order.long,
              'cart_id':cartId,
     "additionals_ids":order.productAdditional
    };

    final response = await PostServices.I.post(
      makeOrder,
      data: body,
      options: authOptions,
    );

    // حسب الـ API تبعك عدلي الشرط:
    // مثال: { "status": "success", ... }
    return response.statusCode !=500;
  }

  @override
  Future<List<OrderModel>> loadSql() {
    return _local.getOrders();
  }

  @override
  Future<void> saveDataSql(List<OrderModel> orders) {
    return _local.saveOrders(orders);
  }
}
