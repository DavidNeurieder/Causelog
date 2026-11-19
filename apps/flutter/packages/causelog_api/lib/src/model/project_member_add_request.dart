//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_member_add_request.g.dart';

/// ProjectMemberAddRequest
///
/// Properties:
/// * [csrfToken] 
/// * [userId] 
/// * [role] 
@BuiltValue()
abstract class ProjectMemberAddRequest implements CsrfBody, Built<ProjectMemberAddRequest, ProjectMemberAddRequestBuilder> {
  @BuiltValueField(wireName: r'role')
  ProjectMemberAddRequestRoleEnum? get role;
  // enum roleEnum {  owner,  member,  };

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  ProjectMemberAddRequest._();

  factory ProjectMemberAddRequest([void updates(ProjectMemberAddRequestBuilder b)]) = _$ProjectMemberAddRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectMemberAddRequestBuilder b) => b
      ..role = ProjectMemberAddRequestRoleEnum.valueOf('member');

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectMemberAddRequest> get serializer => _$ProjectMemberAddRequestSerializer();
}

class _$ProjectMemberAddRequestSerializer implements PrimitiveSerializer<ProjectMemberAddRequest> {
  @override
  final Iterable<Type> types = const [ProjectMemberAddRequest, _$ProjectMemberAddRequest];

  @override
  final String wireName = r'ProjectMemberAddRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectMemberAddRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(ProjectMemberAddRequestRoleEnum),
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
    ProjectMemberAddRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectMemberAddRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ProjectMemberAddRequestRoleEnum),
          ) as ProjectMemberAddRequestRoleEnum?;
          if (valueDes == null) continue;
          result.role = valueDes;
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
  ProjectMemberAddRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectMemberAddRequestBuilder();
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


class ProjectMemberAddRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'owner')
  static const ProjectMemberAddRequestRoleEnum owner = _$projectMemberAddRequestRoleEnum_owner;
  @BuiltValueEnumConst(wireName: r'member')
  static const ProjectMemberAddRequestRoleEnum member = _$projectMemberAddRequestRoleEnum_member;

  static Serializer<ProjectMemberAddRequestRoleEnum> get serializer => _$projectMemberAddRequestRoleEnumSerializer;

  const ProjectMemberAddRequestRoleEnum._(String name): super(name);

  static BuiltSet<ProjectMemberAddRequestRoleEnum> get values => _$projectMemberAddRequestRoleEnumValues;
  static ProjectMemberAddRequestRoleEnum valueOf(String name) => _$projectMemberAddRequestRoleEnumValueOf(name);
}

