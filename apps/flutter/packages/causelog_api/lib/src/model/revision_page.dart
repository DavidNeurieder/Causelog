//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/revision.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'revision_page.g.dart';

/// RevisionPage
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class RevisionPage implements Built<RevisionPage, RevisionPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Revision> get items;

  RevisionPage._();

  factory RevisionPage([void updates(RevisionPageBuilder b)]) = _$RevisionPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RevisionPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RevisionPage> get serializer => _$RevisionPageSerializer();
}

class _$RevisionPageSerializer implements PrimitiveSerializer<RevisionPage> {
  @override
  final Iterable<Type> types = const [RevisionPage, _$RevisionPage];

  @override
  final String wireName = r'RevisionPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RevisionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Revision)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RevisionPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RevisionPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Revision)]),
          ) as BuiltList<Revision>;
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
  RevisionPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RevisionPageBuilder();
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


