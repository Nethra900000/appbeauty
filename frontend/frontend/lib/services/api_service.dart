import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  String _baseUrl = kDebugMode
      ? (defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000'
          : 'http://localhost:8000')
      : 'https://facial-face.onrender.com';
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _currentScan;
  List<dynamic> _savedLooks = [];
  List<dynamic> _patientsList = [];

  // Recommendations cache
  Map<String, dynamic>? _makeupRecs;
  Map<String, dynamic>? _skincareRecs;
  Map<String, dynamic>? _hairstyleRecs;
  Map<String, dynamic>? _outfitRecs;

  // Getters
  String get baseUrl => _baseUrl;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get currentScan => _currentScan;
  List<dynamic> get savedLooks => _savedLooks;
  List<dynamic> get patientsList => _patientsList;

  Map<String, dynamic>? get makeupRecs => _makeupRecs;
  Map<String, dynamic>? get skincareRecs => _skincareRecs;
  Map<String, dynamic>? get hairstyleRecs => _hairstyleRecs;
  Map<String, dynamic>? get outfitRecs => _outfitRecs;

  // Setters
  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentScan = null;
    _savedLooks = [];
    _patientsList = [];
    _makeupRecs = null;
    _skincareRecs = null;
    _hairstyleRecs = null;
    _outfitRecs = null;
    notifyListeners();
  }

  // API Call helper to wrap headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Register / Signup
  Future<String?> register(String username, String email, String password, {String? medicalLicense}) async {
    try {
      // 1. Try FastAPI Form signup endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        body: {
          'name': username,
          'license': medicalLicense ?? 'LIC-$username',
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return null; // Success
        } else {
          return data['message'] ?? 'Registration failed';
        }
      }

      // 2. Fallback to JSON endpoint if FastAPI form not found
      final jsonResp = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(jsonResp.body);
      if (jsonResp.statusCode == 201 || data['success'] == true) {
        return null;
      } else {
        return data['error'] ?? data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      return 'Error connecting to server: $e';
    }
  }

  // Login
  Future<String?> login(String usernameOrEmail, String password) async {
    try {
      // 1. Try FastAPI Form login endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        body: {
          'email': usernameOrEmail,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _currentUser = {
            'id': data['id'],
            'username': data['name'] ?? usernameOrEmail,
            'name': data['name'],
            'email': data['email'],
            'medical_license': data['medical_license'],
            'phone': data['phone'],
            'clinic': data['clinic'],
          };
          notifyListeners();
          await fetchSavedLooks();
          return null; // Success
        } else {
          // If login with email directly failed, try username fallback on JSON endpoint
        }
      }

      // 2. Fallback JSON endpoint
      final jsonResp = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'username': usernameOrEmail,
          'password': password,
        }),
      );

      final data = jsonDecode(jsonResp.body);
      if (jsonResp.statusCode == 200 && data['user'] != null) {
        _currentUser = data['user'];
        notifyListeners();
        await fetchSavedLooks();
        await fetchAllRecommendations();
        return null;
      }

      final errorMsg = jsonDecode(response.body)['message'] ?? 'Invalid Email or Password';
      return errorMsg;
    } catch (e) {
      return 'Error connecting to server: $e';
    }
  }

  // Update Profile preferences
  Future<String?> updateProfilePreferences({
    required String skinType,
    required String skinTone,
    required String faceShape,
    required String concerns,
  }) async {
    try {
      final userId = _currentUser?['id'] ?? 1;
      final response = await http.put(
        Uri.parse('$_baseUrl/api/profile?user_id=$userId'),
        headers: _headers,
        body: jsonEncode({
          'skin_type': skinType,
          'skin_tone': skinTone,
          'face_shape': faceShape,
          'skin_concerns': concerns,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (_currentUser != null) {
          _currentUser!['profile'] = data['profile'];
        }
        notifyListeners();
        await fetchAllRecommendations();
        return null;
      } else {
        return data['error'] ?? 'Profile update failed';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Trigger Upload Scan (which does a mock generation on backend db)
  Future<String?> triggerScanUpload() async {
    try {
      final userId = _currentUser?['id'] ?? 1;
      final response = await http.post(
        Uri.parse('$_baseUrl/api/scan/upload'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _currentScan = data;
        
        // Update local profile with the new scanned traits
        if (_currentUser != null && _currentUser!['profile'] != null) {
          _currentUser!['profile']['skin_type'] = data['skin_type'];
          _currentUser!['profile']['skin_tone'] = data['skin_tone'];
          _currentUser!['profile']['face_shape'] = data['face_shape'];
        }
        
        notifyListeners();
        // Load recommendations matching the fresh scan traits
        await fetchAllRecommendations();
        return null; // Success
      } else {
        return data['error'] ?? 'Face scan parsing failed';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

  // Fetch all recommendations
  Future<void> fetchAllRecommendations() async {
    final tone = _currentScan?['skin_tone'] ?? _currentUser?['profile']?['skin_tone'] ?? 'Warm Beige';
    final type = _currentScan?['skin_type'] ?? _currentUser?['profile']?['skin_type'] ?? 'Combination';
    final shape = _currentScan?['face_shape'] ?? _currentUser?['profile']?['face_shape'] ?? 'Oval';

    await Future.wait([
      getMakeupRecommendations(tone),
      getSkincareRecommendations(type),
      getHairstyleRecommendations(shape),
      getOutfitRecommendations(tone),
    ]);
  }

  // Recommendations: Makeup
  Future<void> getMakeupRecommendations(String skinTone) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recommendations/makeup?skin_tone=$skinTone'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _makeupRecs = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching makeup recs: $e');
    }
  }

  // Recommendations: Skincare
  Future<void> getSkincareRecommendations(String skinType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recommendations/skincare?skin_type=$skinType'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _skincareRecs = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching skincare recs: $e');
    }
  }

  // Recommendations: Hairstyle
  Future<void> getHairstyleRecommendations(String faceShape) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recommendations/hairstyle?face_shape=$faceShape'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _hairstyleRecs = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching hairstyle recs: $e');
    }
  }

  // Recommendations: Outfit
  Future<void> getOutfitRecommendations(String skinTone) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/recommendations/outfit?skin_tone=$skinTone'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _outfitRecs = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching outfit recs: $e');
    }
  }

  // Fetch Saved Looks
  Future<void> fetchSavedLooks() async {
    try {
      final userId = _currentUser?['id'] ?? 1;
      final response = await http.get(
        Uri.parse('$_baseUrl/api/saved-looks?user_id=$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _savedLooks = data['saved_looks'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching saved looks: $e');
    }
  }

  // Save Look
  Future<String?> saveLook({
    required String category,
    required String title,
    required String description,
    required Map<String, dynamic> details,
  }) async {
    try {
      final userId = _currentUser?['id'] ?? 1;
      final response = await http.post(
        Uri.parse('$_baseUrl/api/saved-looks?user_id=$userId'),
        headers: _headers,
        body: jsonEncode({
          'category': category,
          'title': title,
          'description': description,
          'details_json': jsonEncode(details),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await fetchSavedLooks();
        return null; // Success
      } else {
        return data['error'] ?? 'Could not save look';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Delete Look
  Future<String?> deleteLook(int lookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/saved-looks/$lookId'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await fetchSavedLooks();
        return null; // Success
      } else {
        return data['error'] ?? 'Could not delete look';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ==========================================
  // PATIENT & CASE ANALYSIS ENDPOINTS
  // ==========================================

  // Fetch Patients List
  Future<List<dynamic>> fetchPatients({String? search}) async {
    try {
      final uri = Uri.parse('$_baseUrl/patients').replace(
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
      );
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        _patientsList = jsonDecode(response.body);
        notifyListeners();
        return _patientsList;
      }
    } catch (e) {
      debugPrint('Error fetching patients: $e');
    }
    return [];
  }

  // Create Patient
  Future<String?> createPatient({
    required String id,
    required String name,
    required int age,
    required String gender,
    String? guardian,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/patients'),
        headers: _headers,
        body: jsonEncode({
          'id': id,
          'name': name,
          'age': age,
          'gender': gender,
          'guardian': guardian,
          'phone': phone,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPatients();
        return null; // Success
      } else {
        final data = jsonDecode(response.body);
        return data['detail'] ?? 'Failed to create patient';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}

