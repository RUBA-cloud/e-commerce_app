// lib/features/about/data/about_repository.dart
import 'dart:async';
import 'package:ecommerce_app/models/about_us.dart';

abstract class AboutRepository {
  Future<AboutUsInfoModel> fetch();
}

class MockAboutRepository implements AboutRepository {
  @override
  Future<AboutUsInfoModel> fetch() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AboutUsInfoModel(
      companyName: 'Rent Home',
      tagline: 'Find your place, faster.',
      missionEn: 'Make renting simple, transparent, and joyful.',
      missionAr: 'نجعل استئجار المنازل بسيطًا وشفافًا ومبهجًا.',
      visionEn: 'A world where moving home is one tap away.',
      visionAr: 'عالم تصبح فيه عملية الانتقال لمنزل جديد نقرة واحدة فقط.',
      descriptionEn:
          'We connect renters with great homes using modern tech and a caring team. '
          'From smart filters to real-time notifications, our platform removes friction at every step.',
      descriptionAr:
          'نربط المستأجرين بالمنازل المناسبة باستخدام تقنيات حديثة وفريق يهتم بالتفاصيل. '
          'من المرشّحات الذكية إلى الإشعارات الفورية، منصتنا تقلّل التعقيدات في كل خطوة.',
      values: ['Trust', 'Speed', 'Quality', 'Support'],
      email: 'hello@renthome.app',
      phone: '+962-7-0000-0000',
      address: 'Amman, Jordan',
      website: 'https://renthome.app',
      social: {
        'instagram': 'https://instagram.com/renthome',
        'twitter': 'https://x.com/renthome',
      },
    );
  }
}
