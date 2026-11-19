// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GraphResponse extends GraphResponse {
  @override
  final BuiltList<GraphNode> nodes;
  @override
  final BuiltList<GraphEdge> edges;

  factory _$GraphResponse([void Function(GraphResponseBuilder)? updates]) =>
      (GraphResponseBuilder()..update(updates))._build();

  _$GraphResponse._({required this.nodes, required this.edges}) : super._();
  @override
  GraphResponse rebuild(void Function(GraphResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GraphResponseBuilder toBuilder() => GraphResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GraphResponse &&
        nodes == other.nodes &&
        edges == other.edges;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nodes.hashCode);
    _$hash = $jc(_$hash, edges.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GraphResponse')
          ..add('nodes', nodes)
          ..add('edges', edges))
        .toString();
  }
}

class GraphResponseBuilder
    implements Builder<GraphResponse, GraphResponseBuilder> {
  _$GraphResponse? _$v;

  ListBuilder<GraphNode>? _nodes;
  ListBuilder<GraphNode> get nodes =>
      _$this._nodes ??= ListBuilder<GraphNode>();
  set nodes(ListBuilder<GraphNode>? nodes) => _$this._nodes = nodes;

  ListBuilder<GraphEdge>? _edges;
  ListBuilder<GraphEdge> get edges =>
      _$this._edges ??= ListBuilder<GraphEdge>();
  set edges(ListBuilder<GraphEdge>? edges) => _$this._edges = edges;

  GraphResponseBuilder() {
    GraphResponse._defaults(this);
  }

  GraphResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nodes = $v.nodes.toBuilder();
      _edges = $v.edges.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GraphResponse other) {
    _$v = other as _$GraphResponse;
  }

  @override
  void update(void Function(GraphResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GraphResponse build() => _build();

  _$GraphResponse _build() {
    _$GraphResponse _$result;
    try {
      _$result = _$v ??
          _$GraphResponse._(
            nodes: nodes.build(),
            edges: edges.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'nodes';
        nodes.build();
        _$failedField = 'edges';
        edges.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GraphResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
