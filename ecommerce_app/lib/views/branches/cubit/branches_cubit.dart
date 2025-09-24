import 'package:ecommerce_app/views/branches/cubit/branches_state.dart';
import 'package:ecommerce_app/repostery%20/branches_repostery.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BranchesCubit extends Cubit<BranchesState> {
  BranchesCubit() : super(const BranchesState.loading());

  Future<void> load() async {
    emit(const BranchesState.loading());
    try {
      var repo = MockBranchesRepository();
      final data = await repo.fetchAll();
      emit(BranchesState.loaded(data));
    } catch (e) {
      emit(BranchesState.error(e.toString()));
    }
  }
}
