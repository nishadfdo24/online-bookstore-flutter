import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String customerRole = 'Customer';
const String staffRole = 'Store Staff';
const String adminRole = 'Administrator';

String currentRole = customerRole;
void main() {
  runApp(const OnlineBookstoreApp());
}

class OnlineBookstoreApp extends StatelessWidget {
  const OnlineBookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Bookstore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ===============================
// API URLs
// ===============================

const String usersApi =
    'https://jsonplaceholder.typicode.com/users';

const String booksApi =
    'https://jsonplaceholder.typicode.com/albums';

const String photosApi =
    'https://jsonplaceholder.typicode.com/photos';

List<dynamic> cartItems = [];
// ===============================
// HOME PAGE
// ===============================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = [];
  List<dynamic> photos = [];
  List<dynamic> users = [];

  List<dynamic> filteredBooks = [];

  bool isLoading = true;
  String errorMessage = '';

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final responses = await Future.wait([
        http.get(Uri.parse(booksApi)),
        http.get(Uri.parse(photosApi)),
        http.get(Uri.parse(usersApi)),
      ]);
      if(responses.any((response) => response.statusCode !=200)){
        throw Exception('Unable to load bookstore Data');
      }

      if (responses[0].statusCode == 200 &&
          responses[1].statusCode == 200 &&
          responses[2].statusCode == 200) {
        final bookData = jsonDecode(responses[0].body);
        final photoData = jsonDecode(responses[1].body);
        final userData = jsonDecode(responses[2].body);

        setState(() {
          books = bookData;
          photos = photoData;
          users = userData;

          // Display first 30 books for a cleaner application
          filteredBooks = books.take(30).toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load API data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
        'Unable to load books. Please check your internet connection.';
      });
    }
  }

  void searchBooks(String value) {
    final query = value.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredBooks = books.take(30).toList();
      } else {
        filteredBooks = books
            .where(
              (book) => book['title']
              .toString()
              .toLowerCase()
              .contains(query),
        )
            .take(30)
            .toList();
      }
    });
  }

  String getBookImage(int index) {
    if (photos.isEmpty) {
      return '';
    }

    final photo = photos[index % photos.length];

    return photo['thumbnailUrl'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Online Bookstore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BookSearchDelegate(
                  books: books,
                  photos: photos,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=> const CartPage(),
                ),
              );
             },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 55,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Online Bookstore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Find your favourite books',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Books'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);

                showUsers(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('My Cart'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
                );

              },
            ),
            if (currentRole == staffRole ||
                currentRole == adminRole)
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Manage Books'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageBooksPage(),
                    ),
                  );

                },
              ),

            if (currentRole == staffRole ||
                currentRole == adminRole)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Manage Orders'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageOrdersPage(),
                    ),
                  );

                },
              ),

            if (currentRole == adminRole)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('User Management'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementPage(),
                    ),
                  );
                  },
              ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadData,
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : errorMessage.isNotEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 70,
                  color: Colors.grey,
                ),
                const SizedBox(height: 15),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        )
            : SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                const Text(
                  'Welcome to Online Bookstore',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Discover your next favourite book.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),


                TextField(
                  controller: searchController,
                  onChanged: searchBooks,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon:
                    const Icon(Icons.search),
                    suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ),
                      onPressed: () {
                        searchController
                            .clear();
                        searchBooks('');
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor:
                    Colors.grey.shade100,
                  ),
                ),

                const SizedBox(height: 25),


                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple
                        .withValues(alpha: 0.10),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Books',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Browse our collection and find books you love.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),


                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Book Collection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${filteredBooks.length} Books',
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                filteredBooks.isEmpty
                    ? const Center(
                  child: Padding(
                    padding:
                    EdgeInsets.all(40),
                    child: Text(
                      'No books found',
                    ),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount:
                  filteredBooks.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                    0.62,
                  ),
                  itemBuilder:
                      (context, index) {
                    final book =
                    filteredBooks[index];

                    final originalIndex =
                    books.indexOf(book);

                    return BookCard(
                      book: book,
                      imageUrl:
                      getBookImage(
                        originalIndex < 0
                            ? index
                            : originalIndex,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                BookDetailsPage(
                                  book: book,
                                  imageUrl:
                                  getBookImage(
                                    originalIndex <
                                        0
                                        ? index
                                        : originalIndex,
                                  ),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void showUsers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height:
          MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user['id'].toString(),
                        ),
                      ),
                      title: Text(
                        user['name'].toString(),
                      ),
                      subtitle: Text(
                        user['email'].toString(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class BookCard extends StatelessWidget {
  final dynamic book;
  final String imageUrl;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return const Icon(
                      Icons.menu_book,
                      size: 55,
                    );
                  },
                )
                    : const Icon(
                  Icons.menu_book,
                  size: 55,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                5,
              ),
              child: Text(
                book['title'].toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Text(
                'Book ID: ${book['id']}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 25,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Available now',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BookDetailsPage extends StatelessWidget {
  final dynamic book;
  final String imageUrl;

  const BookDetailsPage({
    super.key,
    required this.book,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 300,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius:
                    BorderRadius.circular(18),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error,
                          stackTrace) {
                        return const Icon(
                          Icons.menu_book,
                          size: 80,
                        );
                      },
                    ),
                  )
                      : const Icon(
                    Icons.menu_book,
                    size: 80,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                book['title'].toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Available now',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Book Information',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                const Icon(Icons.confirmation_number),
                title: const Text('Book ID'),
                subtitle:
                Text(book['id'].toString()),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                const Icon(Icons.person_outline),
                title: const Text('User ID'),
                subtitle:
                Text(book['userId'].toString()),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    cartItems.add(book);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Book added to cart',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                  ),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BookSearchDelegate
    extends SearchDelegate<String> {
  final List<dynamic> books;
  final List<dynamic> photos;

  BookSearchDelegate({
    required this.books,
    required this.photos,
  });

  String getImage(int index) {
    if (photos.isEmpty) {
      return '';
    }

    return photos[index % photos.length]
    ['thumbnailUrl']
        .toString();
  }

  @override
  List<Widget>? buildActions(
      BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(
      BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(
      BuildContext context) {
    final results = books
        .where(
          (book) => book['title']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()),
    )
        .take(30)
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];

        final originalIndex =
        books.indexOf(book);

        return ListTile(
          leading: SizedBox(
            width: 55,
            height: 55,
            child: Image.network(
              getImage(
                originalIndex < 0
                    ? index
                    : originalIndex,
              ),
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.menu_book,
                );
              },
            ),
          ),
          title: Text(
            book['title'].toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'Book ID: ${book['id']}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookDetailsPage(
                      book: book,
                      imageUrl: getImage(
                        originalIndex < 0
                            ? index
                            : originalIndex,
                      ),
                    ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(
      BuildContext context) {
    final suggestions = books
        .where(
          (book) => book['title']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()),
    )
        .take(10)
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final book = suggestions[index];

        return ListTile(
          leading:
          const Icon(Icons.menu_book),
          title: Text(
            book['title'].toString(),
          ),
          onTap: () {
            query = book['title'].toString();
            showResults(context);
          },
        );
      },
    );
  }
}


class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<int, int> cartQuantities = {};
  double getTotal() {
    double total = 0.0;

    for (var book in cartItems) {
      final bookId = book['id'] as int;
      final quantity = cartQuantities[bookId] ?? 1;

      final double price = 1000.0 + (bookId * 250.0);

      total = total + (price * quantity);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(fontSize: 18),
        ),
      )

          : Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {

                final book = cartItems[index];

                double price =
                    1000.0 + (book['id'] * 250.0);

                return Card(
                  margin: const EdgeInsets.all(10),

                  child: ListTile(
                    leading: const Icon(
                      Icons.menu_book,
                      size: 40,
                    ),

                    title: Text(
                      book['title'].toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Text(
                      'Rs. ${price.toStringAsFixed(0)}',
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              final id = book['id'] as int;
                              final currentQuantity = cartQuantities[id] ?? 1;

                              if (currentQuantity > 1) {
                                cartQuantities[id] = currentQuantity - 1;
                              }
                            });
                          },
                        ),

                        Text(
                          '${cartQuantities[book['id'] as int] ?? 1}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              final id = book['id'] as int;
                              final currentQuantity = cartQuantities[id] ?? 1;

                              cartQuantities[id] = currentQuantity + 1;
                            });
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              cartQuantities.remove(book['id'] as int);
                              cartItems.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Rs. ${getTotal().toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.shopping_cart_checkout,
                    ),

                    label: const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 16),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String paymentMethod = 'Cash on Delivery';

  void placeOrder() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
        ),
      );
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }
    if (phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderSuccessPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'Cash on Delivery',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Card Payment'),
              value: 'Card Payment',
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),

            const SizedBox(height: 10),


            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: placeOrder,

                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'Order Successful!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              const Text(
                'Order ID: ORD1001',
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                },

                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = customerRole;
  bool obscurePassword = true;

  void login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter username and password'),
        ),
      );
      return;
    }

    // Demo accounts for the assignment
    bool validLogin = false;

    if (selectedRole == customerRole &&
        username == 'customer' &&
        password == '1234') {
      validLogin = true;
    } else if (selectedRole == staffRole &&
        username == 'staff' &&
        password == '5678') {
      validLogin = true;
    } else if (selectedRole == adminRole &&
        username == 'admin' &&
        password == '2468') {
      validLogin = true;
    }

    if (!validLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username, password or role'),
        ),
      );
      return;
    }

    currentRole = selectedRole;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Bookstore'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.menu_book,
              size: 80,
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Login to your Online Bookstore account',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select User Role',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security),
              ),
              items: const [
                DropdownMenuItem(
                  value: customerRole,
                  child: Text('Customer'),
                ),
                DropdownMenuItem(
                  value: staffRole,
                  child: Text('Store Staff'),
                ),
                DropdownMenuItem(
                  value: adminRole,
                  child: Text('Administrator'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: login,
                icon: const Icon(Icons.login),
                label: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Demo Login Accounts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Customer: customer / 1234\n'
                  'Store Staff: staff / 1234\n'
                  'Administrator: admin / 1234',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}



class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});

  @override
  State<ManageBooksPage> createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  final List<Map<String, dynamic>> managedBooks = [
    {
      'title': 'Introduction to Mobile Development',
      'author': 'John Smith',
      'price': 4500.00,
      'stock': 12,
    },
    {
      'title': 'Web Technologies Fundamentals',
      'author': 'Sarah Wilson',
      'price': 5200.00,
      'stock': 8,
    },
    {
      'title': 'Database Systems',
      'author': 'David Brown',
      'price': 6000.00,
      'stock': 15,
    },
  ];

  void showBookDialog({int? index}) {
    final bool editing = index != null;

    final titleController = TextEditingController(
      text: editing ? managedBooks[index!]['title'] : '',
    );

    final authorController = TextEditingController(
      text: editing ? managedBooks[index!]['author'] : '',
    );

    final priceController = TextEditingController(
      text: editing ? managedBooks[index!]['price'].toString() : '',
    );

    final stockController = TextEditingController(
      text: editing ? managedBooks[index!]['stock'].toString() : '',
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(editing ? 'Edit Book' : 'Add Book'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Book Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter book title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter author name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: 'Rs. ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final stock = int.tryParse(value ?? '');
                      if (stock == null || stock < 0) {
                        return 'Enter valid stock quantity';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final book = {
                  'title': titleController.text.trim(),
                  'author': authorController.text.trim(),
                  'price': double.parse(priceController.text),
                  'stock': int.parse(stockController.text),
                };

                setState(() {
                  if (editing) {
                    managedBooks[index!] = book;
                  } else {
                    managedBooks.add(book);
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      editing
                          ? 'Book updated successfully'
                          : 'Book added successfully',
                    ),
                  ),
                );
              },
              child: Text(editing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void deleteBook(int index) {
    final bookTitle = managedBooks[index]['title'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "$bookTitle"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  managedBooks.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Book deleted successfully'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showBookDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),

      body: managedBooks.isEmpty
          ? const Center(
        child: Text(
          'No books available',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: managedBooks.length,
        itemBuilder: (context, index) {
          final book = managedBooks[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 55,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('Author: ${book['author']}'),
                        const SizedBox(height: 4),
                        Text(
                          'Price: Rs. ${book['price'].toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        Text('Stock: ${book['stock']}'),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Edit Book',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showBookDialog(index: index);
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete Book',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          deleteBook(index);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD001',
      'customer': 'John Smith',
      'book': 'Introduction to Mobile Development',
      'quantity': 1,
      'total': 4500.00,
      'status': 'Pending',
    },
    {
      'id': 'ORD002',
      'customer': 'Sarah Wilson',
      'book': 'Web Technologies Fundamentals',
      'quantity': 2,
      'total': 10400.00,
      'status': 'Processing',
    },
    {
      'id': 'ORD003',
      'customer': 'David Brown',
      'book': 'Database Systems',
      'quantity': 1,
      'total': 6000.00,
      'status': 'Delivered',
    },
  ];

  final List<String> statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  void updateOrderStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${orders[index]['id']} status updated to $newStatus',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(
        child: Text(
          'No orders available',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['id'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${order['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Customer: ${order['customer']}',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Book: ${order['book']}',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Quantity: ${order['quantity']}',
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: order['status'],
                          isExpanded: true,
                          items: statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              updateOrderStatus(
                                index,
                                newStatus,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final List<Map<String, String>> users = [
    {
      'name': 'Test Customer',
      'username': 'customer',
      'role': 'Customer',
    },
    {
      'name': 'Store Staff',
      'username': 'staff',
      'role': 'Store Staff',
    },
    {
      'name': 'System Administrator',
      'username': 'admin',
      'role': 'Administrator',
    },
  ];

  void deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User removed successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: users.isEmpty
          ? const Center(
        child: Text(
          'No users available',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                user['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Username: ${user['username']!}\n'
                    'Role: ${user['role']!}',
              ),
              isThreeLine: true,
              trailing: user['role'] == adminRole
                  ? const Icon(
                Icons.lock,
              )
                  : IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  deleteUser(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

