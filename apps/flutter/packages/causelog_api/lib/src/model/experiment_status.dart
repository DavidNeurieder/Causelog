//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_status.g.dart';

class ExperimentStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'planned')
  static const ExperimentStatus planned = _$planned;
  @BuiltValueEnumConst(wireName: r'ongoing')
  static const ExperimentStatus ongoing = _$ongoing;
  @BuiltValueEnumConst(wireName: r'done')
  static const ExperimentStatus done = _$done;
  @BuiltValueEnumConst(wireName: r'abandoned')
  static const ExperimentStatus abandoned = _$abandoned;

  static Serializer<ExperimentStatus> get serializer => _$experimentStatusSerializer;

  const ExperimentStatus._(String name): super(name);

  static BuiltSet<ExperimentStatus> get values => _$values;
  static ExperimentStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExperimentStatusMixin = Object with _$ExperimentStatusMixin;

