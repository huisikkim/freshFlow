import '../../domain/entities/quality_issue.dart';

class QualityIssueModel extends QualityIssue {
  const QualityIssueModel({
    required super.id,
    required super.orderId,
    required super.itemId,
    required super.itemName,
    required super.storeId,
    required super.storeName,
    required super.distributorId,
    required super.issueType,
    required super.issueTypeDescription,
    required super.photoUrls,
    required super.description,
    required super.requestAction,
    required super.requestActionDescription,
    required super.status,
    required super.statusDescription,
    required super.submittedAt,
    super.reviewedAt,
    super.reviewerComment,
    super.pickupScheduledAt,
    super.resolvedAt,
    super.resolutionNote,
  });

  factory QualityIssueModel.fromJson(Map<String, dynamic> json) {
    return QualityIssueModel(
      id: json['id'],
      orderId: json['orderId'],
      itemId: json['itemId'],
      itemName: json['itemName'],
      storeId: json['storeId'],
      storeName: json['storeName'],
      distributorId: json['distributorId'],
      issueType: IssueType.values.byName(json['issueType']),
      issueTypeDescription: json['issueTypeDescription'],
      photoUrls: List<String>.from(json['photoUrls']),
      description: json['description'],
      requestAction: RequestAction.values.byName(json['requestAction']),
      requestActionDescription: json['requestActionDescription'],
      status: IssueStatus.values.byName(json['status']),
      statusDescription: json['statusDescription'],
      submittedAt: DateTime.parse(json['submittedAt']),
      reviewedAt:
          json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewerComment: json['reviewerComment'],
      pickupScheduledAt: json['pickupScheduledAt'] != null
          ? DateTime.parse(json['pickupScheduledAt'])
          : null,
      resolvedAt:
          json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      resolutionNote: json['resolutionNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'itemId': itemId,
      'itemName': itemName,
      'storeId': storeId,
      'storeName': storeName,
      'distributorId': distributorId,
      'issueType': issueType.name,
      'issueTypeDescription': issueTypeDescription,
      'photoUrls': photoUrls,
      'description': description,
      'requestAction': requestAction.name,
      'requestActionDescription': requestActionDescription,
      'status': status.name,
      'statusDescription': statusDescription,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerComment': reviewerComment,
      'pickupScheduledAt': pickupScheduledAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNote': resolutionNote,
    };
  }
}
