import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/quality_issue.dart';
import '../../providers/quality_issue_provider.dart';

class SubmitQualityIssuePage extends StatefulWidget {
  final String storeId;
  final Map<String, dynamic>? prefilledData;

  const SubmitQualityIssuePage({
    super.key,
    required this.storeId,
    this.prefilledData,
  });

  @override
  State<SubmitQualityIssuePage> createState() => _SubmitQualityIssuePageState();
}

class _SubmitQualityIssuePageState extends State<SubmitQualityIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _orderIdController = TextEditingController();
  final _itemIdController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _distributorIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoUrlController = TextEditingController();

  IssueType _selectedIssueType = IssueType.POOR_QUALITY;
  RequestAction _selectedRequestAction = RequestAction.REFUND;
  final List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    // 미리 채워진 데이터가 있으면 설정
    if (widget.prefilledData != null) {
      _orderIdController.text = widget.prefilledData!['orderId']?.toString() ?? '';
      _distributorIdController.text = widget.prefilledData!['distributorId']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _itemIdController.dispose();
    _itemNameController.dispose();
    _storeNameController.dispose();
    _distributorIdController.dispose();
    _descriptionController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  String _getIssueTypeDescription(IssueType type) {
    switch (type) {
      case IssueType.POOR_QUALITY:
        return '품질 불량';
      case IssueType.WRONG_ITEM:
        return '오배송';
      case IssueType.DAMAGED:
        return '파손';
      case IssueType.EXPIRED:
        return '유통기한 임박/경과';
      case IssueType.QUANTITY_MISMATCH:
        return '수량 불일치';
    }
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1장의 사진을 추가해주세요.')),
      );
      return;
    }

    final success = await context.read<QualityIssueProvider>().submitIssue(
          orderId: int.parse(_orderIdController.text),
          itemId: int.parse(_itemIdController.text),
          itemName: _itemNameController.text,
          storeId: widget.storeId,
          storeName: _storeNameController.text,
          distributorId: _distributorIdController.text,
          issueType: _selectedIssueType,
          photoUrls: _photoUrls,
          description: _descriptionController.text,
          requestAction: _selectedRequestAction,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('품질 이슈가 신고되었습니다.')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('신고 실패: ${context.read<QualityIssueProvider>().errorMessage}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('품질 이슈 신고'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: '주문 ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '주문 ID를 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemIdController,
              decoration: const InputDecoration(
                labelText: '품목 ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '품목 ID를 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: '품목명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '품목명을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: '가게명',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '가게명을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distributorIdController,
              decoration: const InputDecoration(
                labelText: '유통사 ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '유통사 ID를 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IssueType>(
              value: _selectedIssueType,
              decoration: const InputDecoration(
                labelText: '이슈 유형',
                border: OutlineInputBorder(),
              ),
              items: IssueType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getIssueTypeDescription(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedIssueType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RequestAction>(
              value: _selectedRequestAction,
              decoration: const InputDecoration(
                labelText: '요청 액션',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: RequestAction.REFUND,
                  child: Text('환불'),
                ),
                DropdownMenuItem(
                  value: RequestAction.EXCHANGE,
                  child: Text('교환'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRequestAction = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '상세 설명',
                border: OutlineInputBorder(),
                hintText: '문제 상황을 자세히 설명해주세요.',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '상세 설명을 입력해주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '사진 URL',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _photoUrlController,
                    decoration: const InputDecoration(
                      hintText: '사진 URL을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_photoUrlController.text.isNotEmpty) {
                      setState(() {
                        _photoUrls.add(_photoUrlController.text);
                        _photoUrlController.clear();
                      });
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_photoUrls.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _photoUrls.asMap().entries.map((entry) {
                  return Chip(
                    label: Text('사진 ${entry.key + 1}'),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _photoUrls.removeAt(entry.key);
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitIssue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('신고하기', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
