# QUERY CHANGES

The sincewhen_models hold the pure dart version of the sincewhen_drift_framwork package for the tables of the framework.

Any new query in the framework requires three(3) updates:

- sincewhen_models/repositories/*_repository.dart
- sincewhen_drift_framework/lib/src/repositories/DriftSinceWhenRepository -- the delegation
- <app>/.../*ItemsDao     -- the actual query
