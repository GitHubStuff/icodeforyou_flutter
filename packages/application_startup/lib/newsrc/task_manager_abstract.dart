import 'package:application_startup/newsrc/common.dart';
import 'package:application_startup/newsrc/startup_task_abstract.dart'
    show BlocProviderRequest;

abstract class RegisterServicesManagerAbstract {
  ListOfTaskType get currentTaskList;

  Future<void> runRootTasks();

  void validateTasks(ListOfTaskType tasks);

  ListOfBlocProviders blocProviders({required BlocProviderRequest forType});
}
