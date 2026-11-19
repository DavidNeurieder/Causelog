//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/csrf_body.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'experiment_event_create_request.g.dart';

/// ExperimentEventCreateRequest
///
/// Properties:
/// * [csrfToken] 
/// * [kind] 
/// * [atMs] 
/// * [note] 
@BuiltValue()
abstract class ExperimentEventCreateRequest implements CsrfBody, Built<ExperimentEventCreateRequest, ExperimentEventCreateRequestBuilder> {
  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'at_ms')
  int? get atMs;

  @BuiltValueField(wireName: r'kind')
  ExperimentEventCreateRequestKindEnum get kind;
  // enum kindEnum {  observation,  measurement,  milestone,  };

  ExperimentEventCreateRequest._();

  factory ExperimentEventCreateRequest([void updates(ExperimentEventCreateRequestBuilder b)]) = _$ExperimentEventCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExperimentEventCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExperimentEventCreateRequest> get serializer => _$ExperimentEventCreateRequestSerializer();
}

class _$ExperimentEventCreateRequestSerializer implements PrimitiveSerializer<ExperimentEventCreateRequest> {
  @override
  final Iterable<Type> types = const [ExperimentEventCreateRequest, _$ExperimentEventCreateRequest];

  @override
  final String wireName = r'ExperimentEventCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExperimentEventCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    if (object.csrfToken != null) {
      yield r'csrf_token';
      yield serializers.serialize(
        object.csrfToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.atMs != null) {
      yield r'at_ms';
      yield serializers.serialize(
        object.atMs,
        specifiedType: const FullType(int),
      );
    }
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ExperimentEventCreateRequestKindEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExperimentEventCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExperimentEventCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'csrf_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.csrfToken = valueDes;
          break;
        case r'at_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.atMs = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExperimentEventCreateRequestKindEnum),
          ) as ExperimentEventCreateRequestKindEnum;
          result.kind = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExperimentEventCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExperimentEventCreateRequestBuilder();
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


class ExperimentEventCreateRequestKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'observation')
  static const ExperimentEventCreateRequestKindEnum observation = _$experimentEventCreateRequestKindEnum_observation;
  @BuiltValueEnumConst(wireName: r'measurement')
  static const ExperimentEventCreateRequestKindEnum measurement = _$experimentEventCreateRequestKindEnum_measurement;
  @BuiltValueEnumConst(wireName: r'milestone')
  static const ExperimentEventCreateRequestKindEnum milestone = _$experimentEventCreateRequestKindEnum_milestone;

  static Serializer<ExperimentEventCreateRequestKindEnum> get serializer => _$experimentEventCreateRequestKindEnumSerializer;

  const ExperimentEventCreateRequestKindEnum._(String name): super(name);

  static BuiltSet<ExperimentEventCreateRequestKindEnum> get values => _$experimentEventCreateRequestKindEnumValues;
  static ExperimentEventCreateRequestKindEnum valueOf(String name) => _$experimentEventCreateRequestKindEnumValueOf(name);
}

