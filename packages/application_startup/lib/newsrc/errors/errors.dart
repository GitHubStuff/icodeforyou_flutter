// ignore_for_file: public_member_api_docs

class DuplicateServiceItem extends StateError {
  DuplicateServiceItem(String name) : super('"$name" is already registered ');
}

class InvalidCreate extends StateError {
  InvalidCreate(String name) : super('Can only create from "$name"');
}

class ServiceItemTimeout extends StateError {
  ServiceItemTimeout(String name, Duration timeout)
    : super('Time out on Service "$name" after ${timeout.inMilliseconds}ms');
}

class UnknownServiceItem extends StateError {
  UnknownServiceItem(String message) : super('Unknown Service Item "$message"');
}
