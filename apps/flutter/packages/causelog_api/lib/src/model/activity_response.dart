//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/activity_item.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'activity_response.g.dart';

/// ActivityResponse
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ActivityResponse implements Built<ActivityResponse, ActivityResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ActivityItem> get items;

  ActivityResponse._();

  factory ActivityResponse([void updates(ActivityResponseBuilder b)]) = _$ActivityResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActivityResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActivityResponse> get serializer => _$ActivityResponseSerializer();
}

class _$ActivityResponseSerializer implements PrimitiveSerializer<ActivityResponse> {
  @override
  final Iterable<Type> types = const [ActivityResponse, _$ActivityResponse];

  @override
  final String wireName = r'ActivityResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActivityResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ActivityItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActivityResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActivityResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ActivityItem)]),
          ) as BuiltList<ActivityItem>;
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
  ActivityResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActivityResponseBuilder();
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


