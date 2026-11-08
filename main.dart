import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('baby_theme');
  runApp(BabyBloomApp(initialTheme: saved));
}

enum BabyTheme { defaultTheme, girl, boy }

class Palette {
  final Color primary, secondary, background, surface, accent, text;
  const Palette(this.primary, this.secondary, this.background, this.surface,
      this.accent, this.text);

  static const neutral = Palette(
    Color(0xFFE9A9C4), Color(0xFFA8B99B), Color(0xFFFFF8F5),
    Colors.white, Color(0xFFCF6F9A), Color(0xFF493541));
  static const girl = Palette(
    Color(0xFFF0A9C7), Color(0xFFA8B99B), Color(0xFFFFF7F8),
    Colors.white, Color(0xFFD95791), Color(0xFF493541));
  static const boy = Palette(
    Color(0xFF9BCDE8), Color(0xFFA8B99B), Color(0xFFF4FAFD),
    Colors.white, Color(0xFF4B9BC7), Color(0xFF304653));

  static Palette from(BabyTheme theme) => switch (theme) {
    BabyTheme.girl => girl,
    BabyTheme.boy => boy,
    BabyTheme.defaultTheme => neutral,
  };
}

class BabyBloomApp extends StatefulWidget {
  final String? initialTheme;
  const BabyBloomApp({super.key, this.initialTheme});

  @override
  State<BabyBloomApp> createState() => _BabyBloomAppState();
}

class _BabyBloomAppState extends State<BabyBloomApp> {
  late BabyTheme theme;
  late bool setupComplete;

  @override
  void initState() {
    super.initState();
    setupComplete = widget.initialTheme != null;
    theme = BabyTheme.values.firstWhere(
      (e) => e.name == widget.initialTheme,
      orElse: () => BabyTheme.defaultTheme,
    );
  }

  Future<void> changeTheme(BabyTheme value) async {
    setState(() { theme = value; setupComplete = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baby_theme', value.name);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.from(theme);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BabyBloom',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: p.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: p.primary,
          primary: p.accent,
          surface: p.surface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: p.background,
          foregroundColor: p.text,
          centerTitle: true,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: p.surface,
          indicatorColor: p.primary.withOpacity(.25),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(color: p.text, fontSize: 11),
          ),
        ),
      ),
      home: setupComplete
          ? HomeScreen(palette: p, theme: theme, onThemeChanged: changeTheme)
          : ThemeSetup(palette: p, onChoose: changeTheme),
    );
  }
}

class ThemeSetup extends StatelessWidget {
  final Palette palette;
  final ValueChanged<BabyTheme> onChoose;
  const ThemeSetup({super.key, required this.palette, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.local_florist_rounded, size: 76, color: palette.accent),
              const SizedBox(height: 12),
              Text('BabyBloom', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                  color: palette.text, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text('Cada pequeño momento, una obra de arte.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.text, fontSize: 16)),
              const SizedBox(height: 44),
              Text('¿Para quién crearemos recuerdos?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: palette.text)),
              const SizedBox(height: 20),
              _ChoiceCard(title: 'Es una niña', subtitle: 'Tonos rosa y suaves',
                icon: Icons.local_florist, color: Palette.girl.primary,
                onTap: () => onChoose(BabyTheme.girl)),
              const SizedBox(height: 12),
              _ChoiceCard(title: 'Es un niño', subtitle: 'Tonos azul cielo y suaves',
                icon: Icons.cloud, color: Palette.boy.primary,
                onTap: () => onChoose(BabyTheme.boy)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => onChoose(BabyTheme.defaultTheme),
                child: const Text('Prefiero elegir más tarde'),
              ),
              const Spacer(),
              Text('Puedes cambiar los colores cuando quieras desde Ajustes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.text.withOpacity(.7), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ChoiceCard({required this.title, required this.subtitle,
    required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: color.withOpacity(.23),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final Palette palette;
  final BabyTheme theme;
  final ValueChanged<BabyTheme> onThemeChanged;
  const HomeScreen({super.key, required this.palette, required this.theme,
    required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(p: widget.palette),
      _SimpleTab(p: widget.palette, title: 'Mis fotos',
        subtitle: 'Tus recuerdos aparecerán aquí cuando generes imágenes.',
        icon: Icons.photo_library_outlined),
      _SimpleTab(p: widget.palette, title: 'Crecimiento mensual',
        subtitle: 'Guarda un recuerdo especial de cada mes de tu bebé.',
        icon: Icons.calendar_month_outlined),
      SettingsTab(p: widget.palette, current: widget.theme,
        onThemeChanged: widget.onThemeChanged),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('BabyBloom', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(Icons.local_florist, color: widget.palette.accent),
        ),
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), label: 'Mis fotos'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Crecimiento'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final Palette p;
  const _HomeTab({required this.p});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [p.primary.withOpacity(.45), p.secondary.withOpacity(.25)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Pequeños momentos, grandes recuerdos',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: p.text)),
          const SizedBox(height: 8),
          Text('Crea fotografías especiales de tu bebé con ayuda de la IA.',
            style: TextStyle(color: p.text)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Crear fotos con IA'),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      Text('Explora BabyBloom', style: TextStyle(fontSize: 19,
        fontWeight: FontWeight.bold, color: p.text)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.18,
        children: [
          _FeatureTile(icon: Icons.palette_outlined, title: 'Temáticas', p: p),
          _FeatureTile(icon: Icons.favorite_border, title: 'Favoritos', p: p),
          _FeatureTile(icon: Icons.photo_camera_outlined, title: 'Sesiones IA', p: p),
          _FeatureTile(icon: Icons.cake_outlined, title: 'Mi primer año', p: p),
        ],
      ),
      const SizedBox(height: 20),
      Text('Tu espacio privado de recuerdos',
        textAlign: TextAlign.center, style: TextStyle(color: p.text.withOpacity(.7))),
    ],
  );
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Palette p;
  const _FeatureTile({required this.icon, required this.title, required this.p});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: p.primary.withOpacity(.18),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 32, color: p.accent),
      const SizedBox(height: 8),
      Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: p.text)),
    ]),
  );
}

class _SimpleTab extends StatelessWidget {
  final Palette p;
  final String title, subtitle;
  final IconData icon;
  const _SimpleTab({required this.p, required this.title,
    required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: p.accent),
        const SizedBox(height: 16),
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: p.text)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center,
          style: TextStyle(color: p.text.withOpacity(.75))),
      ]),
    ),
  );
}

class SettingsTab extends StatelessWidget {
  final Palette p;
  final BabyTheme current;
  final ValueChanged<BabyTheme> onThemeChanged;
  const SettingsTab({required this.p, required this.current, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Apariencia', style: TextStyle(fontSize: 21,
        fontWeight: FontWeight.bold, color: p.text)),
      const SizedBox(height: 12),
      RadioListTile<BabyTheme>(
        value: BabyTheme.girl, groupValue: current,
        title: const Text('Tema rosa'), subtitle: const Text('Rosa pastel y verde salvia'),
        onChanged: (v) { if (v != null) onThemeChanged(v); }),
      RadioListTile<BabyTheme>(
        value: BabyTheme.boy, groupValue: current,
        title: const Text('Tema azul'), subtitle: const Text('Azul cielo y verde salvia'),
        onChanged: (v) { if (v != null) onThemeChanged(v); }),
      RadioListTile<BabyTheme>(
        value: BabyTheme.defaultTheme, groupValue: current,
        title: const Text('Tema predeterminado'), subtitle: const Text('Paleta neutral'),
        onChanged: (v) { if (v != null) onThemeChanged(v); }),
      const Divider(),
      const ListTile(leading: Icon(Icons.lock_outline),
        title: Text('Privacidad y seguridad'),
        subtitle: Text('La protección de las fotos se configurará antes del lanzamiento.')),
      const ListTile(leading: Icon(Icons.info_outline),
        title: Text('Acerca de BabyBloom'), subtitle: Text('Versión de prototipo 0.1.0')),
    ],
  );
}

void _showComingSoon(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Próximamente'),
      content: const Text('La generación de fotografías con IA se conectará en una siguiente etapa.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
    ),
  );
}
