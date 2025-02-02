import 'package:flutter/material.dart';
import 'dart:js' as js;

/// Main entry point of the application, launching the [MyApp] widget.
void main() {
  runApp(const MyApp());
}

/// The main application widget.
///
/// Creates an application with the title "Flutter Demo" and displays the [HomePage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

/// The main page of the application, containing an image and control buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State for the [HomePage].
class _HomePageState extends State<HomePage> {
  /// Controller for the image URL input field.
  late final TextEditingController _urlController;

  /// The current image URL.
  String _imageUrl = '';

  /// Flag indicating the menu state.
  bool _isMenuOpen = false;

  @override
  void initState() {
    _urlController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Loads an image from the entered URL.
  void _loadImage() {
    setState(() {
      _imageUrl = _urlController.text;
    });
  }

  /// Toggles full-screen mode.
  void _toggleFullScreen() {
    js.context.callMethod('eval', [
      """
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
      } else if (document.exitFullscreen) {
        document.exitFullscreen();
      }
      """
    ]);
  }

  /// Enters full-screen mode.
  void _enterFullscreen() {
    js.context.callMethod("eval", ["document.documentElement.requestFullscreen();"]);
    _toggleMenu();
  }

  /// Exits full-screen mode.
  void _exitFullscreen() {
    js.context.callMethod("eval", ["document.exitFullscreen();"]);
    _toggleMenu();
  }

  /// Toggles the menu state.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              AppBar(
                toolbarHeight: 64,
                title: const Text("Image Loader"),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: _toggleFullScreen,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _imageUrl.isEmpty
                                  ? const Center(child: Text("No Image"))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _imageUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(child: Text("Error loading image"));
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              decoration: const InputDecoration(hintText: 'Image URL'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 48.0),
                            child: ElevatedButton(
                              onPressed: _loadImage,
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                                child: Icon(Icons.arrow_forward),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withAlpha(150),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isMenuOpen)
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: _enterFullscreen,
                            child: Text("Enter fullscreen"),
                          ),
                          Divider(height: 1, color: Colors.grey),
                          TextButton(
                            onPressed: _exitFullscreen,
                            child: Text("Exit fullscreen"),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: _toggleMenu,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
