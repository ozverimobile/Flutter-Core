enum CoreShareResultStatus {
  /// The user has selected an action
  success,

  /// The user dismissed the share-sheet
  dismissed,

  /// The platform succeed to share content to user
  /// but the user action can not be determined
  unavailable,
}
