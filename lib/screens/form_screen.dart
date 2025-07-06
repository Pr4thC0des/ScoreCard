import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scorecard_app/providers/score_provider.dart';
import 'package:scorecard_app/screens/sections/dustbin_form_section.dart';
import 'package:scorecard_app/screens/sections/platform_form_section.dart';
import 'package:scorecard_app/screens/sections/toilet_form_section.dart';
import 'package:scorecard_app/screens/sections/waterbooth_form_section.dart';

class ScoreCardFormScreen extends StatelessWidget {
  const ScoreCardFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Station Scorecard"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft, // aligns tabs to the start
              child: TabBar(
                isScrollable: true,
                labelPadding: EdgeInsets.only(right: 15), // removes leading padding
                tabs: [
                  Tab(text: "Platform Area"),
                  Tab(text: "Toilets"),
                  Tab(text: "Dustbins"),
                  Tab(text: "Water Booths"),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextFormField(
                initialValue: provider.stationName,
                decoration: InputDecoration(labelText: "Station Name"),
                onChanged: provider.setStationName,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  provider.inspectionDate == null
                      ? "Select Inspection Date"
                      : "Date: ${provider.inspectionDate!.toLocal().toIso8601String().split('T')[0]}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (selected != null) {
                    provider.setInspectionDate(selected);
                  }
                },
              ),
            ),
            Divider(),

            // Tab views for sections
            Expanded(
              child: TabBarView(
                children: [
                  PlatformFormSection(),
                  ToiletFormSection(),
                  DustbinFormSection(),
                  WaterBoothFormSection(),
                ],
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.check),
          label: Text("Submit"),
          onPressed: () {
            final isValid = Provider.of<FormProvider>(context, listen: false).validateForm();
            if (isValid) {
              Navigator.pushNamed(context, '/preview');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please complete all scores and required fields"),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
