enum DoseStatus { taken, missed, pending, skipped }

DoseStatus mapStatus(String status) {
  switch (status) {
    case "taken":
      return DoseStatus.taken;
    case "missed":
      return DoseStatus.missed;
    case "pending":
      return DoseStatus.pending;
    default:
      return DoseStatus.skipped;
  }
}
