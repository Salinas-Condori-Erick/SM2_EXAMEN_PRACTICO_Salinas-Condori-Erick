// product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'ProductFormScreen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('producto')
            .where('estado', isNotEqualTo: 'inactivo')
            .get();

    final productosCargados =
        snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data()))
            .toList();

    setState(() => productos = productosCargados);
  }

  void _eliminarProducto(Product producto) async {
    await FirebaseFirestore.instance
        .collection('producto')
        .doc(producto.id)
        .update({'estado': 'inactivo'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto.nombre} fue marcado como inactivo.')),
    );

    _cargarProductos();
  }

  void _editarProducto(Product producto) async {
    final productoEditado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(productoExistente: producto),
      ),
    );

    if (productoEditado != null) {
      await FirebaseFirestore.instance
          .collection('producto')
          .doc(productoEditado.id)
          .set(productoEditado.toMap());

      _cargarProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
      body:
          productos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: productos.length,
                itemBuilder: (_, i) {
                  final p = productos[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          p.imagenes.isNotEmpty
                              ? Image.network(
                                p.imagenes[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                      'assets/images/placeholder.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                'assets/images/placeholder.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                    ),
                    title: Text(p.nombre),
                    subtitle: Text('Stock: ${p.stock} - Estado: ${p.estado}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarProducto(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _eliminarProducto(p),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final nuevo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (nuevo != null) {
            await FirebaseFirestore.instance
                .collection('producto')
                .doc(nuevo.id)
                .set(nuevo.toMap());
            _cargarProductos();
          }
        },
      ),
    );
  }
}
