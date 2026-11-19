//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_status.g.dart';

class ProjectStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const ProjectStatus active = _$active;
  @BuiltValueEnumConst(wireName: r'paused')
  static const ProjectStatus paused = _$paused;
  @BuiltValueEnumConst(wireName: r'archived')
  static const ProjectStatus archived = _$archived;

  static Serializer<ProjectStatus> get serializer => _$projectStatusSerializer;

  const ProjectStatus._(String name): super(name);

  static BuiltSet<ProjectStatus> get values => _$values;
  static ProjectStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ProjectStatusMixin = Object with _$ProjectStatusMixin;

