import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> _productosFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchText = '';
  String _selectedCategory = 'Todos';

  final List<String> _categorias = ['Todos', 'Ropa', 'Tecnología', 'Hogar'];

  @override
  void initState() {
    super.initState();
    _productosFuture = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('producto').get();
    final productos =
        snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();
    setState(() {
      _allProducts = productos;
      _filteredProducts = productos;
    });
    return productos;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesText = p.nombre.toLowerCase().contains(
              _searchText.toLowerCase(),
            );
        final matchesCategory =
            _selectedCategory == 'Todos' || p.categoria == _selectedCategory;
        return matchesText && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchText = value;
                _filterProducts();
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _selectedCategory = value;
                  _filterProducts();
                }
              },
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (_filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('No hay productos disponibles.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, i) =>
                        _buildProductCard(context, _filteredProducts[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final precioConDescuento = product.precio * (1 - product.descuento / 100);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product.imagenes.isNotEmpty
              ? Image.network(
                  product.imagenes[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/placeholder.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          product.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'S/ ${precioConDescuento.toStringAsFixed(2)}  (Antes: S/ ${product.precio.toStringAsFixed(2)})',
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < product.valoracion.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            Text(
              '${product.vendidos} vendidos',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Producto "${product.nombre}" agregado al carrito (simulado)',
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ProductDetailScreen(product: product),
            ),
          );
        },
      ),
    );
  }
}
