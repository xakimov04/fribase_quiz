import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fribase/views/screens/admin_panel.dart';
import 'package:fribase/views/screens/home_screen.dart';
import 'package:gap/gap.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 30, top: 90, bottom: 55),
          color: const Color(0xff041955),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(),
              const Gap(20),
              const Gap(50),
              _buildDrawerItem(Icons.grid_view, 'Home', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }),
              _buildDrawerItem(
                  Icons.admin_panel_settings_outlined, 'Admin Page', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionForm(),
                  ),
                );
              }),
              const Spacer(),
              const Text(
                "Good",
                style: TextStyle(fontSize: 15, color: Color(0xff354B8C)),
              ),
              const Text(
                'Consistency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 45,
          right: 30,
          bottom: 140,
          child: Image.asset(
            fit: BoxFit.fill,
            "assets/images/line.png",
            height: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xffEB06FF),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xff0A215E),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/logo.gif'),
              radius: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            const Gap(20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
