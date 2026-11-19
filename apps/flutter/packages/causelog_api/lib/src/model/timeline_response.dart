//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/timeline_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timeline_response.g.dart';

/// TimelineResponse
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class TimelineResponse implements Built<TimelineResponse, TimelineResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<TimelineEvent> get items;

  TimelineResponse._();

  factory TimelineResponse([void updates(TimelineResponseBuilder b)]) = _$TimelineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimelineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimelineResponse> get serializer => _$TimelineResponseSerializer();
}

class _$TimelineResponseSerializer implements PrimitiveSerializer<TimelineResponse> {
  @override
  final Iterable<Type> types = const [TimelineResponse, _$TimelineResponse];

  @override
  final String wireName = r'TimelineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimelineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(TimelineEvent)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TimelineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TimelineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TimelineEvent)]),
          ) as BuiltList<TimelineEvent>;
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
  TimelineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimelineResponseBuilder();
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


