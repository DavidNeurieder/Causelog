//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/note.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'note_page.g.dart';

/// NotePage
///
/// Properties:
/// * [items] 
/// * [page] 
@BuiltValue()
abstract class NotePage implements Built<NotePage, NotePageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Note> get items;

  @BuiltValueField(wireName: r'page')
  PageInfo get page;

  NotePage._();

  factory NotePage([void updates(NotePageBuilder b)]) = _$NotePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotePage> get serializer => _$NotePageSerializer();
}

class _$NotePageSerializer implements PrimitiveSerializer<NotePage> {
  @override
  final Iterable<Type> types = const [NotePage, _$NotePage];

  @override
  final String wireName = r'NotePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Note)]),
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
    NotePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Note)]),
          ) as BuiltList<Note>;
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
  NotePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotePageBuilder();
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


