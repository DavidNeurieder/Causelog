// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExperimentEventKindEnum _$experimentEventKindEnum_observation =
    const ExperimentEventKindEnum._('observation');
const ExperimentEventKindEnum _$experimentEventKindEnum_measurement =
    const ExperimentEventKindEnum._('measurement');
const ExperimentEventKindEnum _$experimentEventKindEnum_milestone =
    const ExperimentEventKindEnum._('milestone');

ExperimentEventKindEnum _$experimentEventKindEnumValueOf(String name) {
  switch (name) {
    case 'observation':
      return _$experimentEventKindEnum_observation;
    case 'measurement':
      return _$experimentEventKindEnum_measurement;
    case 'milestone':
      return _$experimentEventKindEnum_milestone;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExperimentEventKindEnum> _$experimentEventKindEnumValues =
    BuiltSet<ExperimentEventKindEnum>(const <ExperimentEventKindEnum>[
  _$experimentEventKindEnum_observation,
  _$experimentEventKindEnum_measurement,
  _$experimentEventKindEnum_milestone,
]);

Serializer<ExperimentEventKindEnum> _$experimentEventKindEnumSerializer =
    _$ExperimentEventKindEnumSerializer();

class _$ExperimentEventKindEnumSerializer
    implements PrimitiveSerializer<ExperimentEventKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'observation': 'observation',
    'measurement': 'measurement',
    'milestone': 'milestone',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'observation': 'observation',
    'measurement': 'measurement',
    'milestone': 'milestone',
  };

  @override
  final Iterable<Type> types = const <Type>[ExperimentEventKindEnum];
  @override
  final String wireName = 'ExperimentEventKindEnum';

  @override
  Object serialize(Serializers serializers, ExperimentEventKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExperimentEventKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExperimentEventKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ExperimentEvent extends ExperimentEvent {
  @override
  final String id;
  @override
  final String experimentId;
  @override
  final ExperimentEventKindEnum kind;
  @override
  final int atMs;
  @override
  final String note;
  @override
  final int createdAtMs;

  factory _$ExperimentEvent([void Function(ExperimentEventBuilder)? updates]) =>
      (ExperimentEventBuilder()..update(updates))._build();

  _$ExperimentEvent._(
      {required this.id,
      required this.experimentId,
      required this.kind,
      required this.atMs,
      required this.note,
      required this.createdAtMs})
      : super._();
  @override
  ExperimentEvent rebuild(void Function(ExperimentEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExperimentEventBuilder toBuilder() => ExperimentEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExperimentEvent &&
        id == other.id &&
        experimentId == other.experimentId &&
        kind == other.kind &&
        atMs == other.atMs &&
        note == other.note &&
        createdAtMs == other.createdAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, experimentId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, atMs.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExperimentEvent')
          ..add('id', id)
          ..add('experimentId', experimentId)
          ..add('kind', kind)
          ..add('atMs', atMs)
          ..add('note', note)
          ..add('createdAtMs', createdAtMs))
        .toString();
  }
}

class ExperimentEventBuilder
    implements Builder<ExperimentEvent, ExperimentEventBuilder> {
  _$ExperimentEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _experimentId;
  String? get experimentId => _$this._experimentId;
  set experimentId(String? experimentId) => _$this._experimentId = experimentId;

  ExperimentEventKindEnum? _kind;
  ExperimentEventKindEnum? get kind => _$this._kind;
  set kind(ExperimentEventKindEnum? kind) => _$this._kind = kind;

  int? _atMs;
  int? get atMs => _$this._atMs;
  set atMs(int? atMs) => _$this._atMs = atMs;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  ExperimentEventBuilder() {
    ExperimentEvent._defaults(this);
  }

  ExperimentEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _experimentId = $v.experimentId;
      _kind = $v.kind;
      _atMs = $v.atMs;
      _note = $v.note;
      _createdAtMs = $v.createdAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExperimentEvent other) {
    _$v = other as _$ExperimentEvent;
  }

  @override
  void update(void Function(ExperimentEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExperimentEvent build() => _build();

  _$ExperimentEvent _build() {
    final _$result = _$v ??
        _$ExperimentEvent._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ExperimentEvent', 'id'),
          experimentId: BuiltValueNullFieldError.checkNotNull(
              experimentId, r'ExperimentEvent', 'experimentId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ExperimentEvent', 'kind'),
          atMs: BuiltValueNullFieldError.checkNotNull(
              atMs, r'ExperimentEvent', 'atMs'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'ExperimentEvent', 'note'),
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'ExperimentEvent', 'createdAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
