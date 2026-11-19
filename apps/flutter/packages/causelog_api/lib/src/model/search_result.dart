//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_result.g.dart';

/// SearchResult
///
/// Properties:
/// * [entityType] 
/// * [entityId] 
/// * [projectId] 
/// * [projectTitle] 
/// * [title] 
/// * [snippet] 
/// * [rank] 
@BuiltValue()
abstract class SearchResult implements Built<SearchResult, SearchResultBuilder> {
  @BuiltValueField(wireName: r'entity_type')
  SearchResultEntityTypeEnum get entityType;
  // enum entityTypeEnum {  project,  goal,  decision,  experiment,  note,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'project_title')
  String get projectTitle;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'snippet')
  String get snippet;

  @BuiltValueField(wireName: r'rank')
  num get rank;

  SearchResult._();

  factory SearchResult([void updates(SearchResultBuilder b)]) = _$SearchResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchResult> get serializer => _$SearchResultSerializer();
}

class _$SearchResultSerializer implements PrimitiveSerializer<SearchResult> {
  @override
  final Iterable<Type> types = const [SearchResult, _$SearchResult];

  @override
  final String wireName = r'SearchResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(SearchResultEntityTypeEnum),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'project_id';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'project_title';
    yield serializers.serialize(
      object.projectTitle,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'snippet';
    yield serializers.serialize(
      object.snippet,
      specifiedType: const FullType(String),
    );
    yield r'rank';
    yield serializers.serialize(
      object.rank,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SearchResultEntityTypeEnum),
          ) as SearchResultEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'project_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
          break;
        case r'project_title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectTitle = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'snippet':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.snippet = valueDes;
          break;
        case r'rank':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rank = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchResultBuilder();
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


class SearchResultEntityTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'project')
  static const SearchResultEntityTypeEnum project = _$searchResultEntityTypeEnum_project;
  @BuiltValueEnumConst(wireName: r'goal')
  static const SearchResultEntityTypeEnum goal = _$searchResultEntityTypeEnum_goal;
  @BuiltValueEnumConst(wireName: r'decision')
  static const SearchResultEntityTypeEnum decision = _$searchResultEntityTypeEnum_decision;
  @BuiltValueEnumConst(wireName: r'experiment')
  static const SearchResultEntityTypeEnum experiment = _$searchResultEntityTypeEnum_experiment;
  @BuiltValueEnumConst(wireName: r'note')
  static const SearchResultEntityTypeEnum note = _$searchResultEntityTypeEnum_note;

  static Serializer<SearchResultEntityTypeEnum> get serializer => _$searchResultEntityTypeEnumSerializer;

  const SearchResultEntityTypeEnum._(String name): super(name);

  static BuiltSet<SearchResultEntityTypeEnum> get values => _$searchResultEntityTypeEnumValues;
  static SearchResultEntityTypeEnum valueOf(String name) => _$searchResultEntityTypeEnumValueOf(name);
}

