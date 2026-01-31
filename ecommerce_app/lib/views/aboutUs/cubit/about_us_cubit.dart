import 'package:ecommerce_app/views/aboutUs/cubit/about_us_state.dart';
import 'package:ecommerce_app/repostery%20/about_us_repostery.dart'
    show MockAboutRepository;
import 'package:flutter_bloc/flutter_bloc.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(const AboutState.loading());

  Future<void> load() async {
    emit(const AboutState.loading());
    try {
      var repo = MockAboutRepository();
      final info = await repo.fetch();
      emit(AboutState.loaded(info));
    } catch (e) {
      emit(AboutState.error(e.toString()));
    }
  }
}
