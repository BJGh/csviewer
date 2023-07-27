import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/pdf.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class PositionData {
  final double time;
  final double x;
  final double y;
  final double speed;

  PositionData(this.time, this.x, this.y, this.speed);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Position Data Visualization',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<PositionData> data = [];

  @override
  void initState() {
    super.initState();
    _loadCsvData();
  }

  void _loadCsvData() async {
    final csvData =
        await rootBundle.loadString('assets/csv/34003A000C503341.csv');
    final converter = CsvToListConverter();
    final csvList = converter.convert(csvData);
    data.addAll(csvList.map((row) {
      try {
        return PositionData(
          double.tryParse(row[0]) ?? 0.0,
          double.tryParse(row[1]) ?? 0.0,
          double.tryParse(row[2]) ?? 0.0,
          double.tryParse(row[3]) ?? 0.0,
        );
      } catch (e) {
        return PositionData(
            0.0, 0.0, 0.0, 0.0); // Provide a default value if conversion fails
      }
    }).toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Position Data Visualization'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Average Speed Histogram',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: charts.BarChart(
                  _createSeriesData(),
                  animate: true,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _generatePdfReport();
              },
              child: Text('Generate PDF Report'),
            ),
          ],
        ),
      ),
    );
  }

  List<charts.Series<PositionData, String>> _createSeriesData() {
    final fiveMinutesData =
        data.sublist(0, data.length > 3399 ? 3399 : data.length);
    final tenMinutesData =
        data.sublist(0, data.length > 6798 ? 6798 : data.length);

    final fiveMinutesSeries = charts.Series<PositionData, String>(
      id: '5 Minutes',
      domainFn: (PositionData data, _) => '5 Minutes',
      measureFn: (PositionData data, _) => data.speed,
      data: fiveMinutesData,
    );

    final tenMinutesSeries = charts.Series<PositionData, String>(
      id: '10 Minutes',
      domainFn: (PositionData data, _) => '10 Minutes',
      measureFn: (PositionData data, _) => data.speed,
      data: tenMinutesData,
    );

    return [fiveMinutesSeries, tenMinutesSeries];
  }

  void _generatePdfReport() {
    final pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Column(
            children: [
              pdfWidgets.Text(
                'Position Data Report',
                style: pdfWidgets.TextStyle(fontSize: 20),
              ),
              pdfWidgets.SizedBox(height: 20),
              pdfWidgets.Text(
                'Average Speed Statistics:',
                style: pdfWidgets.TextStyle(fontSize: 16),
              ),
              pdfWidgets.SizedBox(height: 10),
              pdfWidgets.Text(
                '5 Minutes: ...', // Add actual statistics here
              ),
              pdfWidgets.SizedBox(height: 10),
              pdfWidgets.Text(
                '10 Minutes: ...', // Add actual statistics here
              ),
              pdfWidgets.SizedBox(height: 20),
              pdfWidgets.Text(
                'Position Data:',
                style: pdfWidgets.TextStyle(fontSize: 16),
              ),
              pdfWidgets.SizedBox(height: 10),
              pdfWidgets.Table.fromTextArray(
                data: [
                  ['Time', 'X', 'Y', 'Speed'],
                  ...data.map((positionData) => [
                        positionData.time.toString(),
                        positionData.x.toString(),
                        positionData.y.toString(),
                        positionData.speed.toString(),
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF report
    // pdf.save(); Uncomment this line to save the PDF report
  }
}
