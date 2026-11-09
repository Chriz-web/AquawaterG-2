import 'package:flutter/material.dart';

void main() {
  runApp(
    WaterProviderScope(
      child: const AquaSanApp(),
    ),
  );
}

class WaterProviderScope extends StatefulWidget {
  final Widget child;

  const WaterProviderScope({super.key, required this.child});

  @override
  State<WaterProviderScope> createState() => _WaterProviderScopeState();
}

class _WaterProviderScopeState extends State<WaterProviderScope> {
  final WaterProvider _waterProvider = WaterProvider();

  @override
  void dispose() {
    _waterProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _WaterProviderInherited(
        notifier: _waterProvider,
        child: widget.child,
      );
}

class _WaterProviderInherited extends InheritedNotifier<WaterProvider> {
  const _WaterProviderInherited({
    required super.notifier,
    required super.child,
  });
}

extension WaterProviderContext on BuildContext {
  T watch<T>() {
    final inherited = dependOnInheritedWidgetOfExactType<_WaterProviderInherited>();
    if (inherited?.notifier is T) return inherited!.notifier as T;
    throw FlutterError('No $T found above this context.');
  }

  T read<T>() {
    final element = getElementForInheritedWidgetOfExactType<_WaterProviderInherited>();
    final inherited = element?.widget as _WaterProviderInherited?;
    if (inherited?.notifier is T) return inherited!.notifier as T;
    throw FlutterError('No $T found above this context.');
  }
}

// ========================================
// PROVIDER
// ========================================

class WaterProvider extends ChangeNotifier {
  String waterStatus = 'No Water';

  final List<Map<String, String>> reports = [];

  void updateStatus(String status) {
    waterStatus = status;
    notifyListeners();
  }

  void addReport(String type, String purok, String details) {
    reports.add({
      'type': type,
      'purok': purok,
      'details': details,
    });

    notifyListeners();
  }
}

// ========================================
// USER PROFILE MODEL
// ========================================

class UserProfile {
  final String name;
  final String barangay;

  UserProfile(this.name, this.barangay);
}

// ========================================
// MAIN APP
// ========================================

class AquaSanApp extends StatelessWidget {
  const AquaSanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaSan Rafael',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF123B68),
        ),
      ),

      // NAMED ROUTES
      initialRoute: '/',

      routes: {
        '/': (context) => const HomePage(),
        '/navigator': (context) => const NavigatorPage(),
        '/report': (context) => const ReportPage(),
        '/history': (context) => const HistoryPage(),
        '/announcements': (context) =>
            const AnnouncementPage(),
      },

      // PASSING OF DATA
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final user = settings.arguments as UserProfile;

          return MaterialPageRoute(
            builder: (context) => ProfilePage(user: user),
          );
        }

        return null;
      },
    );
  }
}

// ========================================
// HOME PAGE
// ========================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'AquaSan Rafael',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Navigator',
            icon: const Icon(Icons.navigation),
            onPressed: () {
              Navigator.pushNamed(context, '/navigator');
            },
          ),

          IconButton(
            tooltip: 'Announcements',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.pushNamed(context, '/announcements');
            },
          ),

          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: UserProfile(
                  'San Rafael Resident',
                  'San Rafael, Castilla, Sorsogon',
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // WATER STATUS CARD

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1675C8),
                  Color(0xFF36B4DC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S STATUS",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 12),

                const Text(
                  'San Rafael',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  '💧 ${water.waterStatus.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Water supply updates for your community.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Barangay Overview',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B68),
            ),
          ),

          const SizedBox(height: 12),

          _barangayRow(
            'San Rafael (Poblacion)',
            water.waterStatus,
          ),

          _barangayRow('Purok 1', 'Low Pressure'),
          _barangayRow('Purok 2', 'No Water'),
          _barangayRow('Purok 3', 'Available'),
          _barangayRow('Purok 4', 'Low Pressure'),

          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B68),
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,

            children: [
              _actionCard(
                context,
                Icons.navigation,
                'Navigator',
                '/navigator',
              ),

              _actionCard(
                context,
                Icons.water_drop,
                'Report Water Issue',
                '/report',
              ),

              _actionCard(
                context,
                Icons.bar_chart,
                'Water History',
                '/history',
              ),

              _actionCard(
                context,
                Icons.notifications,
                'Announcements',
                '/announcements',
              ),

              _actionCard(
                context,
                Icons.person,
                'My Profile',
                '/profile',
                profile: true,
              ),
            ],
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Column(
              children: [
                Text(
                  'Our Goal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1675C8),
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'To keep every household informed about water supply status, schedules, and updates in San Rafael.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Save Water, Save Life. 💙',
              style: TextStyle(
                fontSize: 19,
                color: Color(0xFF1675C8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/navigator');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/report');
          } else if (index == 3) {
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: UserProfile(
                'San Rafael Resident',
                'San Rafael, Castilla, Sorsogon',
              ),
            );
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.navigation),
            label: 'Navigator',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // BARANGAY ROW

  Widget _barangayRow(String name, String status) {
    Color statusColor;

    if (status == 'Available') {
      statusColor = Colors.green;
    } else if (status == 'Low Pressure') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCEAF5)),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ACTION CARD

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String route, {
    bool profile = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),

      onTap: () {
        if (profile) {
          Navigator.pushNamed(
            context,
            '/profile',
            arguments: UserProfile(
              'San Rafael Resident',
              'San Rafael, Castilla, Sorsogon',
            ),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFDCEAF5)),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: const Color(0xFF1675C8),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// NAVIGATOR PAGE
// ========================================

class NavigatorPage extends StatelessWidget {
  const NavigatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigator'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.navigation,
            size: 70,
            color: Color(0xFF1675C8),
          ),

          const SizedBox(height: 15),

          const Text(
            'AquaSan Rafael Navigation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B68),
            ),
          ),

          const SizedBox(height: 25),

          _navigationButton(
            context,
            'Home Page',
            Icons.home,
            '/',
          ),

          _navigationButton(
            context,
            'Report Water Issue',
            Icons.water_drop,
            '/report',
          ),

          _navigationButton(
            context,
            'Water Supply History',
            Icons.bar_chart,
            '/history',
          ),

          _navigationButton(
            context,
            'Announcements',
            Icons.notifications,
            '/announcements',
          ),

          const SizedBox(height: 10),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: UserProfile(
                  'San Rafael Resident',
                  'San Rafael, Castilla, Sorsogon',
                ),
              );
            },

            icon: const Icon(Icons.person),

            label: const Text('Profile Page'),

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Navigator.pushNamed() is used to open another screen using its route name.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _navigationButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },

        icon: Icon(icon),
        label: Text(title),

        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// ========================================
// PROFILE PAGE
// ========================================

class ProfilePage extends StatelessWidget {
  final UserProfile user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),

      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),

          child: Padding(
            padding: const EdgeInsets.all(30),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFDDEFFC),

                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFF1675C8),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  user.barangay,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                const Chip(
                  avatar: Icon(Icons.verified_user),
                  label: Text('Community Resident'),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Your profile information is passed from the Home Page using Navigator.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// REPORT WATER ISSUE
// ========================================

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // setState() updates the selected values.

  String type = 'No Water';
  String purok = 'Purok 1';

  final detailsController = TextEditingController();

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Water Issue'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tell us about the problem.',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text('Report Type'),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: type,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),

            items: const [
              DropdownMenuItem(
                value: 'No Water',
                child: Text('No Water'),
              ),

              DropdownMenuItem(
                value: 'Low Pressure',
                child: Text('Low Pressure'),
              ),

              DropdownMenuItem(
                value: 'Leak',
                child: Text('Leak'),
              ),

              DropdownMenuItem(
                value: 'Other',
                child: Text('Other'),
              ),
            ],

            onChanged: (value) {
              if (value != null) {
                setState(() {
                  type = value;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          const Text('Purok / Location'),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: purok,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),

            items: const [
              DropdownMenuItem(
                value: 'Purok 1',
                child: Text('Purok 1'),
              ),

              DropdownMenuItem(
                value: 'Purok 2',
                child: Text('Purok 2'),
              ),

              DropdownMenuItem(
                value: 'Purok 3',
                child: Text('Purok 3'),
              ),

              DropdownMenuItem(
                value: 'Purok 4',
                child: Text('Purok 4'),
              ),

              DropdownMenuItem(
                value: 'Poblacion',
                child: Text('Poblacion'),
              ),
            ],

            onChanged: (value) {
              if (value != null) {
                setState(() {
                  purok = value;
                });
              }
            },
          ),

          const SizedBox(height: 20),

          const Text('Details / Description'),

          const SizedBox(height: 8),

          TextField(
            controller: detailsController,
            maxLines: 4,

            decoration: const InputDecoration(
              hintText: 'Describe the water problem...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: () {
                if (detailsController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter the details.',
                      ),
                    ),
                  );

                  return;
                }

                // PROVIDER: save the report.

                context.read<WaterProvider>().addReport(
                      type,
                      purok,
                      detailsController.text.trim(),
                    );

                Navigator.pushReplacementNamed(
                  context,
                  '/history',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted!'),
                  ),
                );
              },

              icon: const Icon(Icons.send),

              label: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Submit Report'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// WATER SUPPLY HISTORY
// ========================================

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Supply History'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: const Color(0xFFDDEFFC),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Text(
              'Total Reports: ${water.reports.length}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123B68),
              ),
            ),
          ),

          const SizedBox(height: 15),

          if (water.reports.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text('No reports submitted yet.'),
              ),
            ),

          ...water.reports.map(
            (report) => Card(
              color: Colors.white,

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDDEFFC),
                  child: Icon(
                    Icons.water_drop,
                    color: Colors.blue,
                  ),
                ),

                title: Text(
                  '${report['type']} - ${report['purok']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(report['details']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// ANNOUNCEMENTS PAGE
// ========================================

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements & Updates'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            color: Colors.white,

            child: ListTile(
              leading: Icon(
                Icons.campaign,
                color: Colors.blue,
              ),

              title: Text('Water Supply Advisory'),

              subtitle: Text(
                'Please check your barangay water status regularly.',
              ),
            ),
          ),

          Card(
            color: Colors.white,

            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.blue,
              ),

              title: Text('Service Updates'),

              subtitle: Text(
                'Residents can report water interruptions using the app.',
              ),
            ),
          ),

          Card(
            color: Colors.white,

            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.blue,
              ),

              title: Text('Project Information'),

              subtitle: Text(
                'AquaSan Rafael is a student project prototype.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
