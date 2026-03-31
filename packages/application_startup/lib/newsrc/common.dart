// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/startup_task/base_service_item.dart'
    show BaseServiceItem;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBase, BlocProvider;

typedef StartupTaskType = BlocBase<Object?>;
typedef ListOfTaskType = List<BaseServiceItem<StartupTaskType>>;
typedef ListOfBlocProviders = List<BlocProvider<BlocBase<Object?>>>;

/// all, async, root, sync
enum BlocProviderRequest { all, async, root, sync }

/// modes: async, root, sync
enum AsyncTaskRunMode { async, root, sync }

/// alreadyRegistered, ready, registering
enum AsyncTaskRunState {
  alreadyRegisted,
  ready,
  registering,
}

/// states: ready, starting
enum AsyncTakeManagerState {
  ready,
  starting,
}
