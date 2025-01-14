import 'package:coozy_cafe/bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider> blocProviders = [
  BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()..loadTheme()),
  BlocProvider<HomePageBottomNavCubit>(
      create: (context) => HomePageBottomNavCubit()),
  BlocProvider<AddMenuCategoryCubit>(
      create: (context) => AddMenuCategoryCubit()),
  BlocProvider<MenuCategoryFullListCubit>(
      create: (context) => MenuCategoryFullListCubit()),
];
