//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'note_update_request.g.dart';

/// NoteUpdateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [body] 
@BuiltValue()
abstract class NoteUpdateRequest implements CsrfBody, Built<NoteUpdateRequest, NoteUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  NoteUpdateRequest._();

  factory NoteUpdateRequest([void updates(NoteUpdateRequestBuilder b)]) = _$NoteUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NoteUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NoteUpdateRequest> get serializer => _$NoteUpdateRequestSerializer();
}

class _$NoteUpdateRequestSerializer implements PrimitiveSerializer<NoteUpdateRequest> {
  @override
  final Iterable<Type> types = const [NoteUpdateRequest, _$NoteUpdateRequest];

  @override
  final String wireName = r'NoteUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NoteUpdateRequest object, {
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
    NoteUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NoteUpdateRequestBuilder result,
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
  NoteUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NoteUpdateRequestBuilder();
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


