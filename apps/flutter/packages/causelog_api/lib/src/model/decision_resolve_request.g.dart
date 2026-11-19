// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_resolve_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DecisionResolveRequestStatusEnum
    _$decisionResolveRequestStatusEnum_decided =
    const DecisionResolveRequestStatusEnum._('decided');
const DecisionResolveRequestStatusEnum
    _$decisionResolveRequestStatusEnum_rejected =
    const DecisionResolveRequestStatusEnum._('rejected');

DecisionResolveRequestStatusEnum _$decisionResolveRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'decided':
      return _$decisionResolveRequestStatusEnum_decided;
    case 'rejected':
      return _$decisionResolveRequestStatusEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DecisionResolveRequestStatusEnum>
    _$decisionResolveRequestStatusEnumValues = BuiltSet<
        DecisionResolveRequestStatusEnum>(const <DecisionResolveRequestStatusEnum>[
  _$decisionResolveRequestStatusEnum_decided,
  _$decisionResolveRequestStatusEnum_rejected,
]);

Serializer<DecisionResolveRequestStatusEnum>
    _$decisionResolveRequestStatusEnumSerializer =
    _$DecisionResolveRequestStatusEnumSerializer();

class _$DecisionResolveRequestStatusEnumSerializer
    implements PrimitiveSerializer<DecisionResolveRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'decided': 'decided',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'decided': 'decided',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[DecisionResolveRequestStatusEnum];
  @override
  final String wireName = 'DecisionResolveRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DecisionResolveRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DecisionResolveRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DecisionResolveRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DecisionResolveRequest extends DecisionResolveRequest {
  @override
  final int? reviewAtMs;
  @override
  final String? decidedOption;
  @override
  final String rationale;
  @override
  final DecisionResolveRequestStatusEnum status;
  @override
  final String? csrfToken;

  factory _$DecisionResolveRequest(
          [void Function(DecisionResolveRequestBuilder)? updates]) =>
      (DecisionResolveRequestBuilder()..update(updates))._build();

  _$DecisionResolveRequest._(
      {this.reviewAtMs,
      this.decidedOption,
      required this.rationale,
      required this.status,
      this.csrfToken})
      : super._();
  @override
  DecisionResolveRequest rebuild(
          void Function(DecisionResolveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DecisionResolveRequestBuilder toBuilder() =>
      DecisionResolveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DecisionResolveRequest &&
        reviewAtMs == other.reviewAtMs &&
        decidedOption == other.decidedOption &&
        rationale == other.rationale &&
        status == other.status &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reviewAtMs.hashCode);
    _$hash = $jc(_$hash, decidedOption.hashCode);
    _$hash = $jc(_$hash, rationale.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DecisionResolveRequest')
          ..add('reviewAtMs', reviewAtMs)
          ..add('decidedOption', decidedOption)
          ..add('rationale', rationale)
          ..add('status', status)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class DecisionResolveRequestBuilder
    implements
        Builder<DecisionResolveRequest, DecisionResolveRequestBuilder>,
        CsrfBodyBuilder {
  _$DecisionResolveRequest? _$v;

  int? _reviewAtMs;
  int? get reviewAtMs => _$this._reviewAtMs;
  set reviewAtMs(covariant int? reviewAtMs) => _$this._reviewAtMs = reviewAtMs;

  String? _decidedOption;
  String? get decidedOption => _$this._decidedOption;
  set decidedOption(covariant String? decidedOption) =>
      _$this._decidedOption = decidedOption;

  String? _rationale;
  String? get rationale => _$this._rationale;
  set rationale(covariant String? rationale) => _$this._rationale = rationale;

  DecisionResolveRequestStatusEnum? _status;
  DecisionResolveRequestStatusEnum? get status => _$this._status;
  set status(covariant DecisionResolveRequestStatusEnum? status) =>
      _$this._status = status;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(covariant String? csrfToken) => _$this._csrfToken = csrfToken;

  DecisionResolveRequestBuilder() {
    DecisionResolveRequest._defaults(this);
  }

  DecisionResolveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reviewAtMs = $v.reviewAtMs;
      _decidedOption = $v.decidedOption;
      _rationale = $v.rationale;
      _status = $v.status;
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant DecisionResolveRequest other) {
    _$v = other as _$DecisionResolveRequest;
  }

  @override
  void update(void Function(DecisionResolveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DecisionResolveRequest build() => _build();

  _$DecisionResolveRequest _build() {
    final _$result = _$v ??
        _$DecisionResolveRequest._(
          reviewAtMs: reviewAtMs,
          decidedOption: decidedOption,
          rationale: BuiltValueNullFieldError.checkNotNull(
              rationale, r'DecisionResolveRequest', 'rationale'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'DecisionResolveRequest', 'status'),
          csrfToken: csrfToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
