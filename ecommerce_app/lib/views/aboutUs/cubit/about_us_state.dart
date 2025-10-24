import 'package:ecommerce_app/models/about_us.dart';

enum AboutStatus { loading, loaded, error }

class AboutState {
  final AboutStatus status;
  final AboutUsInfoModel? info;
  final String? error;

  const AboutState._(this.status, {this.info, this.error});

  const AboutState.loading() : this._(AboutStatus.loading);
  const AboutState.loaded(AboutUsInfoModel? info)
      : this._(AboutStatus.loaded, info: info);
  const AboutState.error(String e) : this._(AboutStatus.error, error: e);
}
