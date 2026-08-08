import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_dashboard/core/constants/app_colors.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  _HeaderWidget(),
                  const SizedBox(height: 32),

                  const _StatsSectionWidget(),
                  const SizedBox(height: 32),

                  const _GalleryHeaderWidget(),
                  const SizedBox(height: 20),

                  const _ImageGridWidget(),
                ],
              ),
            ),
          ),
        ],
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
        Spacer(),
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
              onPressed: () {},
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
              style: TextStyle(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '6 görsel',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
        ),
        Row(
          children: [
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
  }
}

class _ImageGridWidget extends StatelessWidget {

  const _ImageGridWidget();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        return Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryText.withOpacity(0.05)),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.secondaryText.withOpacity(0.3),
                size: 48,
              ),
            ),
          );
      },
    );
  }
}
