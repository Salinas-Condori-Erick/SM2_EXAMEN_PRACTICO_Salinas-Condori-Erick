import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool isFavorite;
  final _comentarioCtrl = TextEditingController();
  int _valoracionNueva = 0;

  @override
  void initState() {
    super.initState();
    isFavorite = false; // Simulado
  }

  void _agregarComentario() {
    if (_comentarioCtrl.text.trim().isEmpty || _valoracionNueva == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario y selecciona una valoración.'),
        ),
      );
      return;
    }

    setState(() {
      widget.product.comentarios.add({
        'usuario': 'Usuario Demo',
        'valoracion': _valoracionNueva,
        'comentario': _comentarioCtrl.text.trim(),
      });
      _comentarioCtrl.clear();
      _valoracionNueva = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario agregado exitosamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final precioConDescuento = product.precio * (1 - product.descuento / 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Agregado a favoritos (simulado)'
                        : 'Removido de favoritos (simulado)',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: product.imagenes.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    product.imagenes[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Image.asset('assets/images/placeholder.png'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'S/ ${precioConDescuento.toStringAsFixed(2)} (Antes: S/ ${product.precio.toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < product.valoracion.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 6),
                Text('(${product.valoracionesTotal} valoraciones)'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${product.vendidos} vendidos',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(product.descripcion),
            const Divider(height: 32),

            // Colores disponibles
            const Text(
              'Colores disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  product.colores
                      .map((color) => Chip(label: Text(color)))
                      .toList(),
            ),

            const Divider(height: 32),
            const Text(
              'Tallas disponibles',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  product.tallas
                      .map((talla) => Chip(label: Text(talla)))
                      .toList(),
            ),
            const SizedBox(height: 6),
            Text(
              product.descripcionTallas,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const Divider(height: 32),
            const Text(
              'Comentarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Campo para escribir comentario
            const Text(
              'Tu valoración:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _valoracionNueva ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _valoracionNueva = i + 1;
                    });
                  },
                ),
              ),
            ),
            TextField(
              controller: _comentarioCtrl,
              decoration: const InputDecoration(
                hintText: 'Escribe tu comentario...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agregarComentario,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text(
                  'Enviar comentario',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comentarios existentes
            if (product.comentarios.isEmpty)
              const Text('Aún no hay comentarios.')
            else
              ...product.comentarios.map(
                (comentario) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < (comentario['valoracion'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            comentario['usuario'] ?? 'Anónimo',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comentario['comentario'] ?? ''),
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
