import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_flow/presentation/providers/catalog_provider.dart';

class DeliveryInfoFormPage extends StatefulWidget {
  final int productId;
  final String productName;

  const DeliveryInfoFormPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<DeliveryInfoFormPage> createState() => _DeliveryInfoFormPageState();
}

class _DeliveryInfoFormPageState extends State<DeliveryInfoFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _deliveryType = '익일배송';
  int _deliveryFee = 3000;
  int _freeDeliveryThreshold = 50000;
  String _deliveryRegions = '서울,경기,인천';
  String _deliveryDays = '월,화,수,목,금';
  String _deliveryTimeSlots = '오전,오후';
  int _estimatedDeliveryDays = 1;
  String _packagingType = '박스';
  bool _isFragile = false;
  bool _requiresRefrigeration = false;
  String? _specialInstructions;

  final List<String> _deliveryTypes = ['당일배송', '익일배송', '2-3일 배송', '주문 후 배송'];
  final List<String> _packagingTypes = ['박스', '비닐', '냉장박스', '냉동박스', '스티로폼'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배송 정보 등록'),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.state == CatalogState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상품: ${widget.productName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  DropdownButtonFormField<String>(
                    value: _deliveryType,
                    decoration: const InputDecoration(
                      labelText: '배송 유형',
                      border: OutlineInputBorder(),
                    ),
                    items: _deliveryTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _deliveryType = value;
                          if (value == '당일배송') {
                            _estimatedDeliveryDays = 0;
                          } else if (value == '익일배송') {
                            _estimatedDeliveryDays = 1;
                          } else if (value == '2-3일 배송') {
                            _estimatedDeliveryDays = 2;
                          }
                        });
                      }
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _deliveryType = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _deliveryFee.toString(),
                    decoration: const InputDecoration(
                      labelText: '배송비 (원)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '배송비를 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _deliveryFee = int.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _freeDeliveryThreshold.toString(),
                    decoration: const InputDecoration(
                      labelText: '무료 배송 기준 금액 (원)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '무료 배송 기준 금액을 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _freeDeliveryThreshold = int.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _deliveryRegions,
                    decoration: const InputDecoration(
                      labelText: '배송 가능 지역 (쉼표로 구분)',
                      border: OutlineInputBorder(),
                      hintText: '서울,경기,인천',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '배송 가능 지역을 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _deliveryRegions = value!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _deliveryDays,
                    decoration: const InputDecoration(
                      labelText: '배송 가능 요일 (쉼표로 구분)',
                      border: OutlineInputBorder(),
                      hintText: '월,화,수,목,금',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '배송 가능 요일을 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _deliveryDays = value!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _deliveryTimeSlots,
                    decoration: const InputDecoration(
                      labelText: '배송 시간대 (쉼표로 구분)',
                      border: OutlineInputBorder(),
                      hintText: '오전,오후',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '배송 시간대를 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _deliveryTimeSlots = value!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    initialValue: _estimatedDeliveryDays.toString(),
                    decoration: const InputDecoration(
                      labelText: '예상 배송 일수',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '예상 배송 일수를 입력하세요';
                      }
                      return null;
                    },
                    onSaved: (value) => _estimatedDeliveryDays = int.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _packagingType,
                    decoration: const InputDecoration(
                      labelText: '포장 유형',
                      border: OutlineInputBorder(),
                    ),
                    items: _packagingTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _packagingType = value);
                      }
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _packagingType = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('파손 주의 상품'),
                    value: _isFragile,
                    onChanged: (value) {
                      setState(() => _isFragile = value);
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('냉장 보관 필요'),
                    value: _requiresRefrigeration,
                    onChanged: (value) {
                      setState(() => _requiresRefrigeration = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '특별 지시사항 (선택)',
                      border: OutlineInputBorder(),
                      hintText: '직사광선을 피해 보관해주세요',
                    ),
                    maxLines: 3,
                    onSaved: (value) {
                      _specialInstructions = value?.isEmpty == true ? null : value;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('배송 정보 저장'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 디버깅: 전송할 데이터 확인
      print('=== 배송 정보 전송 데이터 ===');
      print('productId: ${widget.productId}');
      print('deliveryType: $_deliveryType');
      print('deliveryFee: $_deliveryFee');
      print('freeDeliveryThreshold: $_freeDeliveryThreshold');
      print('deliveryRegions: $_deliveryRegions');
      print('deliveryDays: $_deliveryDays');
      print('deliveryTimeSlots: $_deliveryTimeSlots');
      print('estimatedDeliveryDays: $_estimatedDeliveryDays');
      print('packagingType: $_packagingType');
      print('isFragile: $_isFragile');
      print('requiresRefrigeration: $_requiresRefrigeration');
      print('specialInstructions: $_specialInstructions');
      print('========================');

      final provider = context.read<CatalogProvider>();
      
      try {
        await provider.createOrUpdateDeliveryInfo(
          productId: widget.productId,
          deliveryType: _deliveryType,
          deliveryFee: _deliveryFee,
          freeDeliveryThreshold: _freeDeliveryThreshold,
          deliveryRegions: _deliveryRegions,
          deliveryDays: _deliveryDays,
          deliveryTimeSlots: _deliveryTimeSlots,
          estimatedDeliveryDays: _estimatedDeliveryDays,
          packagingType: _packagingType,
          isFragile: _isFragile,
          requiresRefrigeration: _requiresRefrigeration,
          specialInstructions: _specialInstructions,
        );

        if (provider.state == CatalogState.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('배송 정보가 저장되었습니다')),
            );
            Navigator.pop(context);
          }
        } else if (provider.state == CatalogState.error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage ?? '오류가 발생했습니다'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        print('배송 정보 저장 에러: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('에러: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
