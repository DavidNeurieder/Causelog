// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserRoleEnum _$userRoleEnum_admin = const UserRoleEnum._('admin');
const UserRoleEnum _$userRoleEnum_user = const UserRoleEnum._('user');

UserRoleEnum _$userRoleEnumValueOf(String name) {
  switch (name) {
    case 'admin':
      return _$userRoleEnum_admin;
    case 'user':
      return _$userRoleEnum_user;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserRoleEnum> _$userRoleEnumValues =
    BuiltSet<UserRoleEnum>(const <UserRoleEnum>[
  _$userRoleEnum_admin,
  _$userRoleEnum_user,
]);

Serializer<UserRoleEnum> _$userRoleEnumSerializer = _$UserRoleEnumSerializer();

class _$UserRoleEnumSerializer implements PrimitiveSerializer<UserRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'admin': 'admin',
    'user': 'user',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'admin': 'admin',
    'user': 'user',
  };

  @override
  final Iterable<Type> types = const <Type>[UserRoleEnum];
  @override
  final String wireName = 'UserRoleEnum';

  @override
  Object serialize(Serializers serializers, UserRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$User extends User {
  @override
  final String id;
  @override
  final String username;
  @override
  final String displayName;
  @override
  final UserRoleEnum role;
  @override
  final bool approved;
  @override
  final int createdAtMs;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (UserBuilder()..update(updates))._build();

  _$User._(
      {required this.id,
      required this.username,
      required this.displayName,
      required this.role,
      required this.approved,
      required this.createdAtMs})
      : super._();
  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        id == other.id &&
        username == other.username &&
        displayName == other.displayName &&
        role == other.role &&
        approved == other.approved &&
        createdAtMs == other.createdAtMs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, approved.hashCode);
    _$hash = $jc(_$hash, createdAtMs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'User')
          ..add('id', id)
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('role', role)
          ..add('approved', approved)
          ..add('createdAtMs', createdAtMs))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  UserRoleEnum? _role;
  UserRoleEnum? get role => _$this._role;
  set role(UserRoleEnum? role) => _$this._role = role;

  bool? _approved;
  bool? get approved => _$this._approved;
  set approved(bool? approved) => _$this._approved = approved;

  int? _createdAtMs;
  int? get createdAtMs => _$this._createdAtMs;
  set createdAtMs(int? createdAtMs) => _$this._createdAtMs = createdAtMs;

  UserBuilder() {
    User._defaults(this);
  }

  UserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _displayName = $v.displayName;
      _role = $v.role;
      _approved = $v.approved;
      _createdAtMs = $v.createdAtMs;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  User build() => _build();

  _$User _build() {
    final _$result = _$v ??
        _$User._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'User', 'id'),
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'User', 'username'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'User', 'displayName'),
          role: BuiltValueNullFieldError.checkNotNull(role, r'User', 'role'),
          approved: BuiltValueNullFieldError.checkNotNull(
              approved, r'User', 'approved'),
          createdAtMs: BuiltValueNullFieldError.checkNotNull(
              createdAtMs, r'User', 'createdAtMs'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
