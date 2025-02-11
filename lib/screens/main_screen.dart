import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/customButton.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../widgets/buttomNav.dart';
import '../utils/tflite_helper.dart';
import '../services/history_service.dart';

class MainScreen extends StatefulWidget {
  final User? user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          MainContentScreen(user: widget.user),
          const HistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MainContentScreen extends StatelessWidget {
  final User? user;

  const MainContentScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Stack(
          children: [
            const SizedBox(
              height: 800,
              width: double.infinity,
            ),
            const Header(),
            Positioned(top: 130, left: 0, right: 0, child: Content(user: user)),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 80),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF02243D),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Image.asset('assets/images/logoPutih.png', width: 120),
          const SizedBox(height: 10),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Deteksi ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' Dini ASD Untuk Pengobatan Terbaik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Content extends StatefulWidget {
  final User? user;

  const Content({Key? key, required this.user}) : super(key: key);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  Map<String, double>? _classificationResult;
  final HistoryService _HistoryService = HistoryService();

  Future<void> _pickImage(ImageSource source) async {
    var image = await _picker.pickImage(source: source);
    if (image == null) {
      // print("No image selected");
      return;
    }
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    _classifyImage(File(image.path));
  }

  Future<void> _classifyImage(File image) async {
    final tfliteHelper = TFLiteHelper();
    Map<String, double> result = await tfliteHelper.classifyImage(image);
    setState(() {
      _loading = false;
      _classificationResult = result;
    });

    if (widget.user != null) {
      try {
        String imageUrl =
            await _HistoryService.uploadImage(image, widget.user!.uid);

        double confidence = double.parse(
          (_classificationResult!.values.reduce((a, b) => a > b ? a : b) * 100)
              .toStringAsFixed(2),
        );

        await _HistoryService.addToHistory(
          imageUrl,
          getClassificationLabel(),
          confidence,
          widget.user!.uid,
        );
      } catch (e) {
        print('Error uploading image and saving to history: $e');
      }
    }
  }


  Color getResultColor() {
    if (_classificationResult != null && _classificationResult!.isNotEmpty) {
      String classification = _classificationResult!.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      if (classification == 'Autistic') {
        return Colors.red;
      } else if (classification == 'Non Autistic') {
        return Colors.green;
      } else {
        return Colors.black;
      }
    } else {
      return Colors.black;
    }
  }

  String getConfidencePercentage() {
    if (_classificationResult != null && _classificationResult!.isNotEmpty) {
      double confidence =
          _classificationResult!.values.reduce((a, b) => a > b ? a : b);
      return '${(confidence * 100).toStringAsFixed(2)}%';
    } else {
      return '';
    }
  }

  String getClassificationLabel() {
    if (_classificationResult != null && _classificationResult!.isNotEmpty) {
      return _classificationResult!.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    } else {
      return 'N/A';
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 54),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 3, color: Color(0xFF012139)),
                borderRadius: BorderRadius.circular(15),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _image != null
                    ? Image.file(
                        _image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.perm_media_outlined, size: 50),
                          SizedBox(height: 6),
                          Text(
                            'Gambar Belum Diunggah',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: CustomButton(
              text: 'Unggah Gambar',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              onPressed: _showImagePickerOptions,
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              width: 285,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF034B6C),
                  Color(0xFF033B59),
                  Color(0xFF012139),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: 285,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 17),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Terklasifikasi sebagai:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getClassificationLabel(),
                          style: TextStyle(
                            color: getResultColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _classificationResult != null &&
                                  _classificationResult!.isNotEmpty
                              ? '(${getConfidencePercentage()})'
                              : '',
                          style: TextStyle(
                            color: getResultColor().withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/example');
            },
            child: const Text(
              'Lihat Contoh Gambar Yang Disarankan?',
              style: TextStyle(
                color: Color(0xFF02243D),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
