//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/goal_status.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'goal_update_request.g.dart';

/// GoalUpdateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [body] 
/// * [status] 
/// * [assignedTo] 
@BuiltValue()
abstract class GoalUpdateRequest implements CsrfBody, Built<GoalUpdateRequest, GoalUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  @BuiltValueField(wireName: r'assigned_to')
  String? get assignedTo;

  @BuiltValueField(wireName: r'status')
  GoalStatus? get status;
  // enum statusEnum {  open,  ongoing,  done,  dropped,  };

  GoalUpdateRequest._();

  factory GoalUpdateRequest([void updates(GoalUpdateRequestBuilder b)]) = _$GoalUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoalUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoalUpdateRequest> get serializer => _$GoalUpdateRequestSerializer();
}

class _$GoalUpdateRequestSerializer implements PrimitiveSerializer<GoalUpdateRequest> {
  @override
  final Iterable<Type> types = const [GoalUpdateRequest, _$GoalUpdateRequest];

  @override
  final String wireName = r'GoalUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoalUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.body != null) {
      yield r'body';
      yield serializers.serialize(
        object.body,
        specifiedType: const FullType(String),
      );
    }
    if (object.assignedTo != null) {
      yield r'assigned_to';
      yield serializers.serialize(
        object.assignedTo,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(GoalStatus),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GoalUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoalUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.title = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.body = valueDes;
          break;
        case r'assigned_to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedTo = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(GoalStatus),
          ) as GoalStatus?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GoalUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoalUpdateRequestBuilder();
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


