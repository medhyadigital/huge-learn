import 'dart:convert';
import '../storage/local_storage.dart';

/// Token types supported
enum TokenType {
  jwt,
  oauth,
  session,
  unknown,
}

/// Token metadata
class TokenMetadata {
  final TokenType type;
  final DateTime? expiresAt;
  final DateTime issuedAt;
  final Map<String, dynamic>? payload;
  
  TokenMetadata({
    required this.type,
    this.expiresAt,
    required this.issuedAt,
    this.payload,
  });
  
  /// Check if token is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Check if token will expire soon (within 5 minutes)
  bool get willExpireSoon {
    if (expiresAt == null) return false;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return expiresAt!.isBefore(fiveMinutesFromNow);
  }
  
  /// Time until expiration in seconds
  int? get secondsUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inSeconds;
  }
}

/// Token manager for detecting and managing tokens
class TokenManager {
  final LocalStorage _localStorage;
  TokenMetadata? _cachedMetadata;
  
  TokenManager(this._localStorage);
  
  /// Detect token type and extract metadata
  TokenMetadata? detectTokenType(String token) {
    // Check if JWT
    if (_isJWT(token)) {
      return _parseJWT(token);
    }
    
    // Check if OAuth token (usually has specific format)
    if (_isOAuth(token)) {
      return TokenMetadata(
        type: TokenType.oauth,
        issuedAt: DateTime.now(),
      );
    }
    
    // Assume session token
    return TokenMetadata(
      type: TokenType.session,
      issuedAt: DateTime.now(),
    );
  }
  
  /// Check if token is JWT format
  bool _isJWT(String token) {
    final parts = token.split('.');
    return parts.length == 3;
  }
  
  /// Check if token is OAuth format
  bool _isOAuth(String token) {
    // OAuth tokens typically have specific prefix or format
    // This is a simplified check
    return token.startsWith('oauth_') || 
           token.startsWith('bearer_') ||
           (token.length > 40 && !token.contains('.'));
  }
  
  /// Parse JWT token
  TokenMetadata? _parseJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      // Decode payload (second part)
      final payload = _decodeBase64(parts[1]);
      final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
      
      // Extract expiration time
      final exp = payloadMap['exp'] as int?;
      final iat = payloadMap['iat'] as int?;
      
      return TokenMetadata(
        type: TokenType.jwt,
        expiresAt: exp != null 
            ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
            : null,
        issuedAt: iat != null
            ? DateTime.fromMillisecondsSinceEpoch(iat * 1000)
            : DateTime.now(),
        payload: payloadMap,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Decode base64 URL-safe string
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    
    return utf8.decode(base64Url.decode(output));
  }
  
  /// Get current token metadata
  TokenMetadata? getCurrentTokenMetadata() {
    if (_cachedMetadata != null) {
      return _cachedMetadata;
    }
    
    final token = _localStorage.getAuthToken();
    if (token == null) return null;
    
    _cachedMetadata = detectTokenType(token);
    return _cachedMetadata;
  }
  
  /// Clear cached metadata
  void clearCache() {
    _cachedMetadata = null;
  }
  
  /// Check if current token needs refresh
  bool needsRefresh() {
    final metadata = getCurrentTokenMetadata();
    if (metadata == null) return true;
    
    return metadata.isExpired || metadata.willExpireSoon;
  }
  
  /// Get user ID from token (for JWT)
  String? getUserIdFromToken() {
    final metadata = getCurrentTokenMetadata();
    if (metadata?.type != TokenType.jwt) return null;
    
    return metadata?.payload?['sub'] as String? ?? 
           metadata?.payload?['user_id'] as String? ??
           metadata?.payload?['userId'] as String?;
  }
}

