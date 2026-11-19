//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/goal_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'goal.g.dart';

/// Goal
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [title] 
/// * [body] 
/// * [status] 
/// * [createdBy] 
/// * [assignedTo] 
/// * [createdAtMs] 
/// * [updatedAtMs] 
@BuiltValue()
abstract class Goal implements Built<Goal, GoalBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'status')
  GoalStatus get status;
  // enum statusEnum {  open,  ongoing,  done,  dropped,  };

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'assigned_to')
  String? get assignedTo;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  @BuiltValueField(wireName: r'updated_at_ms')
  int get updatedAtMs;

  Goal._();

  factory Goal([void updates(GoalBuilder b)]) = _$Goal;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoalBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Goal> get serializer => _$GoalSerializer();
}

class _$GoalSerializer implements PrimitiveSerializer<Goal> {
  @override
  final Iterable<Type> types = const [Goal, _$Goal];

  @override
  final String wireName = r'Goal';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Goal object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'project_id';
    yield serializers.serialize(
      object.projectId,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(GoalStatus),
    );
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.assignedTo != null) {
      yield r'assigned_to';
      yield serializers.serialize(
        object.assignedTo,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_at_ms';
    yield serializers.serialize(
      object.createdAtMs,
      specifiedType: const FullType(int),
    );
    yield r'updated_at_ms';
    yield serializers.serialize(
      object.updatedAtMs,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Goal object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoalBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'project_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.projectId = valueDes;
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
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GoalStatus),
          ) as GoalStatus;
          result.status = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'assigned_to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedTo = valueDes;
          break;
        case r'created_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAtMs = valueDes;
          break;
        case r'updated_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedAtMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Goal deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoalBuilder();
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


