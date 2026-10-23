import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Warna tema (biru)
const Color biruTua = Color(0xFF0D47A1);
const Color biruUtama = Color(0xFF1976D2);
const Color biruPucat = Color(0xFFBBDEFB);
const Color biruLatar = Color(0xFFE3F2FD);

// ===================== MODEL DATA =====================
class Momen {
  final String tag; // String
  final String date;
  final List<String> imageUrls; // List
  final String story;
  final int jumlahSuka; // int
  final double rating; // double

  const Momen({
    required this.tag,
    required this.date,
    required this.imageUrls,
    required this.story,
    required this.jumlahSuka,
    required this.rating,
  });
}

// Agar halaman & foto bisa digeser memakai mouse/trackpad (di web default-nya hanya sentuhan)
class PerilakuScroll extends MaterialScrollBehavior {
  const PerilakuScroll();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

// ===================== APLIKASI =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const PerilakuScroll(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: biruUtama),
        scaffoldBackgroundColor: biruLatar,
        appBarTheme: const AppBarTheme(
          backgroundColor: biruUtama,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: biruUtama,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
        ),
      ),
      home: const LayarUtama(),
    );
  }
}

class LayarUtama extends StatefulWidget {
  const LayarUtama({super.key});

  @override
  State<LayarUtama> createState() => _LayarUtamaState();
}

class _LayarUtamaState extends State<LayarUtama> {
  final PageController _pageController = PageController();
  int halamanAktif = 0;

  // Data list momen
  final List<Momen> daftarMomen = const [
    Momen(
      tag: '#Manioko',
      date: '2023-2026',
      imageUrls: [
        'manioko1.jpeg',
        'manioko2.jpeg',
        'manioko3.jpeg',
      ],
      story:
          'Some friendships make life feel a little lighter, the laughs a little louder, and ordinary days a little more special. Grateful for the kind of people who make being myself feel so easy. ♡',
      jumlahSuka: 128,
      rating: 4.8,
    ),
    Momen(
      tag: '#Toy Story',
      date: '2025-2026',
      imageUrls: [
        'ts1.jpeg',
        'ts2.jpeg',
      ],
      story:
          'Growing through life together, collecting little memories, sharing big dreams, and laughing at things that probably are not even that funny. Maybe that is what makes friendship beautiful — having people who just get you. ♡',
      jumlahSuka: 54,
      rating: 4.6,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _keHalaman(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // Membatasi lebar konten agar rapi di layar lebar
  Widget _dibatasi(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 432),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Momen')),
      body: Column(
        children: [
          // Indikator halaman ala story Instagram
          _dibatasi(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: IndikatorHalaman(
                jumlah: daftarMomen.length,
                aktif: halamanAktif,
                onPilih: _keHalaman,
              ),
            ),
          ),

          // Halaman yang bisa digeser kiri-kanan
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: daftarMomen.length,
              onPageChanged: (index) {
                setState(() {
                  halamanAktif = index;
                });
              },
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (context, c) {
                    // Tinggi foto menyesuaikan tinggi layar supaya tidak overflow
                    final tinggiFoto = (c.maxHeight - 380).clamp(140.0, 260.0).toDouble();
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: KartuMomen(
                          momen: daftarMomen[index],
                          tinggiFoto: tinggiFoto,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Tombol pindah halaman
          _dibatasi(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: halamanAktif > 0
                          ? () => _keHalaman(halamanAktif - 1)
                          : null,
                      child: const Text('Sebelumnya'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: halamanAktif < daftarMomen.length - 1
                          ? () => _keHalaman(halamanAktif + 1)
                          : null,
                      child: const Text('Berikutnya'),
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

// Custom widget: garis indikator halaman (bisa diketuk)
class IndikatorHalaman extends StatelessWidget {
  final int jumlah;
  final int aktif;
  final ValueChanged<int> onPilih;

  const IndikatorHalaman({
    super.key,
    required this.jumlah,
    required this.aktif,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        jumlah,
        (i) => Expanded(
          child: GestureDetector(
            onTap: () => onPilih(i),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= aktif ? biruUtama : biruPucat,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget khusus untuk kartu momen agar interaksi tombol & slide foto berjalan independen
class KartuMomen extends StatefulWidget {
  final Momen momen;
  final double tinggiFoto;

  const KartuMomen({super.key, required this.momen, this.tinggiFoto = 240});

  @override
  State<KartuMomen> createState() => _KartuMomenState();
}

class _KartuMomenState extends State<KartuMomen>
    with AutomaticKeepAliveClientMixin {
  final PageController _fotoController = PageController();
  int currentImageIndex = 0;
  bool isLiked = false;
  bool isSaved = false;
  bool isExpanded = false;

  // Agar status suka/simpan tidak hilang saat berpindah halaman
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _fotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final jumlahFoto = widget.momen.imageUrls.length;
    final totalSuka = widget.momen.jumlahSuka + (isLiked ? 1 : 0);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: biruUtama.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: biruLatar,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.momen.tag,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: biruTua,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Nama, Tanggal, dan Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Momen',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: biruUtama,
                      ),
                    ),
                    Text(
                      widget.momen.date,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: biruLatar,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: biruUtama),
                    const SizedBox(width: 2),
                    Text(
                      '${widget.momen.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: biruTua,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Frame Slider Foto ala Instagram
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: widget.tinggiFoto,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _fotoController,
                    itemCount: jumlahFoto,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, imgIndex) {
                      return Image.network(
                        widget.momen.imageUrls[imgIndex],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const ColoredBox(
                            color: biruPucat,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const ColoredBox(
                            color: biruPucat,
                            child: Center(
                              child: Icon(Icons.image_outlined, color: biruUtama),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // Penghitung foto
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${currentImageIndex + 1}/$jumlahFoto',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  // Indikator Posisi Foto (Dots)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        jumlahFoto,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: currentImageIndex == dotIndex ? 12 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: currentImageIndex == dotIndex
                                ? Colors.white
                                : Colors.white.withAlpha(130),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Baris Tombol Interaktif
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : biruUtama,
                    ),
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: biruUtama),
                    onPressed: () {
                      debugPrint("Buka Komentar");
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: biruUtama),
                    onPressed: () {
                      debugPrint("Bagikan Momen");
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: biruUtama,
                ),
                onPressed: () {
                  setState(() {
                    isSaved = !isSaved;
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '$totalSuka suka',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),

          // Cuplikan Cerita Momen
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: biruLatar,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.momen.story,
                      maxLines: isExpanded ? null : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                        debugPrint("Baca Selengkapnya Diklik");
                      },
                      child: Text(
                        isExpanded ? 'Tutup' : 'Baca Selengkapnya',
                        style: const TextStyle(fontSize: 12),
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
