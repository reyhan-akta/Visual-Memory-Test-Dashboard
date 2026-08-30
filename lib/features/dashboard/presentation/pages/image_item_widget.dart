import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:image_dashboard/features/dashboard/presentation/bloc/image-detail/image_detail_cubit.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/dashboard_cubit.dart';
import 'image_detail_page.dart';

class ImageItemWidget {
  static void showAddVideoDialog(
      BuildContext context,
      int index,
      String imageUrl, {
        String? imageId,
      }) {
    final cubit = context.read<DashboardGridCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderLine.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: BlocConsumer<DashboardGridCubit, DashboardGridState>(
                listener: (context, state) {
                  // Yükleme Başarılı: Dialog'u kapat ve Detay Sayfasına Yönlendir
                  if (state is VideoLoadedSuccessfuly) {
                    Navigator.pop(dialogContext);
                    _navigateToDetailPage(context, imageUrl, imageId, index);
                  }

                  // Hata Durumu
                  if (state is ErrorVideoLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is VideoLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.video_call_rounded,
                          size: 36,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Video Ekle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Bu görsele ait bir anlatım veya ipucu videosu eklemek ister misiniz?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                          context
                              .read<DashboardGridCubit>()
                              .pickAndUploadVideo(imageUrl);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLoading
                                  ? [
                                AppColors.secondarySurface,
                                AppColors.secondarySurface,
                              ]
                                  : [
                                AppColors.primaryAccent,
                                const Color(0xFF7C3AED),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isLoading
                                ? []
                                : [
                              BoxShadow(
                                color: AppColors.primaryAccent
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoading) ...[
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Video Yükleniyor...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ] else ...[
                                const Icon(
                                  Icons.upload_file_rounded,
                                  color: AppColors.primaryText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Video Seç ve Yükle',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Atla (Skip) Butonu
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          Navigator.pop(dialogContext);
                          _navigateToDetailPage(
                              context, imageUrl, imageId, index);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Atla (Şimdilik İstemiyorum)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isLoading
                                ? AppColors.secondaryText.withOpacity(0.4)
                                : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // 🟢 Düzeltilen Metod: Builder eklenerek alt widget ağacına ImageDetailCubit sağlandı
  static void _navigateToDetailPage(
      BuildContext context,
      String imageUrl,
      String? imageId,
      int index,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider(
          create: (context) => ImageDetailCubit(),
          child: Builder(
            builder: (innerContext) {
              return ImageDetailPage(
                imageUrl: imageUrl,
                imageName: imageId ?? 'Görsel ${index + 1}',
              );
            },
          ),
        ),
      ),
    );
  }
}