// lib/pages/orders/order_invoice_pdf_page.dart

import 'dart:typed_data';

import 'package:ecommerce_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// صفحة عرض الفاتورة كملف PDF حقيقي
class OrderInvoicePdfPage extends StatelessWidget {
  const OrderInvoicePdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args is! OrderModel) {
      return Scaffold(
        appBar: AppBar(
          title: Text('order_invoice_title'.tr),
          centerTitle: true,
        ),
        body: Center(
          child: Text('order_invoice_missing'.tr),
        ),
      );
    }

    final OrderModel order = args;
    final Uint8List pdfBytes = _buildInvoicePdf(order);

    return Scaffold(
      appBar: AppBar(
        title: Text('order_invoice_title'.tr),
        centerTitle: true,
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}

/// يبني ملف PDF للفاتورة ويعيده كـ Uint8List
Uint8List _buildInvoicePdf(OrderModel order) {
  final String appName = 'app_name'.tr;
  final String orderNumberLabel = 'order_number'.tr;
  final String orderDateLabel = 'order_date'.tr;
  final String deliveryAddressLabel = 'order_delivery_address'.tr;
  final String itemsTitle = 'order_items_title'.tr;
  final String qtyLabel = 'order_item_quantity'.tr;
  final String priceLabel = 'order_item_price'.tr;
  final String totalLabel = 'order_item_total'.tr;
  final String subtotalLabel = 'subtotal'.tr;
  final String discountLabel = 'discount'.tr;
  final String shippingLabel = 'shipping'.tr;
  final String grandTotalLabel = 'total'.tr;

  // مع الموديل الجديد، items غير قابلة لأن تكون null
  final items = order.items;
  final currency =
      'currency_symbol'.tr.isEmpty ? 'JOD' : 'currency_symbol'.tr;

  // احسب الإجمالي من العناصر
  double itemsTotal = 0;
  for (final item in items) {
    final int q = item.quantity;
    final double price = item.price;
    itemsTotal += q * price;
  }
  // totalPrice غير nullable في الموديل الجديد
  final double orderTotal = order.totalPrice;

  // ===== إنشاء المستند =====
  final PdfDocument document = PdfDocument();
  final PdfPage page = document.pages.add();
  final Size pageSize = page.getClientSize();

  final PdfFont titleFont =
      PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
  final PdfFont headerFont =
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
  final PdfFont normalFont =
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.regular);

  double y = 20;

  // ========= HEADER =========
  page.graphics.drawString(
    appName,
    titleFont,
    bounds: Rect.fromLTWH(0, y, pageSize.width, 30),
    format: PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.middle,
    ),
  );

  page.graphics.drawString(
    '$orderNumberLabel #${order.id ?? ''}',
    normalFont,
    bounds: Rect.fromLTWH(0, y + 28, pageSize.width / 2, 20),
  );

  page.graphics.drawString(
    '$orderDateLabel: ${order.createdAt.toString()}',
    normalFont,
    bounds: Rect.fromLTWH(pageSize.width / 2, y + 28, pageSize.width / 2, 20),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );

  y += 60;

  // ========= ADDRESS =========
  page.graphics.drawString(
    deliveryAddressLabel,
    headerFont,
    bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
  );
  y += 20;

  final String addr = order.address.isNotEmpty
      ? order.address
      : 'address_details_hint'.tr;

  final PdfTextElement addressElement = PdfTextElement(
    text: addr,
    font: normalFont,
  );
  // draw قد يرجع null، لذلك نتعامل مع ذلك بدون إنشاء PdfLayoutResult يدويًا
  final PdfLayoutResult? addrResult = addressElement.draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, pageSize.width, 60),
  );
  if (addrResult != null) {
    y = addrResult.bounds.bottom + 20;
  } else {
    y += 60; // fallback بسيط لو رجع null
  }

  // ========= ITEMS TITLE =========
  page.graphics.drawString(
    itemsTitle,
    headerFont,
    bounds: Rect.fromLTWH(0, y, pageSize.width, 20),
  );
  y += 24;

  // ========= ITEMS TABLE =========
  final PdfGrid grid = PdfGrid();
  grid.style = PdfGridStyle(
    font: normalFont,
    cellPadding: PdfPaddings(left: 4, right: 4, top: 3, bottom: 3),
  );

  grid.columns.add(count: 4);
  grid.headers.add(1);
  final PdfGridRow header = grid.headers[0];
  header.cells[0].value = 'order_item_product'.tr;
  header.cells[1].value = qtyLabel;
  header.cells[2].value = priceLabel;
  header.cells[3].value = totalLabel;

  header.style = PdfGridRowStyle(
    backgroundBrush: PdfSolidBrush(PdfColor(240, 240, 240)),
    textPen: PdfPens.black,
    font: headerFont,
  );

  for (final item in items) {
    final row = grid.rows.add();
    final productName = (Get.locale?.languageCode == 'ar')
        ? (item.product?.nameAr ?? item.product?.nameEn ?? '${'order_item_product'.tr} #${item.productId}')
        : (item.product?.nameEn ?? item.product?.nameAr ?? '${'order_item_product'.tr} #${item.productId}');
    final int qty = item.quantity;
    final double price = item.price;
    final double lineTotal = item.totalPrice;

    row.cells[0].value = productName;
    row.cells[1].value = 'x$qty';
    row.cells[2].value = '${price.toStringAsFixed(2)} $currency';
    row.cells[3].value = '${lineTotal.toStringAsFixed(2)} $currency';
  }

  final PdfLayoutResult? gridResult = grid.draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, pageSize.width, pageSize.height - y - 120),
  );
  if (gridResult != null) {
    y = gridResult.bounds.bottom + 20;
  } else {
    y += 80; // fallback لو رجع null
  }

  // ========= TOTALS =========
  final double rightColX = pageSize.width * 0.5;

  void drawTotalLine(String label, String value, {bool bold = false}) {
    final font = bold ? headerFont : normalFont;
    page.graphics.drawString(
      label,
      font,
      bounds: Rect.fromLTWH(
        rightColX,
        y,
        pageSize.width * 0.25,
        18,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );
    page.graphics.drawString(
      value,
      font,
      bounds: Rect.fromLTWH(
        rightColX + pageSize.width * 0.25,
        y,
        pageSize.width * 0.25,
        18,
      ),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    y += 18;
  }

  drawTotalLine(
    subtotalLabel,
    '${itemsTotal.toStringAsFixed(2)} $currency',
  );
  drawTotalLine(
    discountLabel,
    '0.00 $currency',
  );
  drawTotalLine(
    shippingLabel,
    '0.00 $currency',
  );

  y += 4;
  page.graphics.drawLine(
    PdfPen(PdfColor(180, 180, 180)),
    Offset(rightColX, y),
    Offset(pageSize.width, y),
  );
  y += 6;

  drawTotalLine(
    grandTotalLabel,
    '${orderTotal.toStringAsFixed(2)} $currency',
    bold: true,
  );

  // ========= FOOT NOTE =========
  y += 20;
  final String thankKey = 'thank_you'.tr;
  final String thankText = thankKey == 'thank_you'
      ? 'Thank you for your purchase!'
      : thankKey;

  final PdfTextElement noteElement = PdfTextElement(
    text: thankText,
    font: normalFont,
  );
  noteElement.draw(
    page: page,
    bounds: Rect.fromLTWH(0, y, pageSize.width, 40),
  );

  // ===== حفظ المستند وإرجاعه كبايت =====
  final List<int> bytes = document.saveSync();
  document.dispose();
  return Uint8List.fromList(bytes);
}
