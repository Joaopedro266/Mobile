import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../model/planet.dart';
import 'planet_list_page.dart';
import 'planet_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Color _hexToColor(String hex) {
    try {
      String formattedHex = hex.replaceAll('#', '0xff');
      if (formattedHex.length == 8) {
        formattedHex = formattedHex.replaceFirst('0x', '0xff');
      }
      return Color(int.parse(formattedHex));
    } catch (e) {
      return Colors.white;
    }
  }

  void _showPage(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout, color: Colors.greenAccent),
            tooltip: 'Sair',
          )
        ],
      ),
      body: StreamBuilder<List<Planet>>(
        stream: _firestoreService.getPlanetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          final List<Planet> planets = snapshot.data ?? [];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              List<Widget> backPlanets = [];
              List<Widget> frontPlanets = [];

              final double orbitRadiusX =
                  MediaQuery.of(context).size.width * 0.4;
              final double orbitRadiusY = 60.0;
              final double centerX = MediaQuery.of(context).size.width / 2;
              final double centerY = MediaQuery.of(context).size.height / 2;

              for (int i = 0; i < planets.length; i++) {
                double angle = (_controller.value * 2 * pi) +
                    (i * (2 * pi / planets.length));

                double x = centerX + orbitRadiusX * cos(angle) - 14;
                double y = centerY + orbitRadiusY * sin(angle) - 14;

                double scale = 1.0 + (sin(angle) * 0.3);
                double opacity = 0.5 + ((scale - 0.7) / 1.3);

                Widget planetWidget = Positioned(
                  left: x,
                  top: y,
                  key: ValueKey(planets[i].id),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity.clamp(0.2, 1.0),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hexToColor(planets[i].corPredominante),
                          boxShadow: [
                            BoxShadow(
                              color: _hexToColor(planets[i].corPredominante)
                                  .withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                if (sin(angle) > 0) {
                  frontPlanets.add(planetWidget);
                } else {
                  backPlanets.add(planetWidget);
                }
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/imgs/background.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  ...backPlanets,
                  ...frontPlanets,
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTitle("GALACTIC\nDB"),
                        const SizedBox(height: 50),
                        _buildButton(
                          label: "NOVO ASTRO",
                          icon: Icons.add,
                          color: Colors.greenAccent,
                          onTap: () =>
                              _showPage(context, const PlanetFormPage()),
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          label: "VISUALIZAR",
                          icon: Icons.list,
                          color: Colors.greenAccent,
                          onTap: () =>
                              _showPage(context, const PlanetListPage()),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Pixelate',
        fontWeight: FontWeight.bold,
        fontSize: 40,
        color: Colors.greenAccent,
        shadows: [
          Shadow(
              offset: Offset(0, 0), blurRadius: 10, color: Colors.greenAccent),
          Shadow(offset: Offset(2, 2), color: Color.fromARGB(255, 0, 70, 0)),
        ],
        letterSpacing: 5,
      ),
    );
  }

  Widget _buildButton(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.5), blurRadius: 15, spreadRadius: 1)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pixelate',
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
