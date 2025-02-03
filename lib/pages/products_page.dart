import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productImageController = TextEditingController();
  String? _selectedCategory;

  // Temporary controllers for editing
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDescriptionController =
      TextEditingController();
  final TextEditingController _editPriceController = TextEditingController();
  final TextEditingController _editImageController = TextEditingController();
  String? _editCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: const Color(0xff0A78D6),
        title: const Text(
          "Тауарлармен және категориялармен жұмыс",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryManagement(),
            const SizedBox(height: 32),
            _buildProductManagement(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Категорияларды басқару",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: "Категория қосу",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0A78D6),
                foregroundColor: Colors.white,
              ),
              child: const Text("Қосу"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("Категориялар жоқ.");
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(doc['title']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(doc.id),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Тауарлар",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<DropdownMenuItem<String>>>(
          future: _getCategoryDropdownItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Text("Категорияларды жазуда қателік кетті");
            }
            return DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Категорияны таңдаңыз"),
              items: snapshot.data,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _productNameController,
          decoration: const InputDecoration(
            labelText: "Тауар аты",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _productDescriptionController,
          decoration: const InputDecoration(
            labelText: "Тауар сипаттамасы",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _productPriceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: "Тауар бағасы",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _productImageController,
          decoration: const InputDecoration(
            labelText: "Тауардың суретінің URL сілтемесі",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff0A78D6),
            foregroundColor: Colors.white,
          ),
          child: const Text("Тауар қосу"),
        ),
        const SizedBox(height: 16),
        const Text("Барлық тауарлар", style: TextStyle(fontSize: 24)),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("Тауарлар жоқ.");
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return ListTile(
                  leading: Image.network(
                    doc['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  title: Text(doc['name']),
                  subtitle: Text("${doc['price']} ₸"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduct(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(doc.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _editProduct(DocumentSnapshot product) {
    _editNameController.text = product['name'];
    _editDescriptionController.text = product['body'];
    _editPriceController.text = product['price'].toString();
    _editImageController.text = product['image'];
    _editCategory = product['category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Тауарды өзгерту"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _editNameController,
                  decoration: const InputDecoration(
                    labelText: "Тауар аты",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _editDescriptionController,
                  decoration: const InputDecoration(
                    labelText: "Тауар сипаттамасы",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _editPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Тауар бағасы",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _editImageController,
                  decoration: const InputDecoration(
                    labelText: "Сурет URL сілтемесі",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<DropdownMenuItem<String>>>(
                  future: _getCategoryDropdownItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return const Text("Категорияларды жазуда қателік кетті");
                    }
                    return DropdownButtonFormField<String>(
                      value: _editCategory,
                      hint: const Text("Категорияны таңдаңыз"),
                      items: snapshot.data,
                      onChanged: (value) {
                        setState(() {
                          _editCategory = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Артқа"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(product.id)
                    .update({
                  'name': _editNameController.text,
                  'body': _editDescriptionController.text,
                  'price': double.parse(_editPriceController.text),
                  'image': _editImageController.text,
                  'category': _editCategory,
                });
                Navigator.pop(context);
              },
              child: const Text("Сақтау"),
            ),
          ],
        );
      },
    );
  }

  Future<List<DropdownMenuItem<String>>> _getCategoryDropdownItems() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs
        .map((doc) => DropdownMenuItem<String>(
              value: doc['title'],
              child: Text(doc['title']),
            ))
        .toList();
  } catch (error) {
    print("Error fetching categories: $error");
    return [];
  }
}


  Future<void> _addCategory() async {
    final title = _categoryController.text.trim();
    if (title.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('categories')
          .add({'title': title});
      _categoryController.clear();
    }
  }

  Future<void> _deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection('categories').doc(id).delete();
  }

  Future<void> _addProduct() async {
    final name = _productNameController.text.trim();
    final description = _productDescriptionController.text.trim();
    final price = double.tryParse(_productPriceController.text.trim());
    final imageUrl = _productImageController.text.trim();
    final category = _selectedCategory;

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        price != null &&
        imageUrl.isNotEmpty &&
        category != null) {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'body': description,
        'price': price,
        'image': imageUrl,
        'category': category,
      });
      _clearProductFields();
    }
  }

  Future<void> _deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  void _clearProductFields() {
    _productNameController.clear();
    _productDescriptionController.clear();
    _productPriceController.clear();
    _productImageController.clear();
    _selectedCategory = null;
  }
}
