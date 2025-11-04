/// A simple generic wrapper for optional values, similar to Rust's `Option` or Swift's `Optional`.
///
/// Use `Opt<T>(value)` to create an optional value that is present, and `Opt<T>.none()`
/// to create one that is absent.
class Opt<T> {
  final T? _value;
  final bool _isPresent;

  /// Creates an optional value that is present.
  const Opt(this._value) : _isPresent = true;

  /// Creates an optional value that is absent.
  const Opt.none()
      : _value = null,
        _isPresent = false;

  /// Returns `true` if the value is present.
  bool get isPresent => _isPresent;

  /// Returns `true` if the value is absent.
  bool get isAbsent => !_isPresent;

  /// Returns the value if present, otherwise throws a [StateError].
  T get value {
    if (_isPresent) {
      return _value as T;
    }
    throw StateError('Opt value is not present');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Opt<T> &&
          runtimeType == other.runtimeType &&
          _value == other._value &&
          _isPresent == other._isPresent;

  @override
  int get hashCode => _value.hashCode ^ _isPresent.hashCode;

  @override
  String toString() {
    if (_isPresent) {
      return 'Opt(value: $_value)';
    }
    return 'Opt.none()';
  }
}