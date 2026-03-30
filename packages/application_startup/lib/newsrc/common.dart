import 'package:application_startup/newsrc/startup_task_abstract.dart'
    show StartupTask;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;

typedef StartupTaskType = BlocBase<Object?>;
typedef ListOfTaskType = List<StartupTask<StartupTaskType>>;
typedef ListOfBlocProviders = List<BlocProvider<BlocBase<Object?>>>;

/// all, async, root, sync
enum BlocProviderRequest { all, async, root, sync }

enum AsyncTaskRunMode { async, root, sync }
