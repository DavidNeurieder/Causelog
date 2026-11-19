// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProjectStatus _$active = const ProjectStatus._('active');
const ProjectStatus _$paused = const ProjectStatus._('paused');
const ProjectStatus _$archived = const ProjectStatus._('archived');

ProjectStatus _$valueOf(String name) {
  switch (name) {
    case 'active':
      return _$active;
    case 'paused':
      return _$paused;
    case 'archived':
      return _$archived;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProjectStatus> _$values =
    BuiltSet<ProjectStatus>(const <ProjectStatus>[
  _$active,
  _$paused,
  _$archived,
]);

class _$ProjectStatusMeta {
  const _$ProjectStatusMeta();
  ProjectStatus get active => _$active;
  ProjectStatus get paused => _$paused;
  ProjectStatus get archived => _$archived;
  ProjectStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ProjectStatus> get values => _$values;
}

abstract class _$ProjectStatusMixin {
  // ignore: non_constant_identifier_names
  _$ProjectStatusMeta get ProjectStatus => const _$ProjectStatusMeta();
}

Serializer<ProjectStatus> _$projectStatusSerializer =
    _$ProjectStatusSerializer();

class _$ProjectStatusSerializer implements PrimitiveSerializer<ProjectStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'paused': 'paused',
    'archived': 'archived',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'paused': 'paused',
    'archived': 'archived',
  };

  @override
  final Iterable<Type> types = const <Type>[ProjectStatus];
  @override
  final String wireName = 'ProjectStatus';

  @override
  Object serialize(Serializers serializers, ProjectStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProjectStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProjectStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
