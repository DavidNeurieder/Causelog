// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GoalStatus _$open = const GoalStatus._('open');
const GoalStatus _$ongoing = const GoalStatus._('ongoing');
const GoalStatus _$done = const GoalStatus._('done');
const GoalStatus _$dropped = const GoalStatus._('dropped');

GoalStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'ongoing':
      return _$ongoing;
    case 'done':
      return _$done;
    case 'dropped':
      return _$dropped;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GoalStatus> _$values = BuiltSet<GoalStatus>(const <GoalStatus>[
  _$open,
  _$ongoing,
  _$done,
  _$dropped,
]);

class _$GoalStatusMeta {
  const _$GoalStatusMeta();
  GoalStatus get open => _$open;
  GoalStatus get ongoing => _$ongoing;
  GoalStatus get done => _$done;
  GoalStatus get dropped => _$dropped;
  GoalStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<GoalStatus> get values => _$values;
}

abstract class _$GoalStatusMixin {
  // ignore: non_constant_identifier_names
  _$GoalStatusMeta get GoalStatus => const _$GoalStatusMeta();
}

Serializer<GoalStatus> _$goalStatusSerializer = _$GoalStatusSerializer();

class _$GoalStatusSerializer implements PrimitiveSerializer<GoalStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'ongoing': 'ongoing',
    'done': 'done',
    'dropped': 'dropped',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'ongoing': 'ongoing',
    'done': 'done',
    'dropped': 'dropped',
  };

  @override
  final Iterable<Type> types = const <Type>[GoalStatus];
  @override
  final String wireName = 'GoalStatus';

  @override
  Object serialize(Serializers serializers, GoalStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GoalStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GoalStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
