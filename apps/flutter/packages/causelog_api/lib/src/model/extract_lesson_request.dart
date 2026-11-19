//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'extract_lesson_request.g.dart';

/// ExtractLessonRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [body] 
@BuiltValue()
abstract class ExtractLessonRequest implements CsrfBody, Built<ExtractLessonRequest, ExtractLessonRequestBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  ExtractLessonRequest._();

  factory ExtractLessonRequest([void updates(ExtractLessonRequestBuilder b)]) = _$ExtractLessonRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExtractLessonRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExtractLessonRequest> get serializer => _$ExtractLessonRequestSerializer();
}

class _$ExtractLessonRequestSerializer implements PrimitiveSerializer<ExtractLessonRequest> {
  @override
  final Iterable<Type> types = const [ExtractLessonRequest, _$ExtractLessonRequest];

  @override
  final String wireName = r'ExtractLessonRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExtractLessonRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
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
    ExtractLessonRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExtractLessonRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
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
  ExtractLessonRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExtractLessonRequestBuilder();
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


