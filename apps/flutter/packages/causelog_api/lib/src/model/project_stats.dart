//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'project_stats.g.dart';

/// ProjectStats
///
/// Properties:
/// * [goalsTotal] 
/// * [goalsOpen] 
/// * [goalsDone] 
/// * [goalsDropped] 
/// * [decisionsTotal] 
/// * [decisionsOpen] 
/// * [decisionsDecided] 
/// * [decisionsRejected] 
/// * [experimentsTotal] 
/// * [experimentsPlanned] 
/// * [experimentsOngoing] 
/// * [experimentsDone] 
/// * [experimentsAbandoned] 
/// * [notesTotal] 
@BuiltValue()
abstract class ProjectStats implements Built<ProjectStats, ProjectStatsBuilder> {
  @BuiltValueField(wireName: r'goals_total')
  int get goalsTotal;

  @BuiltValueField(wireName: r'goals_open')
  int get goalsOpen;

  @BuiltValueField(wireName: r'goals_done')
  int get goalsDone;

  @BuiltValueField(wireName: r'goals_dropped')
  int get goalsDropped;

  @BuiltValueField(wireName: r'decisions_total')
  int get decisionsTotal;

  @BuiltValueField(wireName: r'decisions_open')
  int get decisionsOpen;

  @BuiltValueField(wireName: r'decisions_decided')
  int get decisionsDecided;

  @BuiltValueField(wireName: r'decisions_rejected')
  int get decisionsRejected;

  @BuiltValueField(wireName: r'experiments_total')
  int get experimentsTotal;

  @BuiltValueField(wireName: r'experiments_planned')
  int get experimentsPlanned;

  @BuiltValueField(wireName: r'experiments_ongoing')
  int get experimentsOngoing;

  @BuiltValueField(wireName: r'experiments_done')
  int get experimentsDone;

  @BuiltValueField(wireName: r'experiments_abandoned')
  int get experimentsAbandoned;

  @BuiltValueField(wireName: r'notes_total')
  int get notesTotal;

  ProjectStats._();

  factory ProjectStats([void updates(ProjectStatsBuilder b)]) = _$ProjectStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProjectStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProjectStats> get serializer => _$ProjectStatsSerializer();
}

class _$ProjectStatsSerializer implements PrimitiveSerializer<ProjectStats> {
  @override
  final Iterable<Type> types = const [ProjectStats, _$ProjectStats];

  @override
  final String wireName = r'ProjectStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProjectStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'goals_total';
    yield serializers.serialize(
      object.goalsTotal,
      specifiedType: const FullType(int),
    );
    yield r'goals_open';
    yield serializers.serialize(
      object.goalsOpen,
      specifiedType: const FullType(int),
    );
    yield r'goals_done';
    yield serializers.serialize(
      object.goalsDone,
      specifiedType: const FullType(int),
    );
    yield r'goals_dropped';
    yield serializers.serialize(
      object.goalsDropped,
      specifiedType: const FullType(int),
    );
    yield r'decisions_total';
    yield serializers.serialize(
      object.decisionsTotal,
      specifiedType: const FullType(int),
    );
    yield r'decisions_open';
    yield serializers.serialize(
      object.decisionsOpen,
      specifiedType: const FullType(int),
    );
    yield r'decisions_decided';
    yield serializers.serialize(
      object.decisionsDecided,
      specifiedType: const FullType(int),
    );
    yield r'decisions_rejected';
    yield serializers.serialize(
      object.decisionsRejected,
      specifiedType: const FullType(int),
    );
    yield r'experiments_total';
    yield serializers.serialize(
      object.experimentsTotal,
      specifiedType: const FullType(int),
    );
    yield r'experiments_planned';
    yield serializers.serialize(
      object.experimentsPlanned,
      specifiedType: const FullType(int),
    );
    yield r'experiments_ongoing';
    yield serializers.serialize(
      object.experimentsOngoing,
      specifiedType: const FullType(int),
    );
    yield r'experiments_done';
    yield serializers.serialize(
      object.experimentsDone,
      specifiedType: const FullType(int),
    );
    yield r'experiments_abandoned';
    yield serializers.serialize(
      object.experimentsAbandoned,
      specifiedType: const FullType(int),
    );
    yield r'notes_total';
    yield serializers.serialize(
      object.notesTotal,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProjectStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProjectStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'goals_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.goalsTotal = valueDes;
          break;
        case r'goals_open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.goalsOpen = valueDes;
          break;
        case r'goals_done':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.goalsDone = valueDes;
          break;
        case r'goals_dropped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.goalsDropped = valueDes;
          break;
        case r'decisions_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.decisionsTotal = valueDes;
          break;
        case r'decisions_open':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.decisionsOpen = valueDes;
          break;
        case r'decisions_decided':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.decisionsDecided = valueDes;
          break;
        case r'decisions_rejected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.decisionsRejected = valueDes;
          break;
        case r'experiments_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experimentsTotal = valueDes;
          break;
        case r'experiments_planned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experimentsPlanned = valueDes;
          break;
        case r'experiments_ongoing':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experimentsOngoing = valueDes;
          break;
        case r'experiments_done':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experimentsDone = valueDes;
          break;
        case r'experiments_abandoned':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.experimentsAbandoned = valueDes;
          break;
        case r'notes_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.notesTotal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProjectStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProjectStatsBuilder();
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


