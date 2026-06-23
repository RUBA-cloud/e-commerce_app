import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UpdatePaymentRequest {
  @JsonKey(name: 'payment_id')
   final int? paymentId;

  UpdatePaymentRequest({
    this.paymentId,
  });
  Map<String, dynamic> toJson() {
    return {
      "payment_id":this.paymentId
    };
  }
  }