import 'package:equatable/equatable.dart';

enum IssueType {
  POOR_QUALITY,
  WRONG_ITEM,
  DAMAGED,
  EXPIRED,
  QUANTITY_MISMATCH
}

enum RequestAction { REFUND, EXCHANGE }

enum IssueStatus {
  SUBMITTED,
  REVIEWING,
  APPROVED,
  REJECTED,
  PICKUP_SCHEDULED,
  PICKED_UP,
  REFUNDED,
  EXCHANGED
}

class QualityIssue extends Equatable {
  final int id;
  final int orderId;
  final int itemId;
  final String itemName;
  final String storeId;
  final String storeName;
  final String distributorId;
  final IssueType issueType;
  final String issueTypeDescription;
  final List<String> photoUrls;
  final String description;
  final RequestAction requestAction;
  final String requestActionDescription;
  final IssueStatus status;
  final String statusDescription;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerComment;
  final DateTime? pickupScheduledAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const QualityIssue({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.storeId,
    required this.storeName,
    required this.distributorId,
    required this.issueType,
    required this.issueTypeDescription,
    required this.photoUrls,
    required this.description,
    required this.requestAction,
    required this.requestActionDescription,
    required this.status,
    required this.statusDescription,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerComment,
    this.pickupScheduledAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        itemId,
        itemName,
        storeId,
        storeName,
        distributorId,
        issueType,
        issueTypeDescription,
        photoUrls,
        description,
        requestAction,
        requestActionDescription,
        status,
        statusDescription,
        submittedAt,
        reviewedAt,
        reviewerComment,
        pickupScheduledAt,
        resolvedAt,
        resolutionNote,
      ];
}
