import 'package:atma_kitchen_mobile/auth_service/customer_service.dart';
import 'package:atma_kitchen_mobile/client/cart_client.dart';
import 'package:atma_kitchen_mobile/client/produkClient.dart';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/controller/login_controller.dart';
import 'package:atma_kitchen_mobile/model/cart_model.dart';
import 'package:atma_kitchen_mobile/model/customer_model.dart';
import 'package:atma_kitchen_mobile/model/produk.dart';
import 'package:atma_kitchen_mobile/view/about.dart';
import 'package:atma_kitchen_mobile/view/cart/cart_view.dart';
import 'package:atma_kitchen_mobile/view/customer/saldo_view.dart';
import 'package:atma_kitchen_mobile/view/editProfil/ediProfil.dart';
import 'package:atma_kitchen_mobile/view/history_pemesanan/history_view.dart';
import 'package:flutter/material.dart';

class CustomerViewPage extends StatefulWidget {
  const CustomerViewPage({super.key});

  @override
  State<CustomerViewPage> createState() => _CustomerViewPageState();
}

class _CustomerViewPageState extends State<CustomerViewPage> {
  CustomerModel? _customer;
  List<Produk> _products = [];
  int _cartCount = 0;
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _addingProductId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        CustomerService.getUserInfo(),
        ProdukClient.fetchAll(),
        CartClient.fetchCart(),
      ]);

      if (!mounted) return;
      setState(() {
        _customer = results[0] as CustomerModel;
        _products = results[1] as List<Produk>;
        _cartCount = (results[2] as CartModel).cartCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart(Produk produk) async {
    setState(() => _addingProductId = produk.idProduk);
    try {
      final cart = await CartClient.addItem(produk.idProduk, jumlah: 1);
      if (!mounted) return;
      setState(() => _cartCount = cart.cartCount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produk.nama} ditambahkan ke keranjang'),
          action: SnackBarAction(
            label: 'Lihat',
            textColor: Colors.amberAccent,
            onPressed: _openCart,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _addingProductId = null);
    }
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartView()),
    );
    _loadAll();
  }

  Future<void> _openEditProfile() async {
    if (_customer == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilPage(customer: _customer!),
      ),
    );
    if (updated == true) {
      _loadAll();
    }
  }

  Future<void> _openSaldo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SaldoView()),
    );
    _loadAll();
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
    );
    _loadAll();
  }

  void _showProductDetail(Produk produk) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(produk.nama),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: _SafeNetworkImage(url: produk.gambar),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ApiConfig.formatRupiah(produk.harga),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(produk.availabilityLabel),
                if (produk.deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(produk.deskripsi),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: produk.availableStock <= 0
                ? null
                : () {
                    Navigator.pop(ctx);
                    _addToCart(produk);
                  },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Tambah ke Keranjang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredProducts = _searchQuery.isEmpty
        ? _products
        : _products
            .where((p) =>
                p.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atma Kitchen'),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Keranjang',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _openCart,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 32),
              ),
              accountName: Text(
                _customer?.nama.isNotEmpty == true
                    ? _customer!.nama
                    : 'Customer',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_customer?.email ?? ''),
                  const SizedBox(height: 2),
                  Text(
                    '${_customer?.jumlahPoin ?? 0} Poin  •  ${ApiConfig.formatRupiah(_customer?.saldo ?? 0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Menu & Katalog'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text('Keranjang ($_cartCount)'),
              onTap: () {
                Navigator.pop(context);
                _openCart();
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Riwayat Pesanan'),
              onTap: () {
                Navigator.pop(context);
                _openHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Saldo & Penarikan'),
              onTap: () {
                Navigator.pop(context);
                _openSaldo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context);
                _openEditProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Atma Kitchen'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await LoginController.logout(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 52, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAll,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAll,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 12,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Halo, ${_customer?.nama ?? 'Customer'}!',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Saldo: ${ApiConfig.formatRupiah(_customer?.saldo ?? 0)}  •  Poin: ${_customer?.jumlahPoin ?? 0}',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _openHistory,
                                        icon: const Icon(Icons.receipt_long,
                                            size: 18),
                                        label: const Text('Pesanan'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _openSaldo,
                                        icon: const Icon(
                                            Icons.account_balance_wallet,
                                            size: 18),
                                        label: const Text('Saldo'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _openCart,
                                        icon: const Icon(Icons.shopping_cart,
                                            size: 18),
                                        label: Text('Keranjang ($_cartCount)'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari produk favorit Anda...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (v) =>
                                setState(() => _searchQuery = v.trim()),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Menu Atma Kitchen (${filteredProducts.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (filteredProducts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Text('Produk tidak ditemukan'),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                childAspectRatio: 0.70,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final produk = filteredProducts[index];
                                final isAdding =
                                    _addingProductId == produk.idProduk;

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: InkWell(
                                    onTap: () => _showProductDetail(produk),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: _SafeNetworkImage(
                                              url: produk.gambar,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                produk.nama,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                ApiConfig.formatRupiah(
                                                    produk.harga),
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                produk.availabilityLabel,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                  ),
                                                  onPressed: isAdding ||
                                                          produk.availableStock <=
                                                              0
                                                      ? null
                                                      : () => _addToCart(produk),
                                                  icon: isAdding
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .add_shopping_cart,
                                                          size: 16,
                                                        ),
                                                  label: Text(
                                                    produk.availableStock <= 0
                                                        ? 'Habis'
                                                        : 'Tambah',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _SafeNetworkImage extends StatelessWidget {
  final String url;

  const _SafeNetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: Colors.brown.shade50,
        child: const Center(
          child: Icon(Icons.cake, size: 42, color: Colors.brown),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.brown.shade50,
          child: const Center(
            child: Icon(Icons.bakery_dining, size: 42, color: Colors.brown),
          ),
        );
      },
    );
  }
}
