import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/main.dart';
import '../bloc/image-detail/image_detail_cubit.dart';
import '../bloc/image-detail/image_detail_state.dart';
import '../widgets/figma_ai_loading_widget.dart';

class ImageDetailPage extends StatelessWidget {
  final String imageUrl;
  final String imageName;
  final String imageSize;
  final String imageDate;
  final String? imageId;
  final String difficultyLevel;
  final List<String> tags;

  const ImageDetailPage({
    super.key,
    required this.imageUrl,
    required this.imageName,
    required this.difficultyLevel,
    this.imageSize = '3.2 MB',
    this.imageDate = 'Aug 7, 2026',
    this.imageId,
    this.tags = const ['#nature', '#landscape'],
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (imageId != null) {
        final cubit = context.read<ImageDetailCubit>();

        // 1. Önce Cloud kontrolü yapılır
        await cubit.checkCloudExists(difficultyLevel, imageId!);

        // 2. Eğer veriler Cloud'da ZATEN VARSA (state CloudUploadSuccessState olduysa)
        // önbellek yüklemesi yapılmaz; var değilse önbellekten okunur.
        if (cubit.state is! CloudUploadSuccessState) {
          cubit.checkAndLoadFromCache(imageId);
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF161926),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resim Detayı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              imageName,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white38),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white38),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOL PANEL
            Expanded(flex: 5, child: _buildLeftPanel(context)),
            const SizedBox(width: 24),
            // SAĞ PANEL
            Expanded(flex: 5, child: _buildRightTerminalPanel(context)),
          ],
        ),
      ),
    );
  }

  // SOL PANEL
  Widget _buildLeftPanel(BuildContext context) {
    return BlocBuilder<ImageDetailCubit, ImageDetailState>(
      builder: (context, state) {
        final isGenerating = state is JsonResponseLoading;
        final isGenerated = state is JsonResponseLoaded;
        final isUploading = state is CloudUploadingState;
        final isUploaded = state is CloudUploadSuccessState;

        // JSON üretilmiş, yükleniyor veya cloud'da mevcutsa cloud butonu görünür kalır
        final shouldShowCloudButton = isGenerated || isUploading || isUploaded;

        // Generate butonunun kilitli olma durumu
        final isGenerateDisabled = isGenerating || isGenerated || isUploaded;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ana Resim Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: 380,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 380,
                      color: const Color(0xFF161926),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Meta Bilgiler & Etiketler
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121520),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    _buildMetaItem('DOSYA ADI', imageName),
                    const SizedBox(width: 20),
                    _buildMetaItem('BOYUT', imageSize),
                    const SizedBox(width: 20),
                    _buildMetaItem('TARİH', imageDate),
                    const Spacer(),
                    ...tags.map(
                          (tag) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _buildTag(tag),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Generate Butonu (Gradient)
              Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFFA855F7),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isGenerateDisabled
                      ? null
                      : () async {
                    if (imageId != null) {
                      final cachedData = appStorage.read(
                        'prompt_json_response_$imageId',
                      );

                      if (cachedData != null) {
                        context
                            .read<ImageDetailCubit>()
                            .checkAndLoadFromCache(imageId);
                      } else {
                        context
                            .read<ImageDetailCubit>()
                            .sendPromptRequest(
                          imageId!,
                          imageUrl,
                          difficultyLevel,
                        );
                      }
                    }
                  },
                  child: Opacity(
                    opacity: isGenerateDisabled ? 0.5 : 1.0,
                    child: isGenerating
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (isGenerated || isUploaded)
                              ? 'Questions Generated'
                              : 'Generate Questions & Choices',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Cloud'a Yükle / Cloud Durum Butonu
              if (shouldShowCloudButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2229),
                      disabledForegroundColor: const Color(0xFF2ED573),
                      side: BorderSide(
                        color: isUploaded
                            ? const Color(0xFF2ED573)
                            : const Color(0xFF00B4D8),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (isUploading || isUploaded)
                        ? null
                        : () {
                      String? rawJson;
                      if (state is JsonResponseLoaded) {
                        rawJson = state.rowJson;
                      }

                      if (rawJson != null && imageId != null) {
                        context.read<ImageDetailCubit>().decodeJsonData(
                          rawJson,
                          difficultyLevel,
                          imageId!,
                        );
                      }
                    },
                    child: isUploading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00B4D8),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUploaded
                              ? Icons.check_circle_outline
                              : Icons.cloud_upload_outlined,
                          color: isUploaded
                              ? const Color(0xFF2ED573)
                              : const Color(0xFF00B4D8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUploaded
                              ? 'Cloud\'da Mevcut'
                              : 'Cloud\'a Yükle',
                          style: TextStyle(
                            color: isUploaded
                                ? const Color(0xFF2ED573)
                                : const Color(0xFF00B4D8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // SAĞ PANEL
  Widget _buildRightTerminalPanel(BuildContext context) {
    return BlocBuilder<ImageDetailCubit, ImageDetailState>(
      builder: (context, state) {
        final isGenerating = state is JsonResponseLoading;
        final isGenerated =
            state is JsonResponseLoaded ||
                state is CloudUploadingState ||
                state is CloudUploadSuccessState;

        return Container(
          height: 540,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1017),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFFFF5F56),
                    ),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFFFFBD2E),
                    ),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 5,
                      backgroundColor: Color(0xFF27C93F),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'output.json',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    if (isGenerated)
                      InkWell(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              color: Colors.white38,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Kopyala',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildTerminalContentByState(state),
                ),
              ),
              // Terminal Alt Durum Çubuğu
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: isGenerating
                          ? Colors.amber
                          : state is CloudUploadingState
                          ? Colors.lightBlue
                          : isGenerated
                          ? const Color(0xFF2ED573)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isGenerating
                          ? 'Üretiliyor...'
                          : state is CloudUploadingState
                          ? 'Cloud\'a Aktarılıyor...'
                          : isGenerated
                          ? 'Hazır'
                          : 'Bekliyor',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Terminal İçeriğini Veren Metot
  Widget _buildTerminalContentByState(ImageDetailState state) {
    if (state is JsonResponseLoading) {
      return const FigmaAiLoadingWidget();
    }

    String? jsonText;
    if (state is JsonResponseLoaded) {
      jsonText = state.rowJson;
    } else if (state is CloudUploadingState) {
      jsonText = state.rowJson;
    } else if (state is CloudUploadSuccessState) {
      jsonText = state.rowJson;
    }

    if (jsonText != null) {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF090B10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            jsonText,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Color(0xFF2ED573),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars_rounded, color: Color(0xFF2A2D3D), size: 56),
          SizedBox(height: 12),
          Text(
            '"Generate Questions & Choices" butonuna basarak başla',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            '( JSON çıktısı burada görünecek )',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1730),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3D2A60)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFA855F7),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}