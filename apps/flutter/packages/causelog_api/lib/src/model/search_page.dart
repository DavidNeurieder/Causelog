//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/search_result.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_page.g.dart';

/// SearchPage
///
/// Properties:
/// * [items] 
/// * [page] 
@BuiltValue()
abstract class SearchPage implements Built<SearchPage, SearchPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<SearchResult> get items;

  @BuiltValueField(wireName: r'page')
  PageInfo get page;

  SearchPage._();

  factory SearchPage([void updates(SearchPageBuilder b)]) = _$SearchPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchPage> get serializer => _$SearchPageSerializer();
}

class _$SearchPageSerializer implements PrimitiveSerializer<SearchPage> {
  @override
  final Iterable<Type> types = const [SearchPage, _$SearchPage];

  @override
  final String wireName = r'SearchPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(SearchResult)]),
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
    SearchPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchResult)]),
          ) as BuiltList<SearchResult>;
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
  SearchPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchPageBuilder();
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


