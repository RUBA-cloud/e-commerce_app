import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<int> {
  HomeCubit() : super(0);
  // lib/features/shell/cubit/bottom_nav_cubit.dar

  void setTab(int index) => emit(index);
}
