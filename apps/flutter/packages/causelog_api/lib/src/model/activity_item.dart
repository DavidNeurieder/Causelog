//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'activity_item.g.dart';

/// ActivityItem
///
/// Properties:
/// * [kind] 
/// * [atMs] 
/// * [entityType] 
/// * [entityId] 
/// * [title] 
@BuiltValue()
abstract class ActivityItem implements Built<ActivityItem, ActivityItemBuilder> {
  @BuiltValueField(wireName: r'kind')
  String get kind;

  @BuiltValueField(wireName: r'at_ms')
  int get atMs;

  @BuiltValueField(wireName: r'entity_type')
  String? get entityType;

  @BuiltValueField(wireName: r'entity_id')
  String? get entityId;

  @BuiltValueField(wireName: r'title')
  String get title;

  ActivityItem._();

  factory ActivityItem([void updates(ActivityItemBuilder b)]) = _$ActivityItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ActivityItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ActivityItem> get serializer => _$ActivityItemSerializer();
}

class _$ActivityItemSerializer implements PrimitiveSerializer<ActivityItem> {
  @override
  final Iterable<Type> types = const [ActivityItem, _$ActivityItem];

  @override
  final String wireName = r'ActivityItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ActivityItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(String),
    );
    yield r'at_ms';
    yield serializers.serialize(
      object.atMs,
      specifiedType: const FullType(int),
    );
    if (object.entityType != null) {
      yield r'entity_type';
      yield serializers.serialize(
        object.entityType,
        specifiedType: const FullType(String),
      );
    }
    if (object.entityId != null) {
      yield r'entity_id';
      yield serializers.serialize(
        object.entityId,
        specifiedType: const FullType(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ActivityItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ActivityItemBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.kind = valueDes;
          break;
        case r'at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.atMs = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.entityId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ActivityItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ActivityItemBuilder();
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


