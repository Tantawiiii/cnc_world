import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_texts.dart';
import '../../../../core/localization/app_localizations.dart';

class PickedMapLocation {
  final double latitude;
  final double longitude;
  final String? addressLabel;

  const PickedMapLocation({
    required this.latitude,
    required this.longitude,
    this.addressLabel,
  });
}

/// Map centered on Greater Cairo by default; tap to place marker, confirm to return [PickedMapLocation].
class PickLocationMapScreen extends StatefulWidget {
  final LatLng? initialTarget;

  const PickLocationMapScreen({super.key, this.initialTarget});

  @override
  State<PickLocationMapScreen> createState() => _PickLocationMapScreenState();
}

class _PickLocationMapScreenState extends State<PickLocationMapScreen> {
  static const LatLng _defaultCairo = LatLng(30.0444, 31.2357);

  late LatLng _markerPosition;
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _markerPosition = widget.initialTarget ?? _defaultCairo;
  }

  Future<String?> _reverseGeocode(LatLng p) async {
    try {
      final list = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (list.isEmpty) return null;
      final pm = list.first;
      final parts = <String>[
        pm.street ?? '',
        pm.subLocality ?? '',
        pm.locality ?? '',
        pm.administrativeArea ?? '',
        pm.country ?? '',
      ].where((e) => e.trim().isNotEmpty).toList();
      if (parts.isEmpty) return null;
      return parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirm() async {
    setState(() => _loadingAddress = true);
    final label = await _reverseGeocode(_markerPosition);
    if (!mounted) return;
    setState(() => _loadingAddress = false);
    Navigator.of(context).pop(
      PickedMapLocation(
        latitude: _markerPosition.latitude,
        longitude: _markerPosition.longitude,
        addressLabel: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.pickWorkshopLocation ?? AppTexts.pickWorkshopLocation,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _markerPosition,
              zoom: 14,
            ),
            onTap: (pos) => setState(() => _markerPosition = pos),
            markers: {
              Marker(
                markerId: const MarkerId('pick'),
                position: _markerPosition,
                draggable: true,
                onDragEnd: (pos) => setState(() => _markerPosition = pos),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 24.h,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: _loadingAddress ? null : _confirm,
                      child: _loadingAddress
                          ? SizedBox(
                              height: 22.h,
                              width: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : Text(
                              localizations?.confirmLocation ??
                                  AppTexts.confirmLocation,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
