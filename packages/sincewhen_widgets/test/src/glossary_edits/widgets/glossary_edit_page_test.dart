// packages/sincewhen_widgets/test/src/glossary_edits/widgets/glossary_edit_page_test.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyResolver;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryRepository;
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show GlossaryEditPage, GlossaryEditView;

class _MockDependencyResolver extends Mock implements DependencyResolver {}

class _MockGlossaryRepository extends Mock implements GlossaryRepository {}

void main() {
  late DependencyResolver mockResolver;
  late GlossaryRepository mockGlossaryRepo;

  setUp(() {
    mockResolver = _MockDependencyResolver();
    mockGlossaryRepo = _MockGlossaryRepository();

    when(
      () => mockResolver.get<GlossaryRepository>(),
    ).thenReturn(mockGlossaryRepo);
    when(
      () => mockGlossaryRepo.allColorArgbValues(),
    ).thenAnswer((_) async => <int>{});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: RepositoryProvider<DependencyResolver>.value(
        value: mockResolver,
        child: const GlossaryEditPage(),
      ),
    );
  }

  group('GlossaryEditPage', () {
    testWidgets(
      'resolves GlossaryRepository and renders GlossaryEditView',
      (tester) async {
        await tester.pumpWidget(buildSubject());

        verify(() => mockResolver.get<GlossaryRepository>()).called(1);
        expect(find.byType(GlossaryEditView), findsOneWidget);
      },
    );
  });
}
