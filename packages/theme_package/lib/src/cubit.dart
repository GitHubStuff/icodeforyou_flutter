// lib/src/cubit.dart
part of '../theme_package.dart';

final class _ThemeCubit extends Cubit<_ThemeState> {
  _ThemeCubit({
    required _ThemeLocalDatasource datasource,
    required ThemeMode initialMode,
  })  : _datasource = datasource,
        super(_ThemeState(themeMode: initialMode));

  final _ThemeLocalDatasource _datasource;

  /// Sets the theme mode and persists it.
  ///
  /// Returns [Either<ThemeError, Unit>] indicating success or failure.
  Future<Either<ThemeError, Unit>> setTheme(ThemeMode mode) async {
    final result = await _datasource.setThemeMode(mode);

    return result.fold(
      (error) => Left(error),
      (_) {
        emit(state.copyWith(themeMode: mode));
        return const Right(unit);
      },
    );
  }
}
