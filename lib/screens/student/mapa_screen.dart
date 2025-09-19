import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.deepPurple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      const Color.fromARGB(255, 3, 121, 52),
    ];

    final puntos = [
      PuntoMapa(
        offset: const Offset(100, 30),
        nombre: 'Coliseo UCB',
        descripcion: 'El gran coliseo de la UCB, uno de los mejores coliseos del país, si entras en esta universidad tu bienvenida será en este lugar 😉.',
        foto: 'lib/assets/images/coliseo.jpeg',
      ),
      PuntoMapa(offset: const Offset(190, 10), nombre: 'Bloque B', descripcion: 'Bloque de culturas...', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(260, 10), nombre: 'Bloque C', descripcion: 'Nuestro bloque mas moderno para ingenieria', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(30, 150), nombre: 'Bloque D', descripcion: 'Uno de los bloques mas grandes y clasicos de la u 😉', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(160, 80), nombre: 'Agora', descripcion: 'Este es el lugar donde podras divertirte con tus amigos o ir a hacer tus trabajos', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(320, 70), nombre: 'Bloque F', descripcion: 'Uno de los bloques mas antiguos de la universidad, lo mas probable es que tomes tus materias basica aca 😉', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(80, 180), nombre: 'Bloque G1', descripcion: 'Bloque de postgrado', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(150, 140), nombre: 'Bloque G2', descripcion: 'Bloque de postgrado y de la EPC', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(235, 150), nombre: 'Cafeteria', descripcion: 'En la cafeteria podras desayunar, almorzar y cenar con tus amigos :D', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(320, 150), nombre: 'Biblioteca', descripcion: 'En esta biblioteca podras estudiar tranquilamente o irte a dormir en nuestro 3er piso', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(70, 220), nombre: 'Bloque J', descripcion: 'Area donde podras ir a jugar con tus amigos o hablar con ellos 😉', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(120, 240), nombre: 'Atrio', descripcion: 'Descripción del Edificio K', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(330, 270), nombre: 'Rectorado', descripcion: 'Aca podras encontrar al rector xd (creo)', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(240, 210), nombre: 'Capilla', descripcion: 'En este lugar podras venir a rezar antes de tus parciales 😉', foto: 'lib/assets/images/UCB.png'),
      PuntoMapa(offset: const Offset(240, 280), nombre: 'Miamicito', descripcion: 'Lugar lleno de parejas, cuidado!', foto: 'lib/assets/images/UCB.png'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa del Campus',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005CA7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3.0,
              child: Stack(
                children: [
                  Image.asset(
                    'lib/assets/images/mapa1.jpeg',
                    fit: BoxFit.contain,
                  ),
                  ...puntos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final punto = entry.value;
                    final color = colores[index % colores.length];
                    return Positioned(
                      left: punto.offset.dx,
                      top: punto.offset.dy,
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.location_on, color: color, size: 30),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.yellow[700], // Fondo más amarillo
                                  title: Text(
                                    punto.nombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        punto.descripcion,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 8),
                                      Image.asset(
                                        punto.foto,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "Cerrar",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Text(
                            punto.nombre,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                botonNavegacion(context, 'Trivia', '/trivia'),
                botonNavegacion(context, 'Premios', '/premios'),
                botonNavegacion(context, 'QR', '/qr'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget botonNavegacion(BuildContext context, String texto, String ruta) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, ruta);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF005CA7),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(texto, style: const TextStyle(color: Colors.white)),
    );
  }
}

class PuntoMapa {
  final Offset offset;
  final String nombre;
  final String descripcion;
  final String foto;

  PuntoMapa({
    required this.offset,
    required this.nombre,
    required this.descripcion,
    required this.foto,
  });
}
