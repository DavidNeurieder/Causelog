//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'goal_status.g.dart';

class GoalStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const GoalStatus open = _$open;
  @BuiltValueEnumConst(wireName: r'ongoing')
  static const GoalStatus ongoing = _$ongoing;
  @BuiltValueEnumConst(wireName: r'done')
  static const GoalStatus done = _$done;
  @BuiltValueEnumConst(wireName: r'dropped')
  static const GoalStatus dropped = _$dropped;

  static Serializer<GoalStatus> get serializer => _$goalStatusSerializer;

  const GoalStatus._(String name): super(name);

  static BuiltSet<GoalStatus> get values => _$values;
  static GoalStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class GoalStatusMixin = Object with _$GoalStatusMixin;

