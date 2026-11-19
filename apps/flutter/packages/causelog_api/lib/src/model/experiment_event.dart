//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_event.g.dart';

/// ExperimentEvent
///
/// Properties:
/// * [id] 
/// * [experimentId] 
/// * [kind] 
/// * [atMs] 
/// * [note] 
/// * [createdAtMs] 
@BuiltValue()
abstract class ExperimentEvent implements Built<ExperimentEvent, ExperimentEventBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'experiment_id')
  String get experimentId;

  @BuiltValueField(wireName: r'kind')
  ExperimentEventKindEnum get kind;
  // enum kindEnum {  observation,  measurement,  milestone,  };

  @BuiltValueField(wireName: r'at_ms')
  int get atMs;

  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'created_at_ms')
  int get createdAtMs;

  ExperimentEvent._();

  factory ExperimentEvent([void updates(ExperimentEventBuilder b)]) = _$ExperimentEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentEvent> get serializer => _$ExperimentEventSerializer();
}

class _$ExperimentEventSerializer implements PrimitiveSerializer<ExperimentEvent> {
  @override
  final Iterable<Type> types = const [ExperimentEvent, _$ExperimentEvent];

  @override
  final String wireName = r'ExperimentEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'experiment_id';
    yield serializers.serialize(
      object.experimentId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ExperimentEventKindEnum),
    );
    yield r'at_ms';
    yield serializers.serialize(
      object.atMs,
      specifiedType: const FullType(int),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    yield r'created_at_ms';
    yield serializers.serialize(
      object.createdAtMs,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExperimentEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentEventBuilder result,
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
        case r'experiment_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.experimentId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExperimentEventKindEnum),
          ) as ExperimentEventKindEnum;
          result.kind = valueDes;
          break;
        case r'at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.atMs = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'created_at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.createdAtMs = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExperimentEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentEventBuilder();
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


class ExperimentEventKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'observation')
  static const ExperimentEventKindEnum observation = _$experimentEventKindEnum_observation;
  @BuiltValueEnumConst(wireName: r'measurement')
  static const ExperimentEventKindEnum measurement = _$experimentEventKindEnum_measurement;
  @BuiltValueEnumConst(wireName: r'milestone')
  static const ExperimentEventKindEnum milestone = _$experimentEventKindEnum_milestone;

  static Serializer<ExperimentEventKindEnum> get serializer => _$experimentEventKindEnumSerializer;

  const ExperimentEventKindEnum._(String name): super(name);

  static BuiltSet<ExperimentEventKindEnum> get values => _$experimentEventKindEnumValues;
  static ExperimentEventKindEnum valueOf(String name) => _$experimentEventKindEnumValueOf(name);
}

