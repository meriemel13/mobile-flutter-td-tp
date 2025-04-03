import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// URL de base de l'API
const String baseUrl = 'http://localhost:3000/api';

// Modèle pour les produits
class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'ID: $id, Nom: $name, Prix: $price€, Description: $description';
  }
}

// Modèle pour les éléments d'une commande
class OrderItem {
  final int productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

// Modèle pour les commandes
class Order {
  final int? id;
  final String customerName;
  final List<OrderItem> items;
  final double totalAmount;
  final String? status;
  final String? createdAt;

  Order({
    this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.status,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<OrderItem> orderItems = itemsList.map((item) => OrderItem.fromJson(item)).toList();

    return Order(
      id: json['id'],
      customerName: json['customerName'],
      items: orderItems,
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }

  @override
  String toString() {
    return 'ID: $id, Client: $customerName, Montant total: $totalAmount€, Statut: $status';
  }
}

// Service pour les produits
class ProductService {
  // Récupérer tous les produits
  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Échec de la récupération des produits: ${response.statusCode}');
    }
  }

  // Ajouter un nouveau produit
  static Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de l\'ajout du produit: ${response.statusCode}');
    }
  }
}

// Service pour les commandes
class OrderService {
  // Récupérer toutes les commandes
  static Future<List<Order>> getAllOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => Order.fromJson(data)).toList();
    } else {
      throw Exception('Échec de la récupération des commandes: ${response.statusCode}');
    }
  }

  // Ajouter une nouvelle commande
  static Future<Order> addOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Échec de l\'ajout de la commande: ${response.statusCode}');
    }
  }
}

// Menu principal
void showMenu() {
  print('\n===== GESTION DES PRODUITS ET COMMANDES =====');
  print('1. Afficher tous les produits');
  print('2. Ajouter un nouveau produit');
  print('3. Afficher toutes les commandes');
  print('4. Créer une nouvelle commande');
  print('0. Quitter');
  print('===========================================');
}

// Fonction pour lire une entrée utilisateur
String readLine() {
  return stdin.readLineSync() ?? '';
}

// Fonction pour lire un nombre
double readNumber() {
  while (true) {
    try {
      return double.parse(readLine());
    } catch (e) {
      print('Veuillez entrer un nombre valide:');
    }
  }
}

// Fonction pour lire un entier
int readInteger() {
  while (true) {
    try {
      return int.parse(readLine());
    } catch (e) {
      print('Veuillez entrer un nombre entier valide:');
    }
  }
}

// Fonction principale
void main() async {
  bool running = true;

  while (running) {
    showMenu();
    print('Entrez votre choix:');
    String choice = readLine();

    switch (choice) {
      case '1': // Afficher tous les produits
        try {
          final products = await ProductService.getAllProducts();
          print('\n=== LISTE DES PRODUITS ===');
          if (products.isEmpty) {
            print('Aucun produit disponible.');
          } else {
            for (var product in products) {
              print(product);
            }
          }
        } catch (e) {
          print('Erreur: $e');
        }
        break;

      case '2': // Ajouter un nouveau produit
        try {
          print('\n=== AJOUTER UN PRODUIT ===');
          print('Nom du produit:');
          String name = readLine();
          
          print('Prix:');
          double price = readNumber();
          
          print('Description:');
          String description = readLine();
          
          final product = Product(name: name, price: price, description: description);
          final addedProduct = await ProductService.addProduct(product);
          
          print('\nProduit ajouté avec succès:');
          print(addedProduct);
        } catch (e) {
          print('Erreur: $e');
        }
        break;

      case '3': // Afficher toutes les commandes
        try {
          final orders = await OrderService.getAllOrders();
          print('\n=== LISTE DES COMMANDES ===');
          if (orders.isEmpty) {
            print('Aucune commande disponible.');
          } else {
            for (var order in orders) {
              print(order);
              print('Éléments:');
              for (var item in order.items) {
                print('  - Produit #${item.productId}: ${item.quantity} x ${item.price}€');
              }
              print('---');
            }
          }
        } catch (e) {
          print('Erreur: $e');
        }
        break;

      case '4': // Créer une nouvelle commande
        try {
          print('\n=== CRÉER UNE COMMANDE ===');
          print('Nom du client:');
          String customerName = readLine();
          
          List<OrderItem> items = [];
          double totalAmount = 0;
          bool addingItems = true;
          
          // D'abord, montrons les produits disponibles
          final products = await ProductService.getAllProducts();
          print('\nProduits disponibles:');
          for (var product in products) {
            print(product);
          }
          
          while (addingItems) {
            print('\nAjouter un élément à la commande? (O/N)');
            String response = readLine().toLowerCase();
            
            if (response == 'o') {
              print('ID du produit:');
              int productId = readInteger();
              
              // Vérifier si le produit existe
              final product = products.firstWhere(
                (p) => p.id == productId,
                orElse: () => throw Exception('Produit non trouvé'),
              );
              
              print('Quantité:');
              int quantity = readInteger();
              
              double itemPrice = product.price * quantity;
              totalAmount += itemPrice;
              
              items.add(OrderItem(
                productId: productId,
                quantity: quantity,
                price: product.price,
              ));
              
              print('Élément ajouté. Total actuel: $totalAmount€');
            } else {
              addingItems = false;
            }
          }
          
          if (items.isEmpty) {
            print('La commande a été annulée (aucun élément).');
            break;
          }
          
          final order = Order(
            customerName: customerName,
            items: items,
            totalAmount: totalAmount,
          );
          
          final addedOrder = await OrderService.addOrder(order);
          print('\nCommande créée avec succès:');
          print(addedOrder);
        } catch (e) {
          print('Erreur: $e');
        }
        break;

      case '0': // Quitter
        running = false;
        print('Au revoir!');
        break;

      default:
        print('Option invalide. Veuillez réessayer.');
    }
    
    if (running) {
      print('\nAppuyez sur Entrée pour continuer...');
      readLine();
    }
  }
}