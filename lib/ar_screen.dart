import 'package:flutter/material.dart';
import 'ar_view_local.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Augmented Reality',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              color: Colors.black,
              fontSize: 22,
              letterSpacing: 0.0,
            ),
          ),
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Center(
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () async {
                await openingARV(context);
              },
              child: Container(
                width: 250,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await openingARV(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Launch AR',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openingARV(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AugmentedRealityView()),
    );
  }
}