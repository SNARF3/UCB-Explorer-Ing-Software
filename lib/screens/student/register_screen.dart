import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- Añade esta línea
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

//Agregar funcionalidad de registro

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedColegio;
  String? _selectedCarrera;

  // Lista de carreras de la Universidad Católica Boliviana San Pablo
  final List<String> _carreras = [
    'Administración de Empresas',
    'Arquitectura',
    'Ciencias de la Computación',
    'Comunicación Social',
    'Contaduría Pública',
    'Derecho',
    'Diseño Gráfico',
    'Economía',
    'Educación',
    'Enfermería',
    'Filosofía y Letras',
    'Finanzas',
    'Ingeniería Ambiental',
    'Ingeniería Civil',
    'Ingeniería Comercial',
    'Ingeniería de Sistemas',
    'Ingeniería Electrónica',
    'Ingeniería Industrial',
    'Ingeniería Mecatrónica',
    'Ingeniería Química',
    'Ingeniería en Telecomunicaciones',
    'Marketing y Publicidad',
    'Medicina',
    'Psicología',
    'Relaciones Internacionales',
    'Turismo',
    // Puedes agregar más carreras si es necesario
  ];

  final List<String> _colegios = [
    'Colegio San Calixto',
    'Colegio La Salle',
    'Colegio San Agustín',
    'Colegio Don Bosco',
    'Colegio Franco Boliviano',
    'Colegio Alemán Mariscal Braun',
    'Colegio Santa Ana',
    'Colegio Sagrado Corazón',
    'Colegio San Ignacio',
    'Colegio San Andrés',
    'Colegio Loyola',
    'Colegio Santa Teresa de Jesús',
    'Colegio María Auxiliadora',
    'Colegio San Vicente',
    'Colegio Boliviano Hebreo',
    'Colegio Internacional',
    'Colegio Los Pinos',
    'Colegio San Pablo',
    'Colegio Santa María',
    'Colegio San Marcos',
    'Colegio San Simón',
    'Colegio San Jorge',
    'Colegio San Felipe',
    'Colegio San Lucas',
    'Colegio Santa Isabel',
    'Colegio San Miguel',
    'Colegio San Gabriel',
    'Colegio San José',
    'Colegio San Pedro',
    'Colegio San Juan',
  ];

  // Controladores para los campos de texto
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004077),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.login, color: Color(0xFFFFD700)),
            tooltip: 'Administrador',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _animation,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'lib/assets/images/UCB.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: const Text(
                      'Registro UCB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField('Nombres', Icons.person, false, _nombresController),
                  const SizedBox(height: 20),
                  _buildTextField('Apellidos', Icons.people_alt, false, _apellidosController),
                  const SizedBox(height: 20),
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildColegioDropdown(),
                  const SizedBox(height: 20),
                  _buildCarreraDropdown(), // <-- Nuevo campo de carrera
                  const SizedBox(height: 30),
                  ScaleTransition(
                    scale: _animation,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Guardar en Firebase
                          final docRef = await FirebaseFirestore.instance.collection('estudiantes').add({
                            'nombres': _nombresController.text.trim(),
                            'apellidos': _apellidosController.text.trim(),
                            'telefono': _telefonoController.text.trim(),
                            'email': _emailController.text.trim(),
                            'colegio': _selectedColegio,
                            'carrera': _selectedCarrera,
                            'fechaRegistro': FieldValue.serverTimestamp(),
                            'puntos': 0, 
                          });

                          // Guarda el ID localmente
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('userId', docRef.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro exitoso!'),
                              backgroundColor: Color(0xFF004077),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushReplacementNamed(context, '/home');
                          });
                        }
                      },
                      child: const Text(
                        'REGISTRARSE',
                        style: TextStyle(
                          color: Color(0xFF004077),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool isOptional, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelStyle: const TextStyle(color: Color(0xFFFFD700)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _telefonoController,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Teléfono',
        prefixIcon: const Icon(Icons.phone, color: Color(0xFFFFD700)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelStyle: const TextStyle(color: Color(0xFFFFD700)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (value.length != 8) {
          return 'El teléfono debe tener 8 dígitos';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Correo electrónico (opcional)',
        prefixIcon: const Icon(Icons.email, color: Color(0xFFFFD700)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelStyle: const TextStyle(color: Color(0xFFFFD700)),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value != null && value.isNotEmpty && !value.contains('@')) {
          return 'Ingrese un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildColegioDropdown() {
    return GestureDetector(
      onTap: () => _showColegioSearch(context),
      child: AbsorbPointer(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Colegio',
            prefixIcon: const Icon(Icons.school, color: Color(0xFFFFD700)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white),
            floatingLabelStyle: const TextStyle(color: Color(0xFFFFD700)),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF004077),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
          isExpanded: true,
          hint: const Text(
            'Seleccione su colegio',
            style: TextStyle(color: Colors.white70),
          ),
          value: _selectedColegio,
          items: _colegios.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione su colegio';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedColegio = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildCarreraDropdown() {
    return GestureDetector(
      onTap: () => _showCarreraSearch(context),
      child: AbsorbPointer(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Carrera de interés',
            prefixIcon: const Icon(Icons.school_outlined, color: Color(0xFFFFD700)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white),
            floatingLabelStyle: const TextStyle(color: Color(0xFFFFD700)),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF004077),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
          isExpanded: true,
          hint: const Text(
            'Seleccione su carrera de interés',
            style: TextStyle(color: Colors.white70),
          ),
          value: _selectedCarrera,
          items: _carreras.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione su carrera de interés';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _selectedCarrera = value;
            });
          },
        ),
      ),
    );
  }

  void _showColegioSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF004077),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar colegio...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFFFD700),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _colegios.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFFFFD700),
                      ),
                      title: Text(
                        _colegios[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedColegio = _colegios[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCarreraSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF004077),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar carrera...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFFFD700),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {},
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _carreras.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFFFFD700),
                      ),
                      title: Text(
                        _carreras[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCarrera = _carreras[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
