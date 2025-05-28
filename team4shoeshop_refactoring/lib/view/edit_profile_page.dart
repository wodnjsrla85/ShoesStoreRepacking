/* 3조 - 팀원 : 김수아 개발 
 * 개발 일지 : 
 * 2025-05-28 
 * stf-stl 구조로 바꾼 후 riverpod으로 MVVM 형태로 바꾸는 작업을 진횅 하였다 
 * 
 * 
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:team4shoeshop_refactoring/vm/2_provider.dart';

import '../model/customer.dart';

class EditProfilePage extends ConsumerWidget {
   EditProfilePage({super.key});
  
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController(); // 최종 주소
  final detailAddressController = TextEditingController(); // 상세 주소
  final cardNumController = TextEditingController();
  final cardCvcController = TextEditingController();
  final cardDateController = TextEditingController();
  final box = GetStorage();

  //들어온 주소를 합칠려고 선언해둔 변수 
  final String basicAddress = '';

  //들어온 주소를 합치는 함수
  void _combineAddress() {
    final detail = detailAddressController.text.trim();
    final full = '$basicAddress ${detail.isNotEmpty ? detail : ''}'.trim();
    addressController.text = full;
  }

// 텍스트 필드 통합 디자인 함수 

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    bool readOnly = false,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.edit),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
  //카드 넘버를 4칸마다 -를 넣어 카드번호 형태로 format을 해주는 함수 
  String formatCardNumber(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < number.length; i++) {
      buffer.write(number[i]);
      if ((i + 1) % 4 == 0 && i + 1 != number.length) buffer.write('-');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    //회원 정보를 수정을 하기 위한 과정이 들어 있는 provider을 부름 
    final updateProvider = ref.watch(updateuserProvider);
    //회원의 정보를 가지고 오는 함수 
    ref.read(updateuserProvider.notifier).loadProfile();
    nameController.text = updateProvider.cname.toString();
    passwordController.text = updateProvider.cpassword.toString();
    phoneController.text = updateProvider.cphone.toString();
    addressController.text = updateProvider.caddress.toString();
    detailAddressController.text = updateProvider.caddress.toString();
    cardNumController.text = updateProvider.ccardnum.toString();
    cardCvcController.text = updateProvider.ccardcvc.toString();
    cardDateController.text = updateProvider.ccarddate.toString();
    String userId = box.read('p_userId') ?? '';


    return Scaffold(
      appBar: AppBar(title: const Text("회원정보 수정")),
      body: nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildField(nameController, '이름'),
                  _buildField(passwordController, '비밀번호', obscure: true),
                  _buildField(
                    phoneController,
                    '전화번호',
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      PhoneNumberFormatter(),
                    ],
                  ),
                  _buildField(emailController, '이메일'),
                  const SizedBox(height: 16),

                  /// 주소 검색 버튼
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          basicAddress.isNotEmpty
                              ? basicAddress
                              : '주소를 선택해주세요',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: (){
                          //카카오 맵을 부르느는 함수를 부르고 그 값을 새로운 주소창에 넣어주는 형식을 넣어 둠 
                          ref.read(updateuserProvider.notifier).searchAddress(context);
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('주소 검색'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildField(detailAddressController, '상세 주소',
                      onChanged: (_) => _combineAddress()),
                  _buildField(addressController, '최종 주소 (자동완성)', readOnly: true),

                  const Divider(height: 32),
                  _buildField(
                    cardNumController,
                    '카드번호',
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberFormatter(),
                    ],
                  ),
                  _buildField(
                    cardCvcController,
                    'CVC',
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  _buildField(
                    cardDateController,
                    '유효기간 (YYMM)',
                    keyboard: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:(){ 
                        _combineAddress();
                        final customer = Customer(
                          cid: userId,
                          cname: nameController.text.trim(),
                          cpassword: passwordController.text.trim(),
                          cphone: phoneController.text.trim(),
                          cemail: emailController.text.trim(),
                          caddress: addressController.text.trim(),
                          ccardnum: cardNumController.text.trim(),
                          ccardcvc: int.parse(cardCvcController.text.trim()),
                          ccarddate: cardDateController.text.trim(),
                        );
                        //회원 정보 customer모델에 값을 넣어 업데이트 하는 곳으로 보냄 
                        ref.read(updateuserProvider.notifier).updateProfile(customer);
                      }, 
                      icon: const Icon(Icons.check),
                      label: const Text('수정 완료', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 2 || i == 6) buffer.write('-');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted.length > 13 ? formatted.substring(0, 13) : formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) buffer.write('-');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted.length > 19 ? formatted.substring(0, 19) : formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}