import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({required this.bodyContent, super.key});
  final Widget bodyContent;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentMonthIndex = 0; // To track the current month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Create a notch for the FAB
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.insert_chart_outlined_rounded,
                size: 30,
              ),
              onPressed: () async {
                await context.push('/');
              },
            ),
            const SizedBox(
              width: 20, // Adjust width to fit the FAB
            ),
            IconButton(
              icon: const Icon(
                size: 30,
                Icons.calendar_month_outlined,
              ),
              onPressed: () async {
                await context.push('/history');
              },
            ),
            // Empty space for the FAB
            const SizedBox(
              width: 140, // Adjust width to fit the FAB
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
                size: 30,
              ),
              onPressed: () {
                context.go('/profile');
              },
            ),
            const SizedBox(
              width: 50, // Adjust width to fit the FAB
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onPressed: () async {
          await context.push('/addPayslip');
        },
        tooltip: 'Add new payments',
        child: Icon(
          Icons.add,
          color: Colors.deepPurple[800],
        ),
      ),
      body: widget.bodyContent,
    );
  }
}
