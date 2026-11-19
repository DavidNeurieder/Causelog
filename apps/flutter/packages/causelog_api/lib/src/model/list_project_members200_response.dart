//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/project_member_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_project_members200_response.g.dart';

/// ListProjectMembers200Response
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ListProjectMembers200Response implements Built<ListProjectMembers200Response, ListProjectMembers200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ProjectMemberInfo> get items;

  ListProjectMembers200Response._();

  factory ListProjectMembers200Response([void updates(ListProjectMembers200ResponseBuilder b)]) = _$ListProjectMembers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListProjectMembers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListProjectMembers200Response> get serializer => _$ListProjectMembers200ResponseSerializer();
}

class _$ListProjectMembers200ResponseSerializer implements PrimitiveSerializer<ListProjectMembers200Response> {
  @override
  final Iterable<Type> types = const [ListProjectMembers200Response, _$ListProjectMembers200Response];

  @override
  final String wireName = r'ListProjectMembers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListProjectMembers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ProjectMemberInfo)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListProjectMembers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListProjectMembers200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProjectMemberInfo)]),
          ) as BuiltList<ProjectMemberInfo>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListProjectMembers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListProjectMembers200ResponseBuilder();
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


