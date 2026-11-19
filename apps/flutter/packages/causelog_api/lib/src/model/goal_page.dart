//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/goal.dart';
import 'package:openapi/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'goal_page.g.dart';

/// GoalPage
///
/// Properties:
/// * [items] 
/// * [page] 
@BuiltValue()
abstract class GoalPage implements Built<GoalPage, GoalPageBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Goal> get items;

  @BuiltValueField(wireName: r'page')
  PageInfo get page;

  GoalPage._();

  factory GoalPage([void updates(GoalPageBuilder b)]) = _$GoalPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoalPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoalPage> get serializer => _$GoalPageSerializer();
}

class _$GoalPageSerializer implements PrimitiveSerializer<GoalPage> {
  @override
  final Iterable<Type> types = const [GoalPage, _$GoalPage];

  @override
  final String wireName = r'GoalPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoalPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Goal)]),
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
    GoalPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoalPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Goal)]),
          ) as BuiltList<Goal>;
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
  GoalPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoalPageBuilder();
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


