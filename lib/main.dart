import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import 'uitls/is_youtube_link.dart';
import 'uitls/miniplayer.dart';
import 'uitls/run_python_script.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Future<void> configureWindow() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(500, 0),
      alwaysOnTop: true,
      minimumSize: Size(100, 2),
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAlignment(Alignment.topCenter, animate: true);
      final postion = await windowManager.getPosition();
      await windowManager.setAsFrameless();
      await windowManager.setHasShadow(false);
      await windowManager.setPosition(Offset(
        postion.dx,
        -33,
      ));
      await windowManager.setOpacity(1);
    });
  }

  @override
  void initState() {
    super.initState();
    configureWindow();
  }

  bool isFullScreen = false;
  bool show = false;
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (vale) async {
        await miniplayer(isFullScreen);
      },
      onExit: (_) async {
        await docked(isFullScreen);
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.pink],
              ),
            ),
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        width: 25,
                        child: IconButton(
                          onPressed: () async {
                            await configureWindow();
                          },
                          icon: const Icon(
                            Icons.adjust_rounded,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 60,
                              child: InkWell(
                                onTap: _launchUrl,
                                child: Image.asset(
                                  'assets/icons/microphone.png',
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 340,
                              height: 50,
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      await _paste();
                                    },
                                    icon: const Icon(Icons.paste),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple),
                                onPressed: () async {
                                  await _play(_controller.text.trim());
                                },
                                child: const Text("Play"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(
                  width: 120,
                  height: 9,
                  // child: Divider(
                  //   color: Colors.grey.shade500,
                  //   thickness: 2.5,
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    const url = "https://www.youtube.com/";
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  _paste() async {
    ClipboardData? data = await Clipboard.getData("text/plain");
    if (data != null) {
      if (data.text != null) {
        if (data.text!.isNotEmpty) {
          if (isYouTubeLink(data.text!)) {
            _controller.value = TextEditingValue(
              text: data.text!,
            );
          }
        }
      }
    }
  }

  _play(String text) async {
    if (isYouTubeLink(text)) {
      await runPythonScript(text);
    }
  }
}
