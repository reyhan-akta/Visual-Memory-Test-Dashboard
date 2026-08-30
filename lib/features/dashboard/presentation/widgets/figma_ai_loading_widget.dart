import 'dart:async';
import 'package:flutter/material.dart';

class FigmaAiLoadingWidget extends StatefulWidget {
  final List<String>? loadingTexts;

  const FigmaAiLoadingWidget({
    super.key,
    this.loadingTexts,
  });

  @override
  State<FigmaAiLoadingWidget> createState() => _FigmaAiLoadingWidgetState();
}

class _FigmaAiLoadingWidgetState extends State<FigmaAiLoadingWidget> {
  int _currentIndex = 0;
  Timer? _timer;

  // Figma AI tarzı varsayılan teknolojik terimler
  late final List<String> _texts = widget.loadingTexts ?? [
    'Görsel pikselleri taranıyor...',
    'Nesneler ve semboller tespit ediliyor...',
    'Görsel bağlamı analiz ediliyor...',
    'Sorular ve çeldirici şıklar tasarlanıyor...',
    'Yapay zeka sorusu optimize ediliyor...',
    'Neredeyse tamamlandı...',
  ];

  @override
  void initState() {
    super.initState();
    // Her 1.8 saniyede bir metni yukarı doğru kaydırarak değiştir
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _texts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Dairesel Parıltılı AI Yükleme İkonu
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Icon(
                Icons.auto_awesome, // Figma AI yıldız ikonu
                size: 28,
                color: Colors.amberAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Figma AI Yukarı Doğru Slide Eden Metin Efekti
          SizedBox(
            height: 30, // Metnin kayacağı sabit yükseklik
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), // Kayma hızı
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Aşağıdan yukarıya doğru kayma efekti (Slide Transition)
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 1.2), // Aşağıdan başla
                  end: Offset.zero,             // Tam ortada dur
                ).animate(animation);

                // Soluklaşarak gelme efekti (Fade)
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                _texts[_currentIndex],
                // Key vermek AnimatedSwitcher'ın metin değişimini algılaması için şarttır!
                key: ValueKey<int>(_currentIndex),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Colors.white.withOpacity(0.9),
                  shadows: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}