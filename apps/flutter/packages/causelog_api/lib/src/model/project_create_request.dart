//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/project_status.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_create_request.g.dart';

/// ProjectCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [summary] 
/// * [status] 
@BuiltValue()
abstract class ProjectCreateRequest implements CsrfBody, Built<ProjectCreateRequest, ProjectCreateRequestBuilder> {
  @BuiltValueField(wireName: r'summary')
  String? get summary;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'status')
  ProjectStatus? get status;
  // enum statusEnum {  active,  paused,  archived,  };

  ProjectCreateRequest._();

  factory ProjectCreateRequest([void updates(ProjectCreateRequestBuilder b)]) = _$ProjectCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectCreateRequest> get serializer => _$ProjectCreateRequestSerializer();
}

class _$ProjectCreateRequestSerializer implements PrimitiveSerializer<ProjectCreateRequest> {
  @override
  final Iterable<Type> types = const [ProjectCreateRequest, _$ProjectCreateRequest];

  @override
  final String wireName = r'ProjectCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.summary != null) {
      yield r'summary';
      yield serializers.serialize(
        object.summary,
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
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(ProjectStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summary = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProjectStatus),
          ) as ProjectStatus?;
          if (valueDes == null) continue;
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
  ProjectCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectCreateRequestBuilder();
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


