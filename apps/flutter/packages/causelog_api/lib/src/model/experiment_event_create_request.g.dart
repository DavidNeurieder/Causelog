// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_event_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExperimentEventCreateRequestKindEnum
    _$experimentEventCreateRequestKindEnum_observation =
    const ExperimentEventCreateRequestKindEnum._('observation');
const ExperimentEventCreateRequestKindEnum
    _$experimentEventCreateRequestKindEnum_measurement =
    const ExperimentEventCreateRequestKindEnum._('measurement');
const ExperimentEventCreateRequestKindEnum
    _$experimentEventCreateRequestKindEnum_milestone =
    const ExperimentEventCreateRequestKindEnum._('milestone');

ExperimentEventCreateRequestKindEnum
    _$experimentEventCreateRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'observation':
      return _$experimentEventCreateRequestKindEnum_observation;
    case 'measurement':
      return _$experimentEventCreateRequestKindEnum_measurement;
    case 'milestone':
      return _$experimentEventCreateRequestKindEnum_milestone;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExperimentEventCreateRequestKindEnum>
    _$experimentEventCreateRequestKindEnumValues = BuiltSet<
        ExperimentEventCreateRequestKindEnum>(const <ExperimentEventCreateRequestKindEnum>[
  _$experimentEventCreateRequestKindEnum_observation,
  _$experimentEventCreateRequestKindEnum_measurement,
  _$experimentEventCreateRequestKindEnum_milestone,
]);

Serializer<ExperimentEventCreateRequestKindEnum>
    _$experimentEventCreateRequestKindEnumSerializer =
    _$ExperimentEventCreateRequestKindEnumSerializer();

class _$ExperimentEventCreateRequestKindEnumSerializer
    implements PrimitiveSerializer<ExperimentEventCreateRequestKindEnum> {
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
  final Iterable<Type> types = const <Type>[
    ExperimentEventCreateRequestKindEnum
  ];
  @override
  final String wireName = 'ExperimentEventCreateRequestKindEnum';

  @override
  Object serialize(
          Serializers serializers, ExperimentEventCreateRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExperimentEventCreateRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExperimentEventCreateRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ExperimentEventCreateRequest extends ExperimentEventCreateRequest {
  @override
  final String note;
  @override
  final int? atMs;
  @override
  final ExperimentEventCreateRequestKindEnum kind;
  @override
  final String? csrfToken;

  factory _$ExperimentEventCreateRequest(
          [void Function(ExperimentEventCreateRequestBuilder)? updates]) =>
      (ExperimentEventCreateRequestBuilder()..update(updates))._build();

  _$ExperimentEventCreateRequest._(
      {required this.note, this.atMs, required this.kind, this.csrfToken})
      : super._();
  @override
  ExperimentEventCreateRequest rebuild(
          void Function(ExperimentEventCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExperimentEventCreateRequestBuilder toBuilder() =>
      ExperimentEventCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExperimentEventCreateRequest &&
        note == other.note &&
        atMs == other.atMs &&
        kind == other.kind &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, atMs.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExperimentEventCreateRequest')
          ..add('note', note)
          ..add('atMs', atMs)
          ..add('kind', kind)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class ExperimentEventCreateRequestBuilder
    implements
        Builder<ExperimentEventCreateRequest,
            ExperimentEventCreateRequestBuilder>,
        CsrfBodyBuilder {
  _$ExperimentEventCreateRequest? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(covariant String? note) => _$this._note = note;

  int? _atMs;
  int? get atMs => _$this._atMs;
  set atMs(covariant int? atMs) => _$this._atMs = atMs;

  ExperimentEventCreateRequestKindEnum? _kind;
  ExperimentEventCreateRequestKindEnum? get kind => _$this._kind;
  set kind(covariant ExperimentEventCreateRequestKindEnum? kind) =>
      _$this._kind = kind;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  ExperimentEventCreateRequestBuilder() {
    ExperimentEventCreateRequest._defaults(this);
  }

  ExperimentEventCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _atMs = $v.atMs;
      _kind = $v.kind;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant ExperimentEventCreateRequest other) {
    _$v = other as _$ExperimentEventCreateRequest;
  }

  @override
  void update(void Function(ExperimentEventCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExperimentEventCreateRequest build() => _build();

  _$ExperimentEventCreateRequest _build() {
    final _$result = _$v ??
        _$ExperimentEventCreateRequest._(
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'ExperimentEventCreateRequest', 'note'),
          atMs: atMs,
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ExperimentEventCreateRequest', 'kind'),
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
