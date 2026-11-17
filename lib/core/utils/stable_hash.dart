/// Hash FNV-1a de 32 bits sin signo, idéntico a `hash(s)` del prototipo HTML:
/// ```js
/// let h = 2166136261;
/// for (let i = 0; i < s.length; i++) {
///   h ^= s.charCodeAt(i);
///   h = Math.imul(h, 16777619);
/// }
/// return h >>> 0;
/// ```
int stableHash(String s) {
  int h = 0x811c9dc5; // 2166136261
  for (int i = 0; i < s.length; i++) {
    h ^= s.codeUnitAt(i);
    h = (h * 0x01000193) & 0xFFFFFFFF; // Math.imul(h, 16777619) >>> 0
  }
  return h;
}
