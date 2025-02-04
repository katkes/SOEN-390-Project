import 'package:flutter/material.dart';

class BuildingInformationPopup extends StatefulWidget {
  const BuildingInformationPopup({super.key});

  @override
  State<BuildingInformationPopup> createState() => _BuildingInformationPopupState();
}

class _BuildingInformationPopupState extends State<BuildingInformationPopup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,  // Background color of the container
        border: Border.all(
          color: Colors.black, // Border color
          width: 2,            // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      child: SizedBox(
        width: 180,
        height: 120,  // Adjusted height for better layout
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: 180,
              height: 80,  // Image height
              child: Image.asset(
                'assets/images/buildings/hall.png',
                width: 150,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 12,
              top: 85,  // Positioning the title just below the image
              child: Row(
                children: [
                  Text(
                    'Hall Building',
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'GillSans',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: 16),  // Space between the title and SGW button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff912338),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: const Center(
                      child: Text(
                        'SGW',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 8,
                          color: Colors.white,
                          fontFamily: 'GillSans',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              top: 110,  // Position for the address
              child: Text(
                '2065A Bishop St',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 12,
                  color: Color(0x7f000000),
                  fontFamily: 'GillSans',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
