//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'csrf_body.g.dart';

/// CsrfBody
///
/// Properties:
/// * [csrfToken] 
@BuiltValue(instantiable: false)
abstract class CsrfBody  {
  @BuiltValueField(wireName: r'csrf_token')
  String? get csrfToken;

  @BuiltValueSerializer(custom: true)
  static Serializer<CsrfBody> get serializer => _$CsrfBodySerializer();
}

class _$CsrfBodySerializer implements PrimitiveSerializer<CsrfBody> {
  @override
  final Iterable<Type> types = const [CsrfBody];

  @override
  final String wireName = r'CsrfBody';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CsrfBody object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CsrfBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  @override
  CsrfBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.deserialize(serialized, specifiedType: FullType($CsrfBody)) as $CsrfBody;
  }
}


/// a concrete implementation of [CsrfBody], since [CsrfBody] is not instantiable
@BuiltValue(instantiable: true)
abstract class $CsrfBody implements CsrfBody, Built<$CsrfBody, $CsrfBodyBuilder> {
  $CsrfBody._();

  factory $CsrfBody([void Function($CsrfBodyBuilder)? updates]) = _$$CsrfBody;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults($CsrfBodyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<$CsrfBody> get serializer => _$$CsrfBodySerializer();
}

class _$$CsrfBodySerializer implements PrimitiveSerializer<$CsrfBody> {
  @override
  final Iterable<Type> types = const [$CsrfBody, _$$CsrfBody];

  @override
  final String wireName = r'$CsrfBody';

  @override
  Object serialize(
    Serializers serializers,
    $CsrfBody object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return serializers.serialize(object, specifiedType: FullType(CsrfBody))!;
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CsrfBodyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  $CsrfBody deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = $CsrfBodyBuilder();
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

