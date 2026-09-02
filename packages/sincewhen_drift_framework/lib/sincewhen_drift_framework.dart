// packages/sincewhen_drift_framework/lib/sincewhen_drift_framework.dart

/// Drift persistence framework for SinceWhen.
library;

export 'src/database/database.dart' show SinceWhenDatabase;
export 'src/database/database_opening.dart' show SinceWhenDatabaseOpening;
export 'src/glossary_items/color_collector.dart' show ColorCollector;
export 'src/repositories/drift_glossary_repository.dart'
    show DriftGlossaryRepository;
export 'src/repositories/drift_since_when_repository.dart'
    show DriftSinceWhenRepository;
export 'src/repositories/drift_tag_repository.dart' show DriftTagRepository;
export 'src/sincewhen_startup.dart'
    show
        SinceWhenAppFolderConfiguration,
        SinceWhenConfiguration,
        SinceWhenDocumentsConfiguration,
        SinceWhenInMemoryConfiguration,
        SinceWhenStartup;
export 'src/tables/glossary_items/glossary_items.dart' show GlossaryItems;
export 'src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;
export 'src/tables/glossary_items/glossary_items_dao_abstract.dart'
    show GlossaryItemsDaoAbstract;
