// packages/sincewhen_drift_framework/lib/sincewhen_drift_framework.dart

/// Drift persistence framework for SinceWhen.
library;

export 'src/database/database.dart' show SinceWhenDatabase;
export 'src/database/database_opening.dart' show SinceWhenDatabaseOpening;
export 'src/glossary_items/color_collector.dart' show ColorCollector;
export 'src/startup_methods.dart'
    show
        registerAppDatabaseLazy,
        registerDocumentDatabaseLazy,
        registerGlossaryItemsDao,
        registerInMemoryDatabaseLazy,
        registerSinceWhenItemsDao,
        registerTagItemsDao,
        warmStartDatabase;
export 'src/tables/glossary_items/glossary_items.dart' show GlossaryItems;
export 'src/tables/glossary_items/glossary_items_dao.dart'
    show GlossaryItemsDao;
