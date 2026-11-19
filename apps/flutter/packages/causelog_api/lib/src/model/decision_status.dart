//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision_status.g.dart';

class DecisionStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const DecisionStatus open = _$open;
  @BuiltValueEnumConst(wireName: r'decided')
  static const DecisionStatus decided = _$decided;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const DecisionStatus rejected = _$rejected;

  static Serializer<DecisionStatus> get serializer => _$decisionStatusSerializer;

  const DecisionStatus._(String name): super(name);

  static BuiltSet<DecisionStatus> get values => _$values;
  static DecisionStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DecisionStatusMixin = Object with _$DecisionStatusMixin;

