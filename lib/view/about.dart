import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Atma Kitchen'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bakery_dining, color: Colors.white, size: 44),
                      SizedBox(height: 12),
                      Text(
                        'Where Flavor Meets Soul, Every Dish Tells a Story',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat datang di Atma Kitchen, toko kue dan roti yang memadukan resep klasik dengan bahan berkualitas pilihan. Setiap produk dibuat dengan perhatian penuh untuk menemani momen spesial Anda.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Filosofi Kami',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Di Atma Kitchen, kami percaya bahwa makanan bukan sekadar hidangan, melainkan cerminan rasa, tradisi, dan kehangatan. Setiap kue dibuat segar sesuai kuota produksi harian agar kualitas rasa selalu terjaga.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Misi Kami',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menghadirkan pengalaman kuliner bakery yang mudah dipesan, tepat waktu, dan memuaskan pelanggan — baik melalui layanan pickup maupun pengiriman langsung ke rumah Anda.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
