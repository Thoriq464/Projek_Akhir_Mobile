import 'package:flutter/material.dart';
import '../models/kosakata.dart';

class DetailKosakataScreen extends StatefulWidget {
  final Kosakata kosakata;

  const DetailKosakataScreen({Key? key, required this.kosakata}) : super(key: key);

  @override
  State<DetailKosakataScreen> createState() => _DetailKosakataScreenState();
}

class _DetailKosakataScreenState extends State<DetailKosakataScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section dengan AppBar custom
              _buildHeader(context),
              
              // Main Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Hero Card dengan kata utama
                        _buildHeroCard(),
                        const SizedBox(height: 24),
                        
                        // Grid layout untuk informasi
                        _buildInfoGrid(),
                        const SizedBox(height: 24),
                        
                        // Contoh kalimat section
                        if (widget.kosakata.contohKalimat != null || 
                            widget.kosakata.contohKalimatIndonesia != null)
                          _buildExampleSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Action buttons
                        // _buildActionButtons(),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildHeaderButton(
            icon: Icons.arrow_back_ios,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Detail Kata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Empty container untuk balance layout
          const SizedBox(width: 44), // Same width as button to center the title
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF1565C0),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1976D2),
            Color(0xFF1E88E5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Javanese text dengan style yang menonjol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.kosakata.kataJawa,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          
          // Indonesian translation
          Text(
            widget.kosakata.kataIndonesia,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Word type badge jika ada
          if (widget.kosakata.jenisKata != null && widget.kosakata.jenisKata!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                widget.kosakata.jenisKata!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    List<Widget> infoCards = [];
    
    // Translation card
    infoCards.add(_buildInfoCard(
      icon: Icons.translate,
      title: 'Terjemahan',
      subtitle: 'Bahasa Indonesia',
      content: widget.kosakata.kataIndonesia,
      color: const Color(0xFF4CAF50),
    ));
    
    // Word type card jika ada
    if (widget.kosakata.jenisKata != null && widget.kosakata.jenisKata!.isNotEmpty) {
      infoCards.add(_buildInfoCard(
        icon: Icons.category_outlined,
        title: 'Jenis Kata',
        subtitle: 'Kategori',
        content: widget.kosakata.jenisKata!,
        color: const Color(0xFF9C27B0),
      ));
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: infoCards,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Contoh Penggunaan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Contoh kalimat Jawa
          if (widget.kosakata.contohKalimat != null && widget.kosakata.contohKalimat!.isNotEmpty)
            _buildExampleItem(
              label: 'Jawa',
              text: widget.kosakata.contohKalimat!,
              isJavanese: true,
            ),
          
          // Contoh kalimat Indonesia
          if (widget.kosakata.contohKalimatIndonesia != null && widget.kosakata.contohKalimatIndonesia!.isNotEmpty)
            _buildExampleItem(
              label: 'Indonesia',
              text: widget.kosakata.contohKalimatIndonesia!,
              isJavanese: false,
            ),
        ],
      ),
    );
  }

  Widget _buildExampleItem({
    required String label,
    required String text,
    required bool isJavanese,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isJavanese ? const Color(0xFF1565C0).withOpacity(0.05) : const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isJavanese ? const Color(0xFF1565C0).withOpacity(0.2) : const Color(0xFF4CAF50).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isJavanese ? const Color(0xFF1565C0) : const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$text"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButtons() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _buildActionButton(
  //           icon: Icons.volume_up,
  //           label: 'Dengarkan',
  //           color: const Color(0xFF1565C0),
  //           onTap: () {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Fitur audio akan segera tersedia!'),
  //                 backgroundColor: Color(0xFF1565C0),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: _buildActionButton(
  //           icon: Icons.bookmark_add,
  //           label: 'Simpan',
  //           color: const Color(0xFFE91E63),
  //           onTap: () {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Disimpan ke favorit!'),
  //                 backgroundColor: Color(0xFFE91E63),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
