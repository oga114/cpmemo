import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ThemeSettingsPage(),
    );
  }
}

class ThemeSettingsPage extends StatefulWidget {
  @override
  _ThemeSettingsPageState createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  // テーマモードの初期値を設定
  ThemeMode currentThemeMode = ThemeMode.light;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadData();
  }

  // SharedPreferencesからテーマモードを読み込むメソッド
  _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mode = prefs.getString('mode');
    setState(() {
      if (mode == 'dark') {
        currentThemeMode = ThemeMode.dark;
      } else {
        currentThemeMode = ThemeMode.light;
      }
    });
  }

  // SharedPreferencesにテーマモードを保存するメソッド
  _saveThemeMode(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String modeString = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString('mode', modeString);
  }

  // テーマモードを変更するメソッド
  void setThemeMode(ThemeMode mode) {
    currentThemeMode = mode;
    _saveThemeMode(mode);
  }

  // データをSharedPreferencesに保存するメソッド
  _saveData(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('textData', text);
  }

  // SharedPreferencesからデータを読み込むメソッド
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? text = prefs.getString('textData');
    if (text != null) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('com.cpmemo'),
        actions: [
          // コピー＆ペーストボタンを追加
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _controller.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('テキストをコピーしました')),
              );
            },
          ),
          // 「#」を入力するためのボタンを追加
          IconButton(
            icon: const Text('#'),
            onPressed: () {
              _controller.text += "#";
            },
          ),
          // ダークモード切り替えボタンを追加
          IconButton(
            icon: Icon(currentThemeMode == ThemeMode.light
                ? Icons.lightbulb_outline // ライトモード時は電球のアウトラインアイコン
                : Icons.lightbulb), // ダークモード時は電球アイコン
            onPressed: () {
              // テーマを切り替えるために、currentThemeModeを反転させる
              ThemeMode newThemeMode = currentThemeMode == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
              // 反転したテーマモードをセットする
              setThemeMode(newThemeMode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: 5000,
                maxLines: null, // 複数行入力を有効にする
                decoration: const InputDecoration(
                  hintText: 'ここに文章を入力',
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  // テキストが変更されるたびにデータを保存する
                  _saveData(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
