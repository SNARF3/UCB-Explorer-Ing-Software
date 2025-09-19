import 'package:flutter/material.dart';

class PremiosScreen extends StatelessWidget {
  const PremiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de premios con sus puntos requeridos
    final List<Map<String, dynamic>> premios = [
      {'nombre': 'Carpeta', 'imagen': 'carpeta.jpg', 'puntos': 1500},
      {'nombre': 'Cuaderno', 'imagen': 'cuaderno.jpg', 'puntos': 2000},
      {'nombre': 'Estuchera', 'imagen': 'estuchera.jpg', 'puntos': 2500},
      {'nombre': 'Hoddie', 'imagen': 'hoddie.jpg', 'puntos': 5000},
      {'nombre': 'Tomatodo', 'imagen': 'tomatodo.jpg', 'puntos': 3500},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premios Disponibles', 
              style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004077),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: premios.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: Image.asset(
                      'lib/assets/images/${premios[index]['imagen']}', // Ruta corregida, sin ../ y sin barra inicial
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        premios[index]['nombre'],
                        style: const TextStyle(
                          color: Color(0xFF004077), // Azul cambiado
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${premios[index]['puntos']} Puntos',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}