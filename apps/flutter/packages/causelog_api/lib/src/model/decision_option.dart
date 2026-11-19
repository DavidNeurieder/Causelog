//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision_option.g.dart';

/// DecisionOption
///
/// Properties:
/// * [id] 
/// * [label] 
/// * [pros] 
/// * [cons] 
@BuiltValue()
abstract class DecisionOption implements Built<DecisionOption, DecisionOptionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'pros')
  String get pros;

  @BuiltValueField(wireName: r'cons')
  String get cons;

  DecisionOption._();

  factory DecisionOption([void updates(DecisionOptionBuilder b)]) = _$DecisionOption;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DecisionOptionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DecisionOption> get serializer => _$DecisionOptionSerializer();
}

class _$DecisionOptionSerializer implements PrimitiveSerializer<DecisionOption> {
  @override
  final Iterable<Type> types = const [DecisionOption, _$DecisionOption];

  @override
  final String wireName = r'DecisionOption';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DecisionOption object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'pros';
    yield serializers.serialize(
      object.pros,
      specifiedType: const FullType(String),
    );
    yield r'cons';
    yield serializers.serialize(
      object.cons,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DecisionOption object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DecisionOptionBuilder result,
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
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'pros':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pros = valueDes;
          break;
        case r'cons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cons = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DecisionOption deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DecisionOptionBuilder();
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


