//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/goal_status.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'goal_create_request.g.dart';

/// GoalCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [title] 
/// * [body] 
/// * [status] 
/// * [assignedTo] 
@BuiltValue()
abstract class GoalCreateRequest implements CsrfBody, Built<GoalCreateRequest, GoalCreateRequestBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String? get body;

  @BuiltValueField(wireName: r'assigned_to')
  String? get assignedTo;

  @BuiltValueField(wireName: r'status')
  GoalStatus? get status;
  // enum statusEnum {  open,  ongoing,  done,  dropped,  };

  GoalCreateRequest._();

  factory GoalCreateRequest([void updates(GoalCreateRequestBuilder b)]) = _$GoalCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoalCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoalCreateRequest> get serializer => _$GoalCreateRequestSerializer();
}

class _$GoalCreateRequestSerializer implements PrimitiveSerializer<GoalCreateRequest> {
  @override
  final Iterable<Type> types = const [GoalCreateRequest, _$GoalCreateRequest];

  @override
  final String wireName = r'GoalCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoalCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
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
    GoalCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoalCreateRequestBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
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
  GoalCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoalCreateRequestBuilder();
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


