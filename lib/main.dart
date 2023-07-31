import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // テーマモードの初期値を設定
  static ThemeMode currentThemeMode = ThemeMode.light;

  // テーマモードを変更するメソッド
  static void setThemeMode(BuildContext context, ThemeMode mode) {
    currentThemeMode = mode;
    // MaterialAppを再構築してテーマモードを更新
    runApp(MyApp());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // ライトモードのテーマを設定
      darkTheme: ThemeData.dark(), // ダークモードのテーマを設定
      themeMode: currentThemeMode, // 現在のテーマモードをセット
      home: Scaffold(
        appBar: AppBar(
          title: const Text('com.cpmemo'),
          actions: [
            // コピー＆ペーストボタンを追加
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: HalfScreenTextArea.controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('テキストをコピーしました')),
                );
              },
            ),
            // 「#」を入力するためのボタンを追加
            IconButton(
              icon: const Text('#'),
              onPressed: () {
                HalfScreenTextArea.controller.text += "#";
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
                setThemeMode(context, newThemeMode);
              },
            ),
          ],
        ),
        body: const Center(
          child: HalfScreenTextArea(),
        ),
      ),
    );
  }
}

class HalfScreenTextArea extends StatefulWidget {
  // コントローラーをパブリックに変更
  static TextEditingController controller = TextEditingController();

  const HalfScreenTextArea({Key? key});

  @override
  _HalfScreenTextAreaState createState() => _HalfScreenTextAreaState();
}

class _HalfScreenTextAreaState extends State<HalfScreenTextArea> {
  @override
  void initState() {
    super.initState();
    // アプリ起動時にSharedPreferencesからデータを読み込む
    _loadData();
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
      HalfScreenTextArea.controller.text = text;
    }
  }

  @override
  void dispose() {
    HalfScreenTextArea.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: HalfScreenTextArea.controller,
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
    );
  }
}
