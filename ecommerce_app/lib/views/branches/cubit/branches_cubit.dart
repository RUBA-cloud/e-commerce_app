import 'package:ecommerce_app/models/branches.dart';
import 'package:ecommerce_app/views/branches/cubit/branches_state.dart';
import 'package:ecommerce_app/repostery%20/branches_repostery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BranchesCubit extends Cubit<BranchesState> {
  BranchesCubit() : super(const BranchesState.loading());

  Future<void> load() async {
    emit(const BranchesState.loading());
    try {
    
      final data = await ApiBranchesRepository().fetchAll();
      emit(BranchesState.loaded(data));
    } catch (e) {
      emit(BranchesState.error(e.toString()));
    }
  }

  Future<void> openMaps(BranchModel b) async {
    String url;
    if (b.lat != null && b.lng != null) {
      url = 'https://www.google.com/maps/search/?api=1&query=${b.lat},${b.lng}';
    } else {
      final q = Uri.encodeComponent(b.address);
      url = 'https://www.google.com/maps/search/?api=1&query=$q';
    }
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }
}
