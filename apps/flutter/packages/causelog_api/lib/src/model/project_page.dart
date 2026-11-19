//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/project.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_page.g.dart';

/// ProjectPage
///
/// Properties:
/// * [items] 
/// * [page] 
@BuiltValue()
abstract class ProjectPage implements Built<ProjectPage, ProjectPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Project> get items;

  @BuiltValueField(wireName: r'page')
  PageInfo get page;

  ProjectPage._();

  factory ProjectPage([void updates(ProjectPageBuilder b)]) = _$ProjectPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectPage> get serializer => _$ProjectPageSerializer();
}

class _$ProjectPageSerializer implements PrimitiveSerializer<ProjectPage> {
  @override
  final Iterable<Type> types = const [ProjectPage, _$ProjectPage];

  @override
  final String wireName = r'ProjectPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Project)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(PageInfo),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Project)]),
          ) as BuiltList<Project>;
          result.items.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PageInfo),
          ) as PageInfo;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectPageBuilder();
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


