class StockInsufficientException implements Exception {
  final String message;
  StockInsufficientException(this.message);
  
  @override
  String toString() => message;
}
