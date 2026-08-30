import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/image-detail/image_detail_cubit.dart';
import '../bloc/image-detail/image_detail_state.dart';
import '../widgets/figma_ai_loading_widget.dart';

class ImageDetailPage extends StatelessWidget {
  final String imageUrl;
  final String imageName;
  final String imageSize;
  final String imageDate;
  final List<String> tags;

  const ImageDetailPage({
    super.key,
    required this.imageUrl,
    required this.imageName,
    this.imageSize = '3.2 MB',
    this.imageDate = 'Aug 7, 2026',
    this.tags = const ['#nature', '#landscape'],
  });

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
            Expanded(
              flex: 5,
              child: _buildLeftPanel(context),
            ),
            const SizedBox(width: 24),
            // SAĞ PANEL
            Expanded(
              flex: 5,
              child: _buildRightTerminalPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  // SOL PANEL: Görsel, Meta Veriler ve Aksiyon Butonları
  Widget _buildLeftPanel(BuildContext context) {
    return BlocBuilder<ImageDetailCubit, ImageDetailState>(
      builder: (context, state) {
        final isGenerating = state is JsonResponseLoading;
        final isGenerated = state is JsonResponseLoaded;

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
                      child: const Icon(Icons.broken_image, color: Colors.white24, size: 48),
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
                    ...tags.map((tag) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _buildTag(tag),
                    )),
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
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isGenerating
                      ? null
                      : () {
                    // Cubit tetikleme işlemi
                    context.read<ImageDetailCubit>().sendPromptRequest(imageUrl, 'orta');
                  },
                  child: isGenerating
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate Questions & Choices',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              // Cloud'a Yükle Butonu (Yalnızca üretildiyse görünür)
              if (isGenerated) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2229),
                      side: const BorderSide(color: Color(0xFF00B4D8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Cloud yükleme aksiyonu
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF00B4D8),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Cloud\'a Yükle',
                          style: TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.w600),
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

  // SAĞ PANEL: IDE Terminal & JSON Görünümü
  Widget _buildRightTerminalPanel(BuildContext context) {
    return BlocBuilder<ImageDetailCubit, ImageDetailState>(
      builder: (context, state) {
        final isGenerating = state is JsonResponseLoading;
        final isGenerated = state is JsonResponseLoaded;

        return Container(
          height: 540,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1017),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              // Terminal Üst Barı
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFF5F56)),
                    const SizedBox(width: 6),
                    const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFFBD2E)),
                    const SizedBox(width: 6),
                    const CircleAvatar(radius: 5, backgroundColor: Color(0xFF27C93F)),
                    const SizedBox(width: 12),
                    const Text(
                      'output.json',
                      style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'monospace'),
                    ),
                    const Spacer(),
                    if (isGenerated)
                      InkWell(
                        onTap: () {},
                        child: const Row(
                          children: [
                            Icon(Icons.copy_rounded, color: Colors.white38, size: 14),
                            SizedBox(width: 4),
                            Text('Kopyala', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Terminal İçeriği
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildTerminalContentByState(state),
                ),
              ),
              // Terminal Alt Durum Çubuğu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: isGenerating
                          ? Colors.amber
                          : isGenerated
                          ? const Color(0xFF2ED573)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isGenerating
                          ? 'Üretiliyor...'
                          : isGenerated
                          ? 'Hazır'
                          : 'Bekliyor',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
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

  // State Kontrolüne Göre Terminal İçeriğini Veren Metot
  Widget _buildTerminalContentByState(ImageDetailState state) {
    if (state is JsonResponseLoading) {
      // 🟢 Cubit emit(JsonResponseLoading()) attığında Figma AI Loading Widget çalışır
      return const FigmaAiLoadingWidget();
    }

    if (state is JsonResponseLoaded) {
      // Model verisi toMap() veya json string formatı ile bastırılır
     // final jsonOutputText = state.question.toMap().toString();
      final jsonOutputText = null;

      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF090B10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            jsonOutputText,
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

   /* if (state is ImageDetailError) {
      return Center(
        child: Text(
          'Hata: ${state.message}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
        ),
      );
    } */

    // İlk/Initial Durum
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
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(color: Color(0xFFA855F7), fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}