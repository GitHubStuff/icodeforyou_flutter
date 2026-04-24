// // ignore_for_file: public_member_api_docs


// abstract class ServicesManagerStatus {
//   const ServicesManagerStatus(this.name, this.status);
//   final String name;
//   final ServiceDescriptorStatus status;
//   @override
//   String toString() => 'Name: "$name" Status: ${status.name}';
//   void debugLog() {
//     // ignore: prefer_asserts_with_message
//     assert(() {
//       MyLogger.d(toString());
//       return true;
//     }());
//   }
// }

// //-
// sealed class ServicesManagerState extends ServicesManagerStatus {
//   const ServicesManagerState(super.name, super.status);
// }

// //-
// class ServicesManagerCataloged extends ServicesManagerState {
//   ServicesManagerCataloged(String name) : super(name, .cataloged);
// }

// //-
// class ServicesManagerReady extends ServicesManagerState {
//   const ServicesManagerReady(String name) : super(name, .ready);
// }

// class ServicesManagerRegistered extends ServicesManagerState {
//   const ServicesManagerRegistered(String name) : super(name, .registered);
// }

// class ServicesManagerRegistering extends ServicesManagerState {
//   const ServicesManagerRegistering(String name) : super(name, .registering);
// }

// class ServicesManagerStarting extends ServicesManagerState {
//   const ServicesManagerStarting(String name) : super(name, .starting);
// }

// class ServicesManagerWaiting extends ServicesManagerState {
//   const ServicesManagerWaiting(String name) : super(name, .waiting);
// }



// //-
