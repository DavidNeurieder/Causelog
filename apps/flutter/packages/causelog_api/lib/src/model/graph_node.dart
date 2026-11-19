//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'graph_node.g.dart';

/// GraphNode
///
/// Properties:
/// * [id] 
/// * [entityType] 
/// * [title] 
@BuiltValue()
abstract class GraphNode implements Built<GraphNode, GraphNodeBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'entity_type')
  GraphNodeEntityTypeEnum get entityType;
  // enum entityTypeEnum {  goal,  decision,  experiment,  note,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  GraphNode._();

  factory GraphNode([void updates(GraphNodeBuilder b)]) = _$GraphNode;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GraphNodeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GraphNode> get serializer => _$GraphNodeSerializer();
}

class _$GraphNodeSerializer implements PrimitiveSerializer<GraphNode> {
  @override
  final Iterable<Type> types = const [GraphNode, _$GraphNode];

  @override
  final String wireName = r'GraphNode';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GraphNode object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(GraphNodeEntityTypeEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GraphNode object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GraphNodeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GraphNodeEntityTypeEnum),
          ) as GraphNodeEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GraphNode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GraphNodeBuilder();
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


class GraphNodeEntityTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'goal')
  static const GraphNodeEntityTypeEnum goal = _$graphNodeEntityTypeEnum_goal;
  @BuiltValueEnumConst(wireName: r'decision')
  static const GraphNodeEntityTypeEnum decision = _$graphNodeEntityTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const GraphNodeEntityTypeEnum experiment = _$graphNodeEntityTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'note')
  static const GraphNodeEntityTypeEnum note = _$graphNodeEntityTypeEnum_note;

  static Serializer<GraphNodeEntityTypeEnum> get serializer => _$graphNodeEntityTypeEnumSerializer;

  const GraphNodeEntityTypeEnum._(String name): super(name);

  static BuiltSet<GraphNodeEntityTypeEnum> get values => _$graphNodeEntityTypeEnumValues;
  static GraphNodeEntityTypeEnum valueOf(String name) => _$graphNodeEntityTypeEnumValueOf(name);
}

