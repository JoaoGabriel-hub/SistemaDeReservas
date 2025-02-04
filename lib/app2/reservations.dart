import 'package:flutter/material.dart';
import 'package:projetofinal/data_base.dart';

class Reservations extends StatefulWidget {
  @override
  _ReservationsState createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
  final DataBaseHelper _dbHelper = DataBaseHelper();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final bookings = await _dbHelper.getBookingsByUser();
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No reservations found'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: (booking['thumbnail'] != null && booking['thumbnail'].startsWith('http'))
                            ? Image.network(
                                booking['thumbnail'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.broken_image, size: 50);
                                },
                              )
                            : Icon(Icons.image_not_supported, size: 50),
                        title: Text(booking['title'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Check-in: ${booking['checkin_date']}\nCheck-out: ${booking['checkout_date']}\nTotal: R\$${booking['total_price'].toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}