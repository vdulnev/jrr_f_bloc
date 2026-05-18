import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrr_f_bloc/core/router/navigation_cubit.dart';

void main() {
  group('NavigationCubit', () {
    test('initial state is nowPlaying', () {
      expect(NavigationCubit().state, AppTab.nowPlaying);
    });

    blocTest<NavigationCubit, AppTab>(
      'select emits the new tab',
      build: NavigationCubit.new,
      act: (c) => c.select(AppTab.library),
      expect: () => [AppTab.library],
    );

    blocTest<NavigationCubit, AppTab>(
      'select with same tab is a no-op',
      build: NavigationCubit.new,
      act: (c) {
        c.select(AppTab.zones);
        c.select(AppTab.zones);
      },
      expect: () => [AppTab.zones],
    );
  });
}
