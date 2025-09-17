import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'app_title': 'Rent Home',
      'home_title': 'Home',
      'details_title': 'Details',
      'hello_user': 'Hello, @name! 👋',
      'open_details': 'Open Details',
      'change_lang': 'Language',
      'change_theme': 'Theme',
      'counter': 'Counter',
      'increment': 'Increment',
      'decrement': 'Decrement',
      'size_demo': 'Responsive Box',
      'lorem': 'This text scales with screen size.',
    },
    'ar_JO': {
      'app_title': 'تأجير المنازل',
      'home_title': 'الصفحة الرئيسية',
      'details_title': 'التفاصيل',
      'hello_user': 'مرحبا، @name! 👋',
      'open_details': 'فتح التفاصيل',
      'change_lang': 'اللغة',
      'change_theme': 'السمة',
      'counter': 'العداد',
      'increment': 'زيادة',
      'decrement': 'نقصان',
      'size_demo': 'صندوق متجاوب',
      'lorem': 'هذا النص يتكيف مع حجم الشاشة.',
    },
  };
}
