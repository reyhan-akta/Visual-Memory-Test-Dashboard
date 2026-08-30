import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_dashboard/core/constants/app_colors.dart';
import '../../domain/entities/image_entity.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'image_detail_page.dart';
import 'image_item_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 Hatanın çözümü: Sayfayı BlocProvider ile sarmalayıp verileri yüklüyoruz
    return BlocProvider(
      create: (context) => DashboardGridCubit()..fetchImages(),
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: const [
                    _HeaderWidget(),
                    SizedBox(height: 32),

                    _StatsSectionWidget(),
                    SizedBox(height: 32),

                    _GalleryHeaderWidget(),
                    SizedBox(height: 20),

                    _ImageGridWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarWidget extends StatelessWidget {
  const _SidebarWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Uygulama Adı
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nimbus',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'v2.4.1',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Menü Elemanları
          _buildNavItem(
            Icons.grid_view_rounded,
            'Gallery',
            isActive: true,
            badgeText: '6',
          ),
          _buildNavItem(Icons.cloud_upload_outlined, 'Upload'),
          _buildNavItem(Icons.folder_open_outlined, 'Albums'),
          _buildNavItem(Icons.star_border, 'Starred'),
          _buildNavItem(Icons.delete_outline, 'Trash'),

          const Spacer(),

          // Storage Bar (Sol Alt)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Storage',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '12.4 / 50 GB',
                      style: TextStyle(
                        color: AppColors.primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 12.4 / 50,
                  backgroundColor: AppColors.primaryText,
                  color: AppColors.primaryAccent,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                const Text(
                  '37.6 GB free',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNavItem(
    IconData icon,
    String title, {
      bool isActive = false,
      String? badgeText,
    }) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryText : AppColors.secondaryText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primaryText : AppColors.secondaryText,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (badgeText != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryText,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'My Gallery',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            // Search Input
            SizedBox(
              width: 280,
              height: 42,
              child: TextField(
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search images...',
                  hintStyle: const TextStyle(color: AppColors.secondaryText),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // + Upload Button
            ElevatedButton.icon(
              onPressed: () {
                  context.read<DashboardGridCubit>().pickAndUploadImage();

              },
              icon: const Icon(
                Icons.add,
                color: AppColors.primaryText,
                size: 18,
              ),
              label: const Text(
                'Upload',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsSectionWidget extends StatelessWidget {
  const _StatsSectionWidget();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _StatCard(
          title: 'TOPLAM RESİM',
          value: '6',
          subtitle: '+3 bu hafta',
          subtitleColor: AppColors.primaryAccent,
          delayDuration: 200,
        ),
        _StatCard(
          title: 'KULLANILAN ALAN',
          value: '12.4 GB',
          subtitle: '%24.8 dolu',
          subtitleColor: Color(0xFF22D3EE),
          delayDuration: 400,
        ),
        _StatCard(
          title: 'PAYLAŞILANLAR',
          value: '18',
          subtitle: '5 aktif link',
          subtitleColor: Colors.amber,
          delayDuration: 600,
        ),
        _StatCard(
          title: 'BU AY YÜKLEME',
          value: '47',
          subtitle: '↑ %12 artış',
          subtitleColor: Colors.greenAccent,
          delayDuration: 800,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final int delayDuration;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    required this.delayDuration,
  });

  @override
  Widget build(BuildContext context) {
    return BackInDown(
      delay: Duration(milliseconds: delayDuration),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryText.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.secondaryAccent,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryHeaderWidget extends StatelessWidget {
  const _GalleryHeaderWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardGridCubit, DashboardGridState>(
      builder: (context, state) {

        String? currentDifficultyLevel ;

        if (state is DashboardLoadedSuccessfuly) {
          currentDifficultyLevel = state.difficultyLevel;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Görseller',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                // 🟢 Seviye Dropdown Bileşeni
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryText.withOpacity(0.05),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentDifficultyLevel ?? 'Kolay',
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                      dropdownColor: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      items: <String>['Kolay', 'Orta', 'Zor'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newLevel) {
                        if (newLevel != null) {

                          context
                              .read<DashboardGridCubit>()
                              .changeDifficulty(newLevel);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Grid / List Görünüm Butonları
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: AppColors.primaryAccent,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.format_list_bulleted,
                          size: 18,
                          color: AppColors.secondaryText,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ImageGridWidget extends StatelessWidget {
  const _ImageGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardGridCubit, DashboardGridState>(
      builder: (context, state) {

        // 1. Ekran Yüklenirken (Loading State)
        if (state is DashboardLoading) {
          final previousImages = state.previousImages;

          if (previousImages == null || previousImages.isEmpty) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          return _buildGrid(context, images: previousImages);
        }

        // 2. Yükleme Başarılı Tamamlandığında (Success State)
        if (state is DashboardLoadedSuccessfuly) {
          final images = state.images;

          if (images.isEmpty) {
            return const Center(
              child: Text("Henüz hiç görsel yüklenmedi."),
            );
          }

          return _buildGrid(context, images: images);
        }

        // 3. Hata Durumu (Error State)
        if (state is DashboardError) {
          return Center(
            child: Text("Bir hata oluştu: ${state.message}"),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// GridView Tasarımı
  Widget _buildGrid(BuildContext context, {required List<Object?> images}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = images[index];

        // 🟢 ELEMAN NULL İSE: Yükleniyor Kartı
        if (item == null) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryText.withOpacity(0.05),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        // 🟢 ELEMAN DOLU İSE: Resim ve Sağ Üstte Delete İkonu
        final image = item as ImageEntity;

        return Stack(
          children: [
            // 1. RESİM KARTI VE TIKLAMA ALANI (Tüm kartı kaplar)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    // Detay sayfasına yönlendirme
                   /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(
                          imageUrl: image.url,
                          imageName: image.id ?? 'Görsel ${index + 1}',
                        ),

                      ),



                    ); */

                    ImageItemWidget.showAddVideoDialog(context,index, image.url, imageId: image.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(image.url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. SAĞ ÜST SİLME İKONU (Tıklaması resim kartından bağımsızdır)
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    DeleteConfirmDialog.show(
                      context,
                      onConfirm: () {
                        context.read<DashboardGridCubit>().deleteImage(image.id!);
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFCC9BDD),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

