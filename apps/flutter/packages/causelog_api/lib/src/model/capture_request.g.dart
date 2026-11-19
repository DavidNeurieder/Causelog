// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CaptureRequestKindEnum _$captureRequestKindEnum_note =
    const CaptureRequestKindEnum._('note');
const CaptureRequestKindEnum _$captureRequestKindEnum_observation =
    const CaptureRequestKindEnum._('observation');
const CaptureRequestKindEnum _$captureRequestKindEnum_decisionDraft =
    const CaptureRequestKindEnum._('decisionDraft');

CaptureRequestKindEnum _$captureRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'note':
      return _$captureRequestKindEnum_note;
    case 'observation':
      return _$captureRequestKindEnum_observation;
    case 'decisionDraft':
      return _$captureRequestKindEnum_decisionDraft;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CaptureRequestKindEnum> _$captureRequestKindEnumValues =
    BuiltSet<CaptureRequestKindEnum>(const <CaptureRequestKindEnum>[
  _$captureRequestKindEnum_note,
  _$captureRequestKindEnum_observation,
  _$captureRequestKindEnum_decisionDraft,
]);

Serializer<CaptureRequestKindEnum> _$captureRequestKindEnumSerializer =
    _$CaptureRequestKindEnumSerializer();

class _$CaptureRequestKindEnumSerializer
    implements PrimitiveSerializer<CaptureRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'note': 'note',
    'observation': 'observation',
    'decisionDraft': 'decision_draft',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'note': 'note',
    'observation': 'observation',
    'decision_draft': 'decisionDraft',
  };

  @override
  final Iterable<Type> types = const <Type>[CaptureRequestKindEnum];
  @override
  final String wireName = 'CaptureRequestKindEnum';

  @override
  Object serialize(Serializers serializers, CaptureRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CaptureRequestKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CaptureRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CaptureRequest extends CaptureRequest {
  @override
  final CaptureRequestKindEnum kind;
  @override
  final String? experimentId;
  @override
  final String title;
  @override
  final String? body;
  @override
  final String projectId;
  @override
  final String? csrfToken;

  factory _$CaptureRequest([void Function(CaptureRequestBuilder)? updates]) =>
      (CaptureRequestBuilder()..update(updates))._build();

  _$CaptureRequest._(
      {required this.kind,
      this.experimentId,
      required this.title,
      this.body,
      required this.projectId,
      this.csrfToken})
      : super._();
  @override
  CaptureRequest rebuild(void Function(CaptureRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CaptureRequestBuilder toBuilder() => CaptureRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CaptureRequest &&
        kind == other.kind &&
        experimentId == other.experimentId &&
        title == other.title &&
        body == other.body &&
        projectId == other.projectId &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, experimentId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, projectId.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CaptureRequest')
          ..add('kind', kind)
          ..add('experimentId', experimentId)
          ..add('title', title)
          ..add('body', body)
          ..add('projectId', projectId)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class CaptureRequestBuilder
    implements Builder<CaptureRequest, CaptureRequestBuilder>, CsrfBodyBuilder {
  _$CaptureRequest? _$v;

  CaptureRequestKindEnum? _kind;
  CaptureRequestKindEnum? get kind => _$this._kind;
  set kind(covariant CaptureRequestKindEnum? kind) => _$this._kind = kind;

  String? _experimentId;
  String? get experimentId => _$this._experimentId;
  set experimentId(covariant String? experimentId) =>
      _$this._experimentId = experimentId;

  String? _title;
  String? get title => _$this._title;
  set title(covariant String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(covariant String? body) => _$this._body = body;

  String? _projectId;
  String? get projectId => _$this._projectId;
  set projectId(covariant String? projectId) => _$this._projectId = projectId;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  CaptureRequestBuilder() {
    CaptureRequest._defaults(this);
  }

  CaptureRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _experimentId = $v.experimentId;
      _title = $v.title;
      _body = $v.body;
      _projectId = $v.projectId;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant CaptureRequest other) {
    _$v = other as _$CaptureRequest;
  }

  @override
  void update(void Function(CaptureRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CaptureRequest build() => _build();

  _$CaptureRequest _build() {
    final _$result = _$v ??
        _$CaptureRequest._(
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'CaptureRequest', 'kind'),
          experimentId: experimentId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CaptureRequest', 'title'),
          body: body,
          projectId: BuiltValueNullFieldError.checkNotNull(
              projectId, r'CaptureRequest', 'projectId'),
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
