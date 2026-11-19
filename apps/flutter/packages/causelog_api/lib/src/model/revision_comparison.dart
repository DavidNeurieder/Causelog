//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/revision.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'revision_comparison.g.dart';

/// RevisionComparison
///
/// Properties:
/// * [from] 
/// * [to] 
/// * [unifiedDiff] - Unified diff of Markdown snapshots (server-computed when available)
@BuiltValue()
abstract class RevisionComparison implements Built<RevisionComparison, RevisionComparisonBuilder> {
  @BuiltValueField(wireName: r'from')
  Revision get from;

  @BuiltValueField(wireName: r'to')
  Revision get to;

  /// Unified diff of Markdown snapshots (server-computed when available)
  @BuiltValueField(wireName: r'unified_diff')
  String? get unifiedDiff;

  RevisionComparison._();

  factory RevisionComparison([void updates(RevisionComparisonBuilder b)]) = _$RevisionComparison;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RevisionComparisonBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RevisionComparison> get serializer => _$RevisionComparisonSerializer();
}

class _$RevisionComparisonSerializer implements PrimitiveSerializer<RevisionComparison> {
  @override
  final Iterable<Type> types = const [RevisionComparison, _$RevisionComparison];

  @override
  final String wireName = r'RevisionComparison';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RevisionComparison object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from';
    yield serializers.serialize(
      object.from,
      specifiedType: const FullType(Revision),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(Revision),
    );
    if (object.unifiedDiff != null) {
      yield r'unified_diff';
      yield serializers.serialize(
        object.unifiedDiff,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RevisionComparison object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RevisionComparisonBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Revision),
          ) as Revision;
          result.from.replace(valueDes);
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Revision),
          ) as Revision;
          result.to.replace(valueDes);
          break;
        case r'unified_diff':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unifiedDiff = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RevisionComparison deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RevisionComparisonBuilder();
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


