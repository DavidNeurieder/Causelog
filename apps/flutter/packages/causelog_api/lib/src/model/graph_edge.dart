//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'graph_edge.g.dart';

/// GraphEdge
///
/// Properties:
/// * [fromId] 
/// * [toId] 
/// * [fromType] 
/// * [toType] 
/// * [kind] 
/// * [source_] 
@BuiltValue()
abstract class GraphEdge implements Built<GraphEdge, GraphEdgeBuilder> {
  @BuiltValueField(wireName: r'from_id')
  String get fromId;

  @BuiltValueField(wireName: r'to_id')
  String get toId;

  @BuiltValueField(wireName: r'from_type')
  GraphEdgeFromTypeEnum get fromType;
  // enum fromTypeEnum {  goal,  decision,  experiment,  note,  };

  @BuiltValueField(wireName: r'to_type')
  GraphEdgeToTypeEnum get toType;
  // enum toTypeEnum {  goal,  decision,  experiment,  note,  };

  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'source')
  GraphEdgeSource_Enum get source_;
  // enum source_Enum {  structural,  explicit,  };

  GraphEdge._();

  factory GraphEdge([void updates(GraphEdgeBuilder b)]) = _$GraphEdge;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GraphEdgeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GraphEdge> get serializer => _$GraphEdgeSerializer();
}

class _$GraphEdgeSerializer implements PrimitiveSerializer<GraphEdge> {
  @override
  final Iterable<Type> types = const [GraphEdge, _$GraphEdge];

  @override
  final String wireName = r'GraphEdge';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GraphEdge object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from_id';
    yield serializers.serialize(
      object.fromId,
      specifiedType: const FullType(String),
    );
    yield r'to_id';
    yield serializers.serialize(
      object.toId,
      specifiedType: const FullType(String),
    );
    yield r'from_type';
    yield serializers.serialize(
      object.fromType,
      specifiedType: const FullType(GraphEdgeFromTypeEnum),
    );
    yield r'to_type';
    yield serializers.serialize(
      object.toType,
      specifiedType: const FullType(GraphEdgeToTypeEnum),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(GraphEdgeSource_Enum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GraphEdge object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GraphEdgeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromId = valueDes;
          break;
        case r'to_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toId = valueDes;
          break;
        case r'from_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GraphEdgeFromTypeEnum),
          ) as GraphEdgeFromTypeEnum;
          result.fromType = valueDes;
          break;
        case r'to_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GraphEdgeToTypeEnum),
          ) as GraphEdgeToTypeEnum;
          result.toType = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GraphEdgeSource_Enum),
          ) as GraphEdgeSource_Enum;
          result.source_ = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GraphEdge deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GraphEdgeBuilder();
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


class GraphEdgeFromTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'goal')
  static const GraphEdgeFromTypeEnum goal = _$graphEdgeFromTypeEnum_goal;
  @BuiltValueEnumConst(wireName: r'decision')
  static const GraphEdgeFromTypeEnum decision = _$graphEdgeFromTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const GraphEdgeFromTypeEnum experiment = _$graphEdgeFromTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'note')
  static const GraphEdgeFromTypeEnum note = _$graphEdgeFromTypeEnum_note;

  static Serializer<GraphEdgeFromTypeEnum> get serializer => _$graphEdgeFromTypeEnumSerializer;

  const GraphEdgeFromTypeEnum._(String name): super(name);

  static BuiltSet<GraphEdgeFromTypeEnum> get values => _$graphEdgeFromTypeEnumValues;
  static GraphEdgeFromTypeEnum valueOf(String name) => _$graphEdgeFromTypeEnumValueOf(name);
}

class GraphEdgeToTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'goal')
  static const GraphEdgeToTypeEnum goal = _$graphEdgeToTypeEnum_goal;
  @BuiltValueEnumConst(wireName: r'decision')
  static const GraphEdgeToTypeEnum decision = _$graphEdgeToTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const GraphEdgeToTypeEnum experiment = _$graphEdgeToTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'note')
  static const GraphEdgeToTypeEnum note = _$graphEdgeToTypeEnum_note;

  static Serializer<GraphEdgeToTypeEnum> get serializer => _$graphEdgeToTypeEnumSerializer;

  const GraphEdgeToTypeEnum._(String name): super(name);

  static BuiltSet<GraphEdgeToTypeEnum> get values => _$graphEdgeToTypeEnumValues;
  static GraphEdgeToTypeEnum valueOf(String name) => _$graphEdgeToTypeEnumValueOf(name);
}

class GraphEdgeSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'structural')
  static const GraphEdgeSource_Enum structural = _$graphEdgeSourceEnum_structural;
  @BuiltValueEnumConst(wireName: r'explicit')
  static const GraphEdgeSource_Enum explicit = _$graphEdgeSourceEnum_explicit;

  static Serializer<GraphEdgeSource_Enum> get serializer => _$graphEdgeSourceEnumSerializer;

  const GraphEdgeSource_Enum._(String name): super(name);

  static BuiltSet<GraphEdgeSource_Enum> get values => _$graphEdgeSourceEnumValues;
  static GraphEdgeSource_Enum valueOf(String name) => _$graphEdgeSourceEnumValueOf(name);
}

