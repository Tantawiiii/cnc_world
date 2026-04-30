import 'package:geolocator/geolocator.dart';

import '../di/inject.dart' as di;
import '../errors/session_unauthorized_exception.dart';
import '../network/api_service.dart';
import '../utils/location_distance.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/sellers/data/models/seller_models.dart';
import '../../features/sellers/data/repositories/seller_repository.dart';
import 'storage_service.dart';

/// Runs after splash when a token exists: validates session, syncs GPS, finds nearest seller.
class PostSplashSessionService {
  final ProfileRepository _profileRepository;
  final SellerRepository _sellerRepository;
  final ApiService _apiService;
  final StorageService _storageService;

  PostSplashSessionService({
    ProfileRepository? profileRepository,
    SellerRepository? sellerRepository,
    ApiService? apiService,
    StorageService? storageService,
  })  : _profileRepository = profileRepository ?? ProfileRepository(),
        _sellerRepository = sellerRepository ?? SellerRepository(),
        _apiService = apiService ?? di.sl<ApiService>(),
        _storageService = storageService ?? di.sl<StorageService>();

  /// Returns `true` if the user should go to home, `false` if session is invalid (cleared).
  Future<bool> validateTokenSyncLocationAndNearestSeller() async {
    try {
      var profileResponse = await _profileRepository.checkAuth();
      await _storageService.saveUserData(profileResponse.data.toStorageJson());

      Position? position;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
              ),
            );
          }
        }
      } catch (_) {
        position = null;
      }

      if (position != null) {
        try {
          await _profileRepository.updateLocation(
            lat: position.latitude.toString(),
            lng: position.longitude.toString(),
          );
          profileResponse = await _profileRepository.checkAuth();
          await _storageService.saveUserData(
            profileResponse.data.toStorageJson(),
          );
        } catch (_) {}
      }

      final user = profileResponse.data;
      final refLat = position?.latitude ??
          double.tryParse(user.lat?.trim() ?? '');
      final refLng = position?.longitude ??
          double.tryParse(user.lng?.trim() ?? '');

      if (refLat != null && refLng != null) {
        await _computeAndCacheNearestSeller(
          userLat: refLat,
          userLng: refLng,
          excludeUserId: user.id,
        );
      } else {
        await _storageService.clearNearestSeller();
      }

      return true;
    } on SessionUnauthorizedException {
      await _storageService.clearAll();
      _apiService.clearAuthToken();
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<void> _computeAndCacheNearestSeller({
    required double userLat,
    required double userLng,
    required int excludeUserId,
  }) async {
    final sellers = <Seller>[];
    var page = 1;
    while (true) {
      final res = await _sellerRepository.getSellers(page: page);
      sellers.addAll(res.data);
      final last = res.meta?.lastPage ?? 1;
      if (page >= last || res.data.isEmpty) break;
      page++;
    }

    Seller? best;
    double? bestKm;

    for (final s in sellers) {
      if (s.id == excludeUserId) continue;
      final slat = double.tryParse(s.lat?.trim() ?? '');
      final slng = double.tryParse(s.lng?.trim() ?? '');
      if (slat == null || slng == null) continue;

      final km = haversineDistanceKm(userLat, userLng, slat, slng);
      final prev = bestKm;
      if (prev == null || km < prev) {
        bestKm = km;
        best = s;
      }
    }

    final resolvedKm = bestKm;
    if (best != null && resolvedKm != null) {
      await _storageService.saveNearestSeller(
        id: best.id,
        name: best.name,
        distanceKm: resolvedKm,
      );
    } else {
      await _storageService.clearNearestSeller();
    }
  }
}
