import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.12),
        child: AppBar(
          backgroundColor: const Color(0xFF004077),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Panel del Administrador',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Herramientas de Administración',
              style: TextStyle(
                color: Color(0xFF004077),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gestiona todos los aspectos de la aplicación desde aquí.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
              ),
              children: [
                _buildAdminButton(
                  context,
                  icon: Icons.quiz_outlined,
                  label: 'Crear Pregunta',
                  route: '/admin-crear-pregunta',
                ),
                _buildAdminButton(
                  context,
                  icon: Icons.qr_code_2_outlined,
                  label: 'Crear Código QR',
                  route: '/admin-crear-qr',
                ),
                _buildAdminButton(
                  context,
                  icon: Icons.edit_note_outlined,
                  label: 'Banco de Preguntas',
                  route: '/admin-ver-preguntas',
                ),

                // 🔥 Nuevo botón para ir al Dashboard
                _buildAdminButton(
                  context,
                  icon: Icons.bar_chart_outlined,
                  label: 'Dashboard',
                  route: '/admin-dash',
                ),

                // 🔥 Botón mejorado para Ver Feedback de Usuarios
                _buildAdminButton(
                  context,
                  icon:
                      Icons
                          .feedback_outlined, // icono más representativo de comentarios
                  label: 'Feedback Usuarios', // texto más compacto
                  route: '/admin-ver-feedback',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004077), Color(0xFF0066CC)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: const Color(0xFFFFD700)),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF004077)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
