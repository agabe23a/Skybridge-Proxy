import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const SkybridgeApp());
}

class SkybridgeApp extends StatelessWidget {
  const SkybridgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skybridge Proxy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = false;
  String _statusMessage = "Ready to Connect";
  // The Mock US IP we want to visualize
  String _mockedUSIP = "172.67.18.243 (United States)"; 

  void _handleConnection() {
    setState(() {
      _isLoading = true;
      _statusMessage = "Authenticating with US Master Control...";
    });

    // MOCK DELAY: Simulating network request to your Python API
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      // MOCK SUCCESS
      setState(() {
        _isLoading = false;
        _isConnected = true;
        _statusMessage = "Connected Securely via US-East Gateway";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("IP Mapping Successful.")),
      );
    });
  }

  void _handleDisconnect() {
    setState(() {
      _isConnected = false;
      _statusMessage = "Ready to Connect";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SKYBRIDGE PROXY"),
        backgroundColor: Colors.black12,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      _isConnected ? Icons.verified_user : Icons.gpp_maybe,
                      size: 64,
                      color: _isConnected ? Colors.green : Colors.orangeAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (_isConnected) ...[
                      const SizedBox(height: 15),
                      const Text("Current Digital Identity:", style: TextStyle(color: Colors.grey)),
                      Text(
                        _mockedUSIP,
                        style: const TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Username Input (if not connected)
            if (!_isConnected)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  hintText: "Enter your assigned username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
            const SizedBox(height: 20),

            // Connect/Disconnect Button
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _isConnected ? _handleDisconnect : _handleConnection,
                style: ElevatedButton.styleFrom(
                  primary: _isConnected ? Colors.redAccent : Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _isConnected ? "DISCONNECT" : "CONNECT TO US SERVER",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
