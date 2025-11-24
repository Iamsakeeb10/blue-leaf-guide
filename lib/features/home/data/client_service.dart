// lib/services/client_service.dart
class ClientService {
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  final List<Map<String, dynamic>> _clients = [];

  List<Map<String, dynamic>> get clients => List.unmodifiable(_clients);

  void addClient(Map<String, dynamic> client) {
    _clients.add(client);
  }

  void removeClient(int index) {
    _clients.removeAt(index);
  }

  void updateClient(int index, Map<String, dynamic> client) {
    _clients[index] = client;
  }

  void clear() {
    _clients.clear();
  }
}
