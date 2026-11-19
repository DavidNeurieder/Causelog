// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DecisionStatus _$open = const DecisionStatus._('open');
const DecisionStatus _$decided = const DecisionStatus._('decided');
const DecisionStatus _$rejected = const DecisionStatus._('rejected');

DecisionStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'decided':
      return _$decided;
    case 'rejected':
      return _$rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DecisionStatus> _$values =
    BuiltSet<DecisionStatus>(const <DecisionStatus>[
  _$open,
  _$decided,
  _$rejected,
]);

class _$DecisionStatusMeta {
  const _$DecisionStatusMeta();
  DecisionStatus get open => _$open;
  DecisionStatus get decided => _$decided;
  DecisionStatus get rejected => _$rejected;
  DecisionStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<DecisionStatus> get values => _$values;
}

abstract class _$DecisionStatusMixin {
  // ignore: non_constant_identifier_names
  _$DecisionStatusMeta get DecisionStatus => const _$DecisionStatusMeta();
}

Serializer<DecisionStatus> _$decisionStatusSerializer =
    _$DecisionStatusSerializer();

class _$DecisionStatusSerializer
    implements PrimitiveSerializer<DecisionStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'decided': 'decided',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'decided': 'decided',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[DecisionStatus];
  @override
  final String wireName = 'DecisionStatus';

  @override
  Object serialize(Serializers serializers, DecisionStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DecisionStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DecisionStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
