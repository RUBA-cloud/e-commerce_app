class MakeOrderRequest {
  const MakeOrderRequest({
    required this.cartId,
    required this.address,
    required this.streetName,
    required this.buildingNumber,
    required this.lat,
    required this.long,
    required this.orderStatusId,
    required this.totalPrice,
    required this.products,
  });

  final int cartId;
  final String address;
  final String streetName;
  final String buildingNumber;   // string per API
  final double lat;
  final double long;
  final int orderStatusId;
  final double totalPrice;
  final List<OrderProductItem> products;

  factory MakeOrderRequest.fromJson(Map<String, dynamic> json) =>
      MakeOrderRequest(
        cartId: json['cart_id'],
        address: json['address'],
        streetName: json['street_name'],
        buildingNumber: json['building_number'].toString(),
        lat: (json['lat'] as num).toDouble(),
        long: (json['long'] as num).toDouble(),
        orderStatusId: json['order_status_id'],
        totalPrice: (json['total_price'] as num).toDouble(),
        products: (json['products'] as List)
            .map((p) => OrderProductItem.fromJson(p))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'cart_id': cartId,
    'address': address,
    'street_name': streetName,
    'building_number': buildingNumber,
    'lat': lat,
    'long': long,
    'order_status_id': orderStatusId,
    'total_price': totalPrice,
    'products': products.map((p) => p.toJson()).toList(),
  };
}

class OrderProductItem {
  const OrderProductItem({
    required this.productId,
    required this.sizeId,
    required this.quantity,
    required this.colors,
  });

  final int productId;
  final int sizeId;
  final int quantity;
  final List<String> colors;   // array per API

  factory OrderProductItem.fromJson(Map<String, dynamic> json) =>
      OrderProductItem(
        productId: json['product_id'],
        sizeId: json['size_id'],
        quantity: json['quantity'],
        colors: List<String>.from(json['colors']),
      );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'size_id': sizeId,
    'quantity': quantity,
    'colors': colors,
  };
}