// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExperimentStatus _$planned = const ExperimentStatus._('planned');
const ExperimentStatus _$ongoing = const ExperimentStatus._('ongoing');
const ExperimentStatus _$done = const ExperimentStatus._('done');
const ExperimentStatus _$abandoned = const ExperimentStatus._('abandoned');

ExperimentStatus _$valueOf(String name) {
  switch (name) {
    case 'planned':
      return _$planned;
    case 'ongoing':
      return _$ongoing;
    case 'done':
      return _$done;
    case 'abandoned':
      return _$abandoned;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExperimentStatus> _$values =
    BuiltSet<ExperimentStatus>(const <ExperimentStatus>[
  _$planned,
  _$ongoing,
  _$done,
  _$abandoned,
]);

class _$ExperimentStatusMeta {
  const _$ExperimentStatusMeta();
  ExperimentStatus get planned => _$planned;
  ExperimentStatus get ongoing => _$ongoing;
  ExperimentStatus get done => _$done;
  ExperimentStatus get abandoned => _$abandoned;
  ExperimentStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ExperimentStatus> get values => _$values;
}

abstract class _$ExperimentStatusMixin {
  // ignore: non_constant_identifier_names
  _$ExperimentStatusMeta get ExperimentStatus => const _$ExperimentStatusMeta();
}

Serializer<ExperimentStatus> _$experimentStatusSerializer =
    _$ExperimentStatusSerializer();

class _$ExperimentStatusSerializer
    implements PrimitiveSerializer<ExperimentStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'planned': 'planned',
    'ongoing': 'ongoing',
    'done': 'done',
    'abandoned': 'abandoned',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'planned': 'planned',
    'ongoing': 'ongoing',
    'done': 'done',
    'abandoned': 'abandoned',
  };

  @override
  final Iterable<Type> types = const <Type>[ExperimentStatus];
  @override
  final String wireName = 'ExperimentStatus';

  @override
  Object serialize(Serializers serializers, ExperimentStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExperimentStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExperimentStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
