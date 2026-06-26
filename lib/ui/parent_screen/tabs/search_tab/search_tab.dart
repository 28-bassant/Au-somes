import 'dart:math';
import 'package:flutter/material.dart';

import 'package:au_somes/l10n/app_localizations.dart';
import 'package:au_somes/utils/app_styles.dart';
import 'package:au_somes/utils/app_colors.dart';

import '../../../../models/Centers/center_model.dart';
import 'centers/center_data.dart';
import 'centers/center_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<CenterModel> allCenters = [];
  List<CenterModel>? filteredCenters;

  bool isLoading = true;

  // موقع ثابت (القاهرة)
  static const double userLatitude = 30.0444;
  static const double userLongitude = 31.2357;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final centers = await loadCenters();

      setState(() {
        allCenters = centers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading centers: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // ================== distance ==================
  double _toRadians(double degree) => degree * pi / 180;

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  // ================== FILTER ==================
  void filterNearest() {
    double shortest = double.infinity;
    CenterModel? nearest;

    for (var center in allCenters) {
      final distance = _calculateDistance(
        userLatitude,
        userLongitude,
        center.latitude,
        center.longitude,
      );

      if (distance < shortest) {
        shortest = distance;
        nearest = center;
      }
    }

    setState(() {
      filteredCenters = nearest != null ? [nearest] : [];
    });
  }

  // ================== SORT ==================
  void sortByNearest() {
    final sorted = List<CenterModel>.from(allCenters);

    sorted.sort((a, b) {
      final da = _calculateDistance(
        userLatitude,
        userLongitude,
        a.latitude,
        a.longitude,
      );

      final db = _calculateDistance(
        userLatitude,
        userLongitude,
        b.latitude,
        b.longitude,
      );

      return da.compareTo(db);
    });

    setState(() {
      filteredCenters = sorted;
    });
  }

  // ================== RESET ==================
  void resetCenters() {
    setState(() {
      filteredCenters = null;
    });
  }

  // ================== BUTTON STYLE ==================
  ButtonStyle _customButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.softBlue,
      elevation: 0,
      side: const BorderSide(color: AppColors.softBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return AppColors.softBlue;
        }
        return Colors.white;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return AppColors.softBlue;
      }),
      side: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return BorderSide.none;
        }
        return const BorderSide(color: AppColors.softBlue);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final centersToShow = filteredCenters ?? allCenters;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04),
        child: Column(
          children: [
            SizedBox(height: height * .08),

            Text(
              AppLocalizations.of(context)!.autism_centers,
              style: AppStyles.bold20BlackWithOpacity60,
            ),

            // ✅ تقليل المسافة هنا
            SizedBox(height: height * .009), // تغيير من .01 إلى .015

            // الأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: _customButtonStyle(),
                  onPressed: isLoading ? null : filterNearest,
                  icon: const Icon(Icons.filter_alt),
                  label: Text(AppLocalizations.of(context)!.nearest),
                ),
                ElevatedButton.icon(
                  style: _customButtonStyle(),
                  onPressed: isLoading ? null : sortByNearest,
                  icon: const Icon(Icons.sort),
                  label: Text(AppLocalizations.of(context)!.sort),
                ),
                ElevatedButton.icon(
                  style: _customButtonStyle(),
                  onPressed: isLoading ? null : resetCenters,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.reset),
                ),
              ],
            ),


            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : centersToShow.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.no_centers_found))
                  : ListView.builder(
                itemCount: centersToShow.length,
                itemBuilder: (context, index) {
                  return CenterWidget(
                    model: centersToShow[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
