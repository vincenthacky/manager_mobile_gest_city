import 'package:flutter/material.dart';
import 'admin_cotisations_page.dart';

class CotisationsPage extends StatefulWidget {
  const CotisationsPage({super.key});

  @override
  State<CotisationsPage> createState() => _CotisationsPageState();
}

class _CotisationsPageState extends State<CotisationsPage> {
  @override
  Widget build(BuildContext context) {
    return const AdminCotisationsPage();
  }
}