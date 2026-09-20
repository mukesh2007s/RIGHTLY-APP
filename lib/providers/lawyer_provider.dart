import 'package:flutter/foundation.dart';
import '../models/lawyer_model.dart';
import '../services/lawyer_service.dart';

/// Lawyer Provider — state management for Lawyer Connect module
class LawyerProvider extends ChangeNotifier {
  final LawyerService _lawyerService = LawyerService();

  // ═══════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════

  List<LawyerModel> _lawyers = [];
  List<LawyerModel> get lawyers => _lawyers;

  List<LawyerModel> _filteredLawyers = [];
  List<LawyerModel> get filteredLawyers =>
      _filteredLawyers.isNotEmpty ? _filteredLawyers : _lawyers;

  LawyerModel? _selectedLawyer;
  LawyerModel? get selectedLawyer => _selectedLawyer;

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  List<String> _specializations = [];
  List<String> get specializations => _specializations;

  String? _activeFilter;
  String? get activeFilter => _activeFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadLawyers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lawyers = await _lawyerService.getAllLawyers();
      _specializations = await _lawyerService.getSpecializations();
      _filteredLawyers = [];
      _activeFilter = null;
      _searchQuery = '';
    } catch (e) {
      _error = 'Failed to load lawyers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH & FILTER
  // ═══════════════════════════════════════════════════════════════

  Future<void> searchLawyers(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _filteredLawyers = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredLawyers = await _lawyerService.searchLawyers(query);
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterBySpecialization(String? specialization) async {
    _activeFilter = specialization;

    if (specialization == null) {
      _filteredLawyers = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredLawyers = await _lawyerService.filterBySpecialization(specialization);
    } catch (e) {
      _error = 'Filter failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _filteredLawyers = [];
    _activeFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // LAWYER DETAIL
  // ═══════════════════════════════════════════════════════════════

  Future<void> selectLawyer(String lawyerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedLawyer = await _lawyerService.getLawyerById(lawyerId);
      _reviews = await _lawyerService.getReviews(lawyerId);
    } catch (e) {
      _error = 'Failed to load lawyer details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedLawyer = null;
    _reviews = [];
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // REVIEWS
  // ═══════════════════════════════════════════════════════════════

  Future<bool> submitReview({
    required String lawyerId,
    required String userId,
    required String userName,
    required double rating,
    required String reviewText,
  }) async {
    try {
      final hasReviewed = await _lawyerService.hasUserReviewed(lawyerId, userId);
      if (hasReviewed) {
        _error = 'You have already reviewed this lawyer';
        notifyListeners();
        return false;
      }

      final review = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lawyerId: lawyerId,
        userId: userId,
        userName: userName,
        rating: rating,
        reviewText: reviewText,
        createdAt: DateTime.now(),
      );

      await _lawyerService.addReview(review);

      // Refresh data
      _reviews = await _lawyerService.getReviews(lawyerId);
      _selectedLawyer = await _lawyerService.getLawyerById(lawyerId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit review: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
