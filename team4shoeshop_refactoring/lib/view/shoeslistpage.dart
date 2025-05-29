import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/vm/1_provider.dart';
import 'cart.dart';
import 'edit_profile_page.dart';
import 'location_search.dart';
import 'orderviewpage.dart';
import 'returns.dart';
import 'shoes_detail_page.dart';

class Shoeslistpage extends ConsumerWidget {
  const Shoeslistpage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoesAsync = ref.watch(shoesProvider);
    final searchText = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('상품 구매 화면'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long),
            tooltip: '주문내역',
            onPressed: () => Get.to(() => OrderViewPage()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          Expanded(
            child: shoesAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("에러: $err")),
              data: (products) {
                final filtered = products.where((p) =>
                  p['pname'].toString().toLowerCase().contains(searchText.toLowerCase())
                ).toList();

                if (filtered.isEmpty) return Center(child: Text('상품이 없습니다.'));
                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildProductCard(filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: '제품명 검색',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.purple[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (text) => ref.read(searchProvider.notifier).state = text,
      ),
    );
  }
}

  Widget _buildProductCard(Map<String, dynamic> product) {
    final selectedSize = product['psize'] ?? 250;
    final isSoldOut = (product['pstock'] ?? 0) <= 0;

    return Opacity(
      opacity: isSoldOut ? 0.5 : 1.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black, width: 2),
        ),
        child: InkWell(
          onTap: isSoldOut
              ? null
              : () {
                  Get.to(() => ShoesDetailPage(product: product, selectedSize: selectedSize));
                },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'http://127.0.0.1:8000/view/${product['pid']}?t=${DateTime.now().millisecondsSinceEpoch}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: Center(child: Text("이미지 없음")),
                          ),
                        ),
                      ),
                      if (isSoldOut)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            color: Colors.black.withOpacity(0.7),
                            child: Text(
                              '품절',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product["pname"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${product["pprice"]}원', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('브랜드: ${product["pbrand"] ?? ""}', style: TextStyle(fontSize: 12)),
                      Text('색상: ${product["pcolor"]}', style: TextStyle(fontSize: 12)),
                      Text('사이즈: ${product["psize"]}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


class MainDrawer extends StatelessWidget {
  final box = GetStorage();

  MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = box.read('p_userId') ?? '';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userId.isNotEmpty ? userId : '로그인 필요',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildTile(context, Icons.shopping_bag, '상품 구매', () => Get.back()),
                _buildTile(context, Icons.person_outline, '회원정보 수정', () => Get.to(() => EditProfilePage())),
                _buildTile(context, Icons.receipt_long, '내 주문 내역', () => Get.to(() => OrderViewPage())),
                _buildTile(context, Icons.shopping_cart, '장바구니', () => Get.to(() => CartPage())),
                _buildTile(context, Icons.location_on, '위치 검색', () => Get.to(() => LocationSearch())),
                _buildTile(context, Icons.assignment_return, '반품 내역 확인', () => Get.to(() => Returns())),
                Divider(height: 30),
                _buildTile(context, Icons.logout, '로그아웃', () {
                  box.erase();
                  Get.offAllNamed('/');
                }, iconColor: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(fontSize: 15)),
      onTap: onTap,
      horizontalTitleGap: 8.0,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.grey[200],
    );
  }
}