
import 'package:application_startup/newsrc/startup_task_abstract.dart'
    show BlocProviderRequest, StartupTask;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;

typedef StartupTaskType = BlocBase<Object?>;
typedef ListOfTaskType = List<StartupTask<StartupTaskType>>;
typedef ListOfBlocProviders = List<BlocProvider<BlocBase<Object?>>>;

abstract class StartTaskManagerAbstract {
  ListOfTaskType get currentTaskList;

  Future<void> runRootTasks();

  void validateTasks(ListOfTaskType tasks);

  ListOfBlocProviders blocProviders({required BlocProviderRequest forType});
}
