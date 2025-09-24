// lib/features/branches/cubit/branches_cubit.dart
import 'package:ecommerce_app/models/branches.dart';

enum BranchesStatus { loading, loaded, error }

class BranchesState {
  final BranchesStatus status;
  final List<BranchModel> branches;
  final String? error;

  const BranchesState._(this.status, this.branches, this.error);
  const BranchesState.loading()
    : this._(BranchesStatus.loading, const [], null);
  const BranchesState.loaded(List<BranchModel> data)
    : this._(BranchesStatus.loaded, data, null);
  const BranchesState.error(String e)
    : this._(BranchesStatus.error, const [], e);
}
