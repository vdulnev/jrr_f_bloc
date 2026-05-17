import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/orientation/orientation_lock.dart';
import 'core/router/root_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/connection/bloc/session_cubit.dart';
import 'features/connection/data/repositories/connection_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(
          create: (_) => SessionCubit(
            repository: getIt<ConnectionRepository>(),
            prefs: getIt(),
            talker: getIt(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JRiver Remote',
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(),
        themeMode: ThemeMode.dark,
        home: const RootScreen(),
        builder: (context, child) =>
            OrientationLock(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
