// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_edge.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GraphEdgeFromTypeEnum _$graphEdgeFromTypeEnum_goal =
    const GraphEdgeFromTypeEnum._('goal');
const GraphEdgeFromTypeEnum _$graphEdgeFromTypeEnum_decision =
    const GraphEdgeFromTypeEnum._('decision');
const GraphEdgeFromTypeEnum _$graphEdgeFromTypeEnum_experiment =
    const GraphEdgeFromTypeEnum._('experiment');
const GraphEdgeFromTypeEnum _$graphEdgeFromTypeEnum_note =
    const GraphEdgeFromTypeEnum._('note');

GraphEdgeFromTypeEnum _$graphEdgeFromTypeEnumValueOf(String name) {
  switch (name) {
    case 'goal':
      return _$graphEdgeFromTypeEnum_goal;
    case 'decision':
      return _$graphEdgeFromTypeEnum_decision;
    case 'experiment':
      return _$graphEdgeFromTypeEnum_experiment;
    case 'note':
      return _$graphEdgeFromTypeEnum_note;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GraphEdgeFromTypeEnum> _$graphEdgeFromTypeEnumValues =
    BuiltSet<GraphEdgeFromTypeEnum>(const <GraphEdgeFromTypeEnum>[
  _$graphEdgeFromTypeEnum_goal,
  _$graphEdgeFromTypeEnum_decision,
  _$graphEdgeFromTypeEnum_experiment,
  _$graphEdgeFromTypeEnum_note,
]);

const GraphEdgeToTypeEnum _$graphEdgeToTypeEnum_goal =
    const GraphEdgeToTypeEnum._('goal');
const GraphEdgeToTypeEnum _$graphEdgeToTypeEnum_decision =
    const GraphEdgeToTypeEnum._('decision');
const GraphEdgeToTypeEnum _$graphEdgeToTypeEnum_experiment =
    const GraphEdgeToTypeEnum._('experiment');
const GraphEdgeToTypeEnum _$graphEdgeToTypeEnum_note =
    const GraphEdgeToTypeEnum._('note');

GraphEdgeToTypeEnum _$graphEdgeToTypeEnumValueOf(String name) {
  switch (name) {
    case 'goal':
      return _$graphEdgeToTypeEnum_goal;
    case 'decision':
      return _$graphEdgeToTypeEnum_decision;
    case 'experiment':
      return _$graphEdgeToTypeEnum_experiment;
    case 'note':
      return _$graphEdgeToTypeEnum_note;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GraphEdgeToTypeEnum> _$graphEdgeToTypeEnumValues =
    BuiltSet<GraphEdgeToTypeEnum>(const <GraphEdgeToTypeEnum>[
  _$graphEdgeToTypeEnum_goal,
  _$graphEdgeToTypeEnum_decision,
  _$graphEdgeToTypeEnum_experiment,
  _$graphEdgeToTypeEnum_note,
]);

const GraphEdgeSource_Enum _$graphEdgeSourceEnum_structural =
    const GraphEdgeSource_Enum._('structural');
const GraphEdgeSource_Enum _$graphEdgeSourceEnum_explicit =
    const GraphEdgeSource_Enum._('explicit');

GraphEdgeSource_Enum _$graphEdgeSourceEnumValueOf(String name) {
  switch (name) {
    case 'structural':
      return _$graphEdgeSourceEnum_structural;
    case 'explicit':
      return _$graphEdgeSourceEnum_explicit;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GraphEdgeSource_Enum> _$graphEdgeSourceEnumValues =
    BuiltSet<GraphEdgeSource_Enum>(const <GraphEdgeSource_Enum>[
  _$graphEdgeSourceEnum_structural,
  _$graphEdgeSourceEnum_explicit,
]);

Serializer<GraphEdgeFromTypeEnum> _$graphEdgeFromTypeEnumSerializer =
    _$GraphEdgeFromTypeEnumSerializer();
Serializer<GraphEdgeToTypeEnum> _$graphEdgeToTypeEnumSerializer =
    _$GraphEdgeToTypeEnumSerializer();
Serializer<GraphEdgeSource_Enum> _$graphEdgeSourceEnumSerializer =
    _$GraphEdgeSource_EnumSerializer();

class _$GraphEdgeFromTypeEnumSerializer
    implements PrimitiveSerializer<GraphEdgeFromTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };

  @override
  final Iterable<Type> types = const <Type>[GraphEdgeFromTypeEnum];
  @override
  final String wireName = 'GraphEdgeFromTypeEnum';

  @override
  Object serialize(Serializers serializers, GraphEdgeFromTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GraphEdgeFromTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GraphEdgeFromTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GraphEdgeToTypeEnumSerializer
    implements PrimitiveSerializer<GraphEdgeToTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'goal': 'goal',
    'decision': 'decision',
    'experiment': 'experiment',
    'note': 'note',
  };

  @override
  final Iterable<Type> types = const <Type>[GraphEdgeToTypeEnum];
  @override
  final String wireName = 'GraphEdgeToTypeEnum';

  @override
  Object serialize(Serializers serializers, GraphEdgeToTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GraphEdgeToTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GraphEdgeToTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GraphEdgeSource_EnumSerializer
    implements PrimitiveSerializer<GraphEdgeSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'structural': 'structural',
    'explicit': 'explicit',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'structural': 'structural',
    'explicit': 'explicit',
  };

  @override
  final Iterable<Type> types = const <Type>[GraphEdgeSource_Enum];
  @override
  final String wireName = 'GraphEdgeSource_Enum';

  @override
  Object serialize(Serializers serializers, GraphEdgeSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GraphEdgeSource_Enum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GraphEdgeSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GraphEdge extends GraphEdge {
  @override
  final String fromId;
  @override
  final String toId;
  @override
  final GraphEdgeFromTypeEnum fromType;
  @override
  final GraphEdgeToTypeEnum toType;
  @override
  final String kind;
  @override
  final GraphEdgeSource_Enum source_;

  factory _$GraphEdge([void Function(GraphEdgeBuilder)? updates]) =>
      (GraphEdgeBuilder()..update(updates))._build();

  _$GraphEdge._(
      {required this.fromId,
      required this.toId,
      required this.fromType,
      required this.toType,
      required this.kind,
      required this.source_})
      : super._();
  @override
  GraphEdge rebuild(void Function(GraphEdgeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GraphEdgeBuilder toBuilder() => GraphEdgeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GraphEdge &&
        fromId == other.fromId &&
        toId == other.toId &&
        fromType == other.fromType &&
        toType == other.toType &&
        kind == other.kind &&
        source_ == other.source_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fromId.hashCode);
    _$hash = $jc(_$hash, toId.hashCode);
    _$hash = $jc(_$hash, fromType.hashCode);
    _$hash = $jc(_$hash, toType.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GraphEdge')
          ..add('fromId', fromId)
          ..add('toId', toId)
          ..add('fromType', fromType)
          ..add('toType', toType)
          ..add('kind', kind)
          ..add('source_', source_))
        .toString();
  }
}

class GraphEdgeBuilder implements Builder<GraphEdge, GraphEdgeBuilder> {
  _$GraphEdge? _$v;

  String? _fromId;
  String? get fromId => _$this._fromId;
  set fromId(String? fromId) => _$this._fromId = fromId;

  String? _toId;
  String? get toId => _$this._toId;
  set toId(String? toId) => _$this._toId = toId;

  GraphEdgeFromTypeEnum? _fromType;
  GraphEdgeFromTypeEnum? get fromType => _$this._fromType;
  set fromType(GraphEdgeFromTypeEnum? fromType) => _$this._fromType = fromType;

  GraphEdgeToTypeEnum? _toType;
  GraphEdgeToTypeEnum? get toType => _$this._toType;
  set toType(GraphEdgeToTypeEnum? toType) => _$this._toType = toType;

  String? _kind;
  String? get kind => _$this._kind;
  set kind(String? kind) => _$this._kind = kind;

  GraphEdgeSource_Enum? _source_;
  GraphEdgeSource_Enum? get source_ => _$this._source_;
  set source_(GraphEdgeSource_Enum? source_) => _$this._source_ = source_;

  GraphEdgeBuilder() {
    GraphEdge._defaults(this);
  }

  GraphEdgeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fromId = $v.fromId;
      _toId = $v.toId;
      _fromType = $v.fromType;
      _toType = $v.toType;
      _kind = $v.kind;
      _source_ = $v.source_;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GraphEdge other) {
    _$v = other as _$GraphEdge;
  }

  @override
  void update(void Function(GraphEdgeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GraphEdge build() => _build();

  _$GraphEdge _build() {
    final _$result = _$v ??
        _$GraphEdge._(
          fromId: BuiltValueNullFieldError.checkNotNull(
              fromId, r'GraphEdge', 'fromId'),
          toId:
              BuiltValueNullFieldError.checkNotNull(toId, r'GraphEdge', 'toId'),
          fromType: BuiltValueNullFieldError.checkNotNull(
              fromType, r'GraphEdge', 'fromType'),
          toType: BuiltValueNullFieldError.checkNotNull(
              toType, r'GraphEdge', 'toType'),
          kind:
              BuiltValueNullFieldError.checkNotNull(kind, r'GraphEdge', 'kind'),
          source_: BuiltValueNullFieldError.checkNotNull(
              source_, r'GraphEdge', 'source_'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
