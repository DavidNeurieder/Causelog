//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/decision_status.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/decision_option.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'decision.g.dart';

/// Decision
///
/// Properties:
/// * [id] 
/// * [projectId] 
/// * [goalId] 
/// * [title] 
/// * [context] 
/// * [options] 
/// * [status] 
/// * [decidedOption] 
/// * [rationale] 
/// * [decidedAtMs] 
/// * [reviewAtMs] 
/// * [createdBy] 
/// * [createdAtMs] 
/// * [updatedAtMs] 
@BuiltValue()
abstract class Decision implements Built<Decision, DecisionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'project_id')
  String get projectId;

  @BuiltValueField(wireName: r'goal_id')
  String? get goalId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'context')
  String get context;

  @BuiltValueField(wireName: r'options')
  BuiltList<DecisionOption> get options;

  @BuiltValueField(wireName: r'status')
  DecisionStatus get status;
  // enum statusEnum {  open,  decided,  rejected,  };

  @BuiltValueField(wireName: r'decided_option')
  String? get decidedOption;

  @BuiltValueField(wireName: r'rationale')
  String get rationale;

  @BuiltValueField(wireName: r'decided_at_ms')
  int? get decidedAtMs;

  @BuiltValueField(wireName: r'review_at_ms')
  int? get reviewAtMs;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  @BuiltValueField(wireName: r'updated_at_ms')
  int get updatedAtMs;

  Decision._();

  factory Decision([void updates(DecisionBuilder b)]) = _$Decision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Decision> get serializer => _$DecisionSerializer();
}

class _$DecisionSerializer implements PrimitiveSerializer<Decision> {
  @override
  final Iterable<Type> types = const [Decision, _$Decision];

  @override
  final String wireName = r'Decision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Decision object, {
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
    if (object.goalId != null) {
      yield r'goal_id';
      yield serializers.serialize(
        object.goalId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'context';
    yield serializers.serialize(
      object.context,
      specifiedType: const FullType(String),
    );
    yield r'options';
    yield serializers.serialize(
      object.options,
      specifiedType: const FullType(BuiltList, [FullType(DecisionOption)]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DecisionStatus),
    );
    if (object.decidedOption != null) {
      yield r'decided_option';
      yield serializers.serialize(
        object.decidedOption,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'rationale';
    yield serializers.serialize(
      object.rationale,
      specifiedType: const FullType(String),
    );
    if (object.decidedAtMs != null) {
      yield r'decided_at_ms';
      yield serializers.serialize(
        object.decidedAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.reviewAtMs != null) {
      yield r'review_at_ms';
      yield serializers.serialize(
        object.reviewAtMs,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
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
    Decision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DecisionBuilder result,
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
        case r'goal_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.goalId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'context':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.context = valueDes;
          break;
        case r'options':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DecisionOption)]),
          ) as BuiltList<DecisionOption>;
          result.options.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DecisionStatus),
          ) as DecisionStatus;
          result.status = valueDes;
          break;
        case r'decided_option':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decidedOption = valueDes;
          break;
        case r'rationale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rationale = valueDes;
          break;
        case r'decided_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.decidedAtMs = valueDes;
          break;
        case r'review_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.reviewAtMs = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
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
  Decision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DecisionBuilder();
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


