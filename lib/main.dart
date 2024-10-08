import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letter_counter/camera_viewer.dart';

late List<CameraDescription> _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '서예용 글자수 세기',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final tfController = TextEditingController();

  final hangulRegex = RegExp(r'[가-힣]');
  final emptyRegex = RegExp(r'\s+');

  String inputText = '';

  @override
  void dispose() {
    tfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String onlyHangul = hangulRegex.allMatches(inputText).map((e) => e.group(0) ?? '').join();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: CameraViewer(camera: _cameras.first),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('한글만: ${onlyHangul.length}', style: const TextStyle(color: Colors.redAccent)),
                    Text('공백 제외: ${inputText.replaceAll(emptyRegex, '').length}', style: const TextStyle(color: Colors.green)),
                    Text('모든 문자: ${inputText.length}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        Clipboard.getData('text/plain').then((value) {
                          tfController.text = value?.text ?? '';
                          inputText = value?.text ?? '';
                        });
                        tfController.clear();
                        inputText = '';
                      }),
                      child: const Text('붙여넣기'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        tfController.clear();
                        inputText = '';
                      }),
                      child: const Text('초기화'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: tfController,
                  onChanged: (value) => setState(() {
                    inputText = value;
                  }),
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: '글자수 세기',
                    hintText: '글자수를 세고 싶은 글을 입력하세요.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  minLines: 10,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
