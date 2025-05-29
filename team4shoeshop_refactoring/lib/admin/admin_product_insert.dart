// 상품 등록 페이지 

/* 개발자 : 김수아
 * 목적 :  
 *  새로운 제품을 등록해야 될 떄 사용하는 페이지이다. 
 * 개발일지 :
 *  20250529
 *  satefullwidget 이였던 파일을 consumerwidget으로 변경하고
 *  riverpod을 이용하여  MVVM 형태의 개발을 만들었다. 
 *  
 */


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/admin/widget/admin_drawer.dart';
import 'package:team4shoeshop_refactoring/vm/2_provider.dart';

class AdminProductInsertPage extends ConsumerWidget {
  AdminProductInsertPage({super.key});
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();

  final TextEditingController _pid = TextEditingController();
  final TextEditingController _pname = TextEditingController();
  final TextEditingController _pstock = TextEditingController();
  final TextEditingController _pprice = TextEditingController();

  String? _selectedBrand;
  String? _selectedSize;
  String? _selectedColor;


  final List<String> _brands = ['나이키', '아디다스', '뉴발란스', '컨버스', '리복'];
  final List<String> _sizes = ['230', '240', '250', '260', '270', 'Free'];
  final List<String> _colors = ['블랙', '화이트', '레드', '블루', '그린', '옐로우'];

  bool isHQUser() {
    final eid = box.read('adminId') ?? '';
    return ['h001', 'h002', 'h003'].contains(eid);
  }

 



  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final insertProvider = ref.watch(productInsertProvider);
    if (!isHQUser()) {
      return Scaffold(
        appBar: AppBar(title: const Text('상품 등록')),
        body: const Center(child: Text('접근 권한이 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('신규 상품 등록')),
      drawer: AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(_pid, '상품 코드'),
              buildTextField(_pname, '상품명'),
              buildTextField(_pprice, '가격', isNumber: true),
              buildTextField(_pstock, '재고 수량', isNumber: true),
              const SizedBox(height: 12),

              buildDropdown('브랜드', _brands, _selectedBrand, (val) {
                insertProvider.pbrand = val!;
              }),
              const SizedBox(height: 12),

              buildDropdown('사이즈', _sizes, _selectedSize, (val) {
                insertProvider.psize = int.parse(val!);
              }),
              const SizedBox(height: 12),

              buildDropdown('색상', _colors, _selectedColor, (val) {
                insertProvider.pcolor= val!;
              }),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: ()=>ref.read(ImageHandlerProvider.notifier).getImageFromGallery(ImageSource.gallery) ,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[100],
                  ),
                  alignment: Alignment.center,
                  child: ref.watch(ImageHandlerProvider).imageFile != null
                      ? Image.file(File(ref.watch(ImageHandlerProvider).imageFile!.path), fit: BoxFit.cover)
                      : const Text('이미지를 선택하려면 탭하세요'),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: (){
                  
                  if (ref.watch(ImageHandlerProvider).imageFile == null) {
                    Get.snackbar('오류', '이미지를 선택하세요.');
                    return;
                  }
                  insertProvider.pid =_pid.text.trim();
                  insertProvider.pname = _pname.text.trim();
                  insertProvider.pprice= int.parse(_pprice.text.trim());
                  insertProvider.pstock = int.parse(_pstock.text.trim());
                  insertProvider.pimage = ref.watch(ImageHandlerProvider).imageFile!;
                  ref.read(productInsertProvider.notifier).submitProduct();

                  Get.back();
                  },
                child: const Text('상품 등록'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label을(를) 입력하세요';
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? '$label을 선택하세요' : null,
    );
  }
}