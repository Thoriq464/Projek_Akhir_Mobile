import 'package:flutter/material.dart';
// import '../widgets/kosakata_tile.dart';
import 'detail_kosakata_screen.dart';
import '../models/kosakata.dart';
import '../services/api_service.dart';

class DaftarKosakataScreen extends StatefulWidget {
  const DaftarKosakataScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKosakataScreen> createState() => _DaftarKosakataScreenState();
}

class _DaftarKosakataScreenState extends State<DaftarKosakataScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  List<Kosakata> _daftarKosakata = [];
  List<Kosakata> _daftarKosakataTerfilter = [];

  @override
  void initState() {
    super.initState();
    _loadKosakata();
  }
  Future<void> _loadKosakata() async {
    try {
      List<Kosakata> data = await apiService.getDaftarKosakata();
      setState(() {
        _daftarKosakata = data;
        _daftarKosakataTerfilter = data;
        _sortKosakata();
      });
    } catch (e) {
      print('Error loading kosakata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kosakata: $e')),
      );
    }
  }

  void _filterKosakata(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      if (keyword.isEmpty) {
        _daftarKosakataTerfilter = _daftarKosakata;
      } else {
        _daftarKosakataTerfilter = _daftarKosakata
            .where((kosakata) =>
                kosakata.kataJawa.toLowerCase().contains(keyword.toLowerCase()) ||
                kosakata.kataIndonesia.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
      _sortKosakata();
    });
  }
  void _sortKosakata() {
    setState(() {
      _daftarKosakataTerfilter.sort((a, b) => a.kataJawa.toLowerCase().compareTo(b.kataJawa.toLowerCase()));
    });
  }

  Map<String, List<Kosakata>> _groupKosakataByAlphabet() {
    Map<String, List<Kosakata>> groupedKosakata = {};
    
    for (var kosakata in _daftarKosakataTerfilter) {
      String firstLetter = kosakata.kataJawa.isNotEmpty 
          ? kosakata.kataJawa[0].toUpperCase() 
          : '#';
      
      if (!groupedKosakata.containsKey(firstLetter)) {
        groupedKosakata[firstLetter] = [];
      }
      groupedKosakata[firstLetter]!.add(kosakata);
    }
    
    // Sort the keys alphabetically
    var sortedKeys = groupedKosakata.keys.toList()..sort();
    Map<String, List<Kosakata>> sortedGroupedKosakata = {};
    for (String key in sortedKeys) {
      sortedGroupedKosakata[key] = groupedKosakata[key]!;
    }
    
    return sortedGroupedKosakata;
  }

  Widget _buildAlphabetHeader(String letter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1976D2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKosakataGridItem(Kosakata kosakata) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailKosakataScreen(
              kosakata: kosakata,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.translate,
                      color: Color(0xFF1565C0),
                      size: 14,
                    ),
                  ),
                  if (kosakata.jenisKata != null && kosakata.jenisKata!.isNotEmpty)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kosakata.jenisKata!,
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9C27B0),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Kata Jawa
              Text(
                kosakata.kataJawa,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Kata Indonesia
              Expanded(
                child: Text(
                  kosakata.kataIndonesia,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 6),

              // Bottom indicator
              Container(
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(        slivers: [          SliverAppBar(
            expandedHeight: 220.0, // Dikurangi untuk mengurangi jarak
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF1565C0),
                      Color(0xFF0D47A1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JavDict',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Temukan arti kata-kata Jowo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),                          ],                        ),
                        const SizedBox(height: 16),                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari kata Jawa...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF1565C0),
                                size: 20,
                              ),
                              suffixIcon: _searchKeyword.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterKosakata('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            onChanged: _filterKosakata,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),                        ),
                        const SizedBox(height: 8),
                        // Statistics Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.library_books_rounded,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_daftarKosakata.length} kata tersedia',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_searchKeyword.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.filter_list_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_daftarKosakataTerfilter.length} hasil',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Loading State
          if (_daftarKosakata.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memuat kosakata...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),          // Empty State
          if (_daftarKosakata.isNotEmpty && _daftarKosakataTerfilter.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada hasil ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Coba dengan kata kunci lain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Kosakata Grid dengan Alphabet Headers
          if (_daftarKosakataTerfilter.isNotEmpty)
            ...(_groupKosakataByAlphabet().entries.map((entry) {
              String letter = entry.key;
              List<Kosakata> kosakataList = entry.value;
              
              return [
                // Alphabet Header
                SliverToBoxAdapter(
                  child: _buildAlphabetHeader(letter),
                ),
                // Grid untuk huruf ini
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildKosakataGridItem(kosakataList[index]);
                      },
                      childCount: kosakataList.length,
                    ),
                  ),
                ),
              ];
            }).expand((list) => list)),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Space for FAB
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/chatbot');
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text(
          'Chatbot Jawa',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
