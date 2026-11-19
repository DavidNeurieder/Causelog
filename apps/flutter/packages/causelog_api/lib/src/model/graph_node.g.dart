// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_node.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GraphNodeEntityTypeEnum _$graphNodeEntityTypeEnum_goal =
    const GraphNodeEntityTypeEnum._('goal');
const GraphNodeEntityTypeEnum _$graphNodeEntityTypeEnum_decision =
    const GraphNodeEntityTypeEnum._('decision');
const GraphNodeEntityTypeEnum _$graphNodeEntityTypeEnum_experiment =
    const GraphNodeEntityTypeEnum._('experiment');
const GraphNodeEntityTypeEnum _$graphNodeEntityTypeEnum_note =
    const GraphNodeEntityTypeEnum._('note');

GraphNodeEntityTypeEnum _$graphNodeEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'goal':
      return _$graphNodeEntityTypeEnum_goal;
    case 'decision':
      return _$graphNodeEntityTypeEnum_decision;
    case 'experiment':
      return _$graphNodeEntityTypeEnum_experiment;
    case 'note':
      return _$graphNodeEntityTypeEnum_note;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GraphNodeEntityTypeEnum> _$graphNodeEntityTypeEnumValues =
    BuiltSet<GraphNodeEntityTypeEnum>(const <GraphNodeEntityTypeEnum>[
  _$graphNodeEntityTypeEnum_goal,
  _$graphNodeEntityTypeEnum_decision,
  _$graphNodeEntityTypeEnum_experiment,
  _$graphNodeEntityTypeEnum_note,
]);

Serializer<GraphNodeEntityTypeEnum> _$graphNodeEntityTypeEnumSerializer =
    _$GraphNodeEntityTypeEnumSerializer();

class _$GraphNodeEntityTypeEnumSerializer
    implements PrimitiveSerializer<GraphNodeEntityTypeEnum> {
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
  final Iterable<Type> types = const <Type>[GraphNodeEntityTypeEnum];
  @override
  final String wireName = 'GraphNodeEntityTypeEnum';

  @override
  Object serialize(Serializers serializers, GraphNodeEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GraphNodeEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GraphNodeEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GraphNode extends GraphNode {
  @override
  final String id;
  @override
  final GraphNodeEntityTypeEnum entityType;
  @override
  final String title;

  factory _$GraphNode([void Function(GraphNodeBuilder)? updates]) =>
      (GraphNodeBuilder()..update(updates))._build();

  _$GraphNode._(
      {required this.id, required this.entityType, required this.title})
      : super._();
  @override
  GraphNode rebuild(void Function(GraphNodeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GraphNodeBuilder toBuilder() => GraphNodeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GraphNode &&
        id == other.id &&
        entityType == other.entityType &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GraphNode')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('title', title))
        .toString();
  }
}

class GraphNodeBuilder implements Builder<GraphNode, GraphNodeBuilder> {
  _$GraphNode? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GraphNodeEntityTypeEnum? _entityType;
  GraphNodeEntityTypeEnum? get entityType => _$this._entityType;
  set entityType(GraphNodeEntityTypeEnum? entityType) =>
      _$this._entityType = entityType;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GraphNodeBuilder() {
    GraphNode._defaults(this);
  }

  GraphNodeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _entityType = $v.entityType;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GraphNode other) {
    _$v = other as _$GraphNode;
  }

  @override
  void update(void Function(GraphNodeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GraphNode build() => _build();

  _$GraphNode _build() {
    final _$result = _$v ??
        _$GraphNode._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'GraphNode', 'id'),
          entityType: BuiltValueNullFieldError.checkNotNull(
              entityType, r'GraphNode', 'entityType'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GraphNode', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
