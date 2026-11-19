//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_member_info.g.dart';

/// ProjectMemberInfo
///
/// Properties:
/// * [user] 
/// * [role] 
@BuiltValue()
abstract class ProjectMemberInfo implements Built<ProjectMemberInfo, ProjectMemberInfoBuilder> {
  @BuiltValueField(wireName: r'user')
  User get user;

  @BuiltValueField(wireName: r'role')
  ProjectMemberInfoRoleEnum get role;
  // enum roleEnum {  owner,  member,  };

  ProjectMemberInfo._();

  factory ProjectMemberInfo([void updates(ProjectMemberInfoBuilder b)]) = _$ProjectMemberInfo;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectMemberInfoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectMemberInfo> get serializer => _$ProjectMemberInfoSerializer();
}

class _$ProjectMemberInfoSerializer implements PrimitiveSerializer<ProjectMemberInfo> {
  @override
  final Iterable<Type> types = const [ProjectMemberInfo, _$ProjectMemberInfo];

  @override
  final String wireName = r'ProjectMemberInfo';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectMemberInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(User),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(ProjectMemberInfoRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectMemberInfo object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectMemberInfoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(User),
          ) as User;
          result.user.replace(valueDes);
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProjectMemberInfoRoleEnum),
          ) as ProjectMemberInfoRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectMemberInfo deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectMemberInfoBuilder();
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


class ProjectMemberInfoRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'owner')
  static const ProjectMemberInfoRoleEnum owner = _$projectMemberInfoRoleEnum_owner;
  @BuiltValueEnumConst(wireName: r'member')
  static const ProjectMemberInfoRoleEnum member = _$projectMemberInfoRoleEnum_member;

  static Serializer<ProjectMemberInfoRoleEnum> get serializer => _$projectMemberInfoRoleEnumSerializer;

  const ProjectMemberInfoRoleEnum._(String name): super(name);

  static BuiltSet<ProjectMemberInfoRoleEnum> get values => _$projectMemberInfoRoleEnumValues;
  static ProjectMemberInfoRoleEnum valueOf(String name) => _$projectMemberInfoRoleEnumValueOf(name);
}

