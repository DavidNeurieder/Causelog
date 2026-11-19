//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'health200_response.g.dart';

/// Health200Response
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class Health200Response implements Built<Health200Response, Health200ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  Health200ResponseStatusEnum get status;
  // enum statusEnum {  ok,  };

  Health200Response._();

  factory Health200Response([void updates(Health200ResponseBuilder b)]) = _$Health200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(Health200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Health200Response> get serializer => _$Health200ResponseSerializer();
}

class _$Health200ResponseSerializer implements PrimitiveSerializer<Health200Response> {
  @override
  final Iterable<Type> types = const [Health200Response, _$Health200Response];

  @override
  final String wireName = r'Health200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Health200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(Health200ResponseStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Health200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required Health200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Health200ResponseStatusEnum),
          ) as Health200ResponseStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Health200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = Health200ResponseBuilder();
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


class Health200ResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ok')
  static const Health200ResponseStatusEnum ok = _$health200ResponseStatusEnum_ok;

  static Serializer<Health200ResponseStatusEnum> get serializer => _$health200ResponseStatusEnumSerializer;

  const Health200ResponseStatusEnum._(String name): super(name);

  static BuiltSet<Health200ResponseStatusEnum> get values => _$health200ResponseStatusEnumValues;
  static Health200ResponseStatusEnum valueOf(String name) => _$health200ResponseStatusEnumValueOf(name);
}

