//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/graph_node.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/graph_edge.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'graph_response.g.dart';

/// GraphResponse
///
/// Properties:
/// * [nodes] 
/// * [edges] 
@BuiltValue()
abstract class GraphResponse implements Built<GraphResponse, GraphResponseBuilder> {
  @BuiltValueField(wireName: r'nodes')
  BuiltList<GraphNode> get nodes;

  @BuiltValueField(wireName: r'edges')
  BuiltList<GraphEdge> get edges;

  GraphResponse._();

  factory GraphResponse([void updates(GraphResponseBuilder b)]) = _$GraphResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GraphResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GraphResponse> get serializer => _$GraphResponseSerializer();
}

class _$GraphResponseSerializer implements PrimitiveSerializer<GraphResponse> {
  @override
  final Iterable<Type> types = const [GraphResponse, _$GraphResponse];

  @override
  final String wireName = r'GraphResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GraphResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'nodes';
    yield serializers.serialize(
      object.nodes,
      specifiedType: const FullType(BuiltList, [FullType(GraphNode)]),
    );
    yield r'edges';
    yield serializers.serialize(
      object.edges,
      specifiedType: const FullType(BuiltList, [FullType(GraphEdge)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GraphResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GraphResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nodes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GraphNode)]),
          ) as BuiltList<GraphNode>;
          result.nodes.replace(valueDes);
          break;
        case r'edges':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GraphEdge)]),
          ) as BuiltList<GraphEdge>;
          result.edges.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GraphResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GraphResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}


