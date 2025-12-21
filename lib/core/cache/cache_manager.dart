/// In-memory cache manager for performance
class CacheManager {
  final _cache = <String, CachedItem>{};
  final Duration _defaultDuration = const Duration(minutes: 5);
  
  /// Get cached item
  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    if (DateTime.now().difference(item.timestamp) > item.duration) {
      _cache.remove(key);
      return null;
    }
    
    return item.data as T;
  }
  
  /// Set cached item
  void set<T>(String key, T data, {Duration? duration}) {
    _cache[key] = CachedItem(
      data: data,
      timestamp: DateTime.now(),
      duration: duration ?? _defaultDuration,
    );
  }
  
  /// Clear specific cache
  void clear(String key) {
    _cache.remove(key);
  }
  
  /// Clear all cache
  void clearAll() {
    _cache.clear();
  }
  
  /// Check if key exists and is valid
  bool has(String key) {
    return get(key) != null;
  }
}

/// Cached item model
class CachedItem<T> {
  final T data;
  final DateTime timestamp;
  final Duration duration;
  
  CachedItem({
    required this.data,
    required this.timestamp,
    required this.duration,
  });
}



