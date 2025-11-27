import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../model/planet.dart';
import 'planet_form_page.dart';

class PlanetListPage extends StatefulWidget {
  const PlanetListPage({super.key});

  @override
  State<PlanetListPage> createState() => _PlanetListPageState();
}

class _PlanetListPageState extends State<PlanetListPage> {
  final FirestoreService _firestoreService = FirestoreService();

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

  void _showPage({Planet? planet}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanetFormPage(planet: planet),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("EXCLUIR ASTRO",
            style: TextStyle(color: Colors.redAccent, fontFamily: 'Pixelate')),
        content: Text(
            "Tem certeza que deseja excluir o astro '${name.toUpperCase()}'?",
            style:
                const TextStyle(color: Colors.white70, fontFamily: 'Pixelate')),
        actions: [
          TextButton(
            child: const Text("CANCELAR",
                style:
                    TextStyle(color: Colors.white70, fontFamily: 'Pixelate')),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("EXCLUIR",
                style:
                    TextStyle(color: Colors.redAccent, fontFamily: 'Pixelate')),
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deletePlanet(id);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ASTROS CADASTRADOS",
            style:
                TextStyle(color: Colors.greenAccent, fontFamily: 'Pixelate')),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imgs/background.jpg",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.9),
                colorBlendMode: BlendMode.darken),
          ),
          StreamBuilder<List<Planet>>(
            stream: _firestoreService.getPlanetsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Erro ao carregar dados: ${snapshot.error}',
                        style: const TextStyle(
                            color: Colors.redAccent, fontFamily: 'Pixelate')));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: Colors.greenAccent));
              }

              final planets = snapshot.data ?? [];

              if (planets.isEmpty) {
                return const Center(
                    child: Text("Nenhum astro cadastrado. Adicione um!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontFamily: 'Pixelate')));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: planets.length,
                itemBuilder: (context, index) {
                  return _buildCard(planets[index]);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPage();
        },
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  Widget _buildCard(Planet planet) {
    Color planetColor = _hexToColor(planet.corPredominante);

    return GestureDetector(
      onTap: () {
        _showPage(planet: planet);
      },
      onLongPress: () {
        if (planet.id != null) {
          _confirmDelete(planet.id!, planet.nome);
        }
      },
      child: Card(
        color: Colors.black.withOpacity(0.7),
        shape: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: planetColor,
                  boxShadow: [
                    BoxShadow(
                      color: planetColor.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      planet.nome.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontFamily: 'Pixelate'),
                    ),
                    Text(
                      "Tipo: ${planet.tipo}",
                      style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white70,
                          fontFamily: 'Pixelate'),
                    ),
                    if (planet.massa != null && planet.massa! > 0)
                      Text(
                        "Massa: ${planet.massa} kg",
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                            fontFamily: 'Pixelate'),
                      ),
                    if (planet.diametro != null && planet.diametro! > 0)
                      Text(
                        "Diâmetro/Raio: ${planet.diametro} km",
                        style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.white70,
                            fontFamily: 'Pixelate'),
                      ),
                    Text(
                      "Cor Hex: ${planet.corPredominante}",
                      style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white70,
                          fontFamily: 'Pixelate'),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, color: Colors.greenAccent, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
