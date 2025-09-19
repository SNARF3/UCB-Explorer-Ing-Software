import 'package:flutter/material.dart';

class PuntoCard extends StatelessWidget {
  final int puntos;

  const PuntoCard({super.key, required this.puntos});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFF024177), // azul oficial UCB
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.star,
              color: Color(0xFFFFCF00),
              size: 36,
            ), // amarillo oficial
            const SizedBox(width: 16),
            Text(
              '$puntos puntos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
