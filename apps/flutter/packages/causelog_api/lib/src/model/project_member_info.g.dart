// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_member_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProjectMemberInfoRoleEnum _$projectMemberInfoRoleEnum_owner =
    const ProjectMemberInfoRoleEnum._('owner');
const ProjectMemberInfoRoleEnum _$projectMemberInfoRoleEnum_member =
    const ProjectMemberInfoRoleEnum._('member');

ProjectMemberInfoRoleEnum _$projectMemberInfoRoleEnumValueOf(String name) {
  switch (name) {
    case 'owner':
      return _$projectMemberInfoRoleEnum_owner;
    case 'member':
      return _$projectMemberInfoRoleEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProjectMemberInfoRoleEnum> _$projectMemberInfoRoleEnumValues =
    BuiltSet<ProjectMemberInfoRoleEnum>(const <ProjectMemberInfoRoleEnum>[
  _$projectMemberInfoRoleEnum_owner,
  _$projectMemberInfoRoleEnum_member,
]);

Serializer<ProjectMemberInfoRoleEnum> _$projectMemberInfoRoleEnumSerializer =
    _$ProjectMemberInfoRoleEnumSerializer();

class _$ProjectMemberInfoRoleEnumSerializer
    implements PrimitiveSerializer<ProjectMemberInfoRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'owner': 'owner',
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'owner': 'owner',
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[ProjectMemberInfoRoleEnum];
  @override
  final String wireName = 'ProjectMemberInfoRoleEnum';

  @override
  Object serialize(Serializers serializers, ProjectMemberInfoRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProjectMemberInfoRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProjectMemberInfoRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProjectMemberInfo extends ProjectMemberInfo {
  @override
  final User user;
  @override
  final ProjectMemberInfoRoleEnum role;

  factory _$ProjectMemberInfo(
          [void Function(ProjectMemberInfoBuilder)? updates]) =>
      (ProjectMemberInfoBuilder()..update(updates))._build();

  _$ProjectMemberInfo._({required this.user, required this.role}) : super._();
  @override
  ProjectMemberInfo rebuild(void Function(ProjectMemberInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProjectMemberInfoBuilder toBuilder() =>
      ProjectMemberInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProjectMemberInfo &&
        user == other.user &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProjectMemberInfo')
          ..add('user', user)
          ..add('role', role))
        .toString();
  }
}

class ProjectMemberInfoBuilder
    implements Builder<ProjectMemberInfo, ProjectMemberInfoBuilder> {
  _$ProjectMemberInfo? _$v;

  UserBuilder? _user;
  UserBuilder get user => _$this._user ??= UserBuilder();
  set user(UserBuilder? user) => _$this._user = user;

  ProjectMemberInfoRoleEnum? _role;
  ProjectMemberInfoRoleEnum? get role => _$this._role;
  set role(ProjectMemberInfoRoleEnum? role) => _$this._role = role;

  ProjectMemberInfoBuilder() {
    ProjectMemberInfo._defaults(this);
  }

  ProjectMemberInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProjectMemberInfo other) {
    _$v = other as _$ProjectMemberInfo;
  }

  @override
  void update(void Function(ProjectMemberInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProjectMemberInfo build() => _build();

  _$ProjectMemberInfo _build() {
    _$ProjectMemberInfo _$result;
    try {
      _$result = _$v ??
          _$ProjectMemberInfo._(
            user: user.build(),
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'ProjectMemberInfo', 'role'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProjectMemberInfo', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
