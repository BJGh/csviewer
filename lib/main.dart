import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'dart:async';

Uint8List? pngBytes;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Histogram Visualization',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HistogramPage(),
    );
  }
}

class HistogramChart extends StatefulWidget {
  final List<List<dynamic>> data;

  const HistogramChart({Key? key, required this.data}) : super(key: key);

  @override
  _HistogramChartState createState() => _HistogramChartState();
}

class _HistogramChartState extends State<HistogramChart> {
  Uint8List? pngBytes;

  @override
  void initState() {
    super.initState();
    createImageFromChart();
  }

  Future<void> createImageFromChart() async {
    final chart = SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <HistogramSeries>[
        HistogramSeries<List<dynamic>, String>(
          dataSource: widget.data,
          sortFieldValueMapper: (data, _) => data[0].toString(),
          yValueMapper: (data, _) => double.parse(data[3].toString()),
          binInterval: 1, // Set the bin interval to 1
        ),
      ],
    );
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    final chartPadding = 15.0;
    final chartHeight = 500.0; // your chart height
    final chartWidth = 500.0; // your chart width

    // chart has to be drawn to the canvaa

    // store the created picture
    final picture = pictureRecorder.endRecording();

    // convert picture to image
    final img = await picture.toImage(chartWidth.toInt(), chartHeight.toInt());

    // get byte data from image
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      // update pngBytes with the byte data from the image
      pngBytes = byteData!.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pngBytes == null) {
      return CircularProgressIndicator(); // show loading indicator
    }

    return Container(
      child: Image.memory(pngBytes!),
    );
  }
}

class HistogramPage extends StatefulWidget {
  @override
  _HistogramPageState createState() => _HistogramPageState();
}

class _HistogramPageState extends State<HistogramPage> {
  List<List<dynamic>> csvData = [];
  Uint8List? pngBytes;

  @override
  void initState() {
    super.initState();
    readCSVData();
  }

  void readCSVData() async {
    String csvString = '''time,x,y,speed
      1198.820,-10.950,-33.214,0.000
      1198.840,-10.951,-33.222,0.004
      1198.860,-10.944,-33.237,0.012
      1198.880,-10.964,-33.260,0.02'''; // Replace with your actual CSV data

    csvData = const CsvToListConverter().convert(csvString);
    setState(() {});
  }

  SfCartesianChart pdfHistogramChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <HistogramSeries>[
        HistogramSeries<List<dynamic>, String>(
          dataSource: csvData,
          sortFieldValueMapper: (data, _) => data[0].toStringAsFixed(2),
          yValueMapper: (data, _) => double.parse(data[3].toString()),
          binInterval: 1, // Set the bin interval to 1
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histogram Visualization'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (csvData.isNotEmpty) HistogramChart(data: csvData),
            SizedBox(height: 20),
            Text(
              'Average Speed: 0.01 m/s', // Replace with actual average speed
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Image.asset('assets/logo.png'), // Replace with your image asset
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: generatePDFReport,
              child: Text('Generate PDF Report'),
            ),
          ],
        ),
      ),
    );
  }
}

void generatePDFReport() async {
  final pdf = pw.Document();

  final image = pw.MemoryImage(pngBytes!.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            children: [
              // add the image to the pdf
              pw.Image(image),
            ],
          ),
        );
      },
    ),
  );

  final output = File('report.pdf');
  final bytes = await pdf.save();
  await output.writeAsBytes(bytes);
}

class Histogram extends StatelessWidget {
  final List<List<dynamic>> data;

  const Histogram({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(),
      series: <HistogramSeries>[
        HistogramSeries<List<dynamic>, String>(
          dataSource: data,
          sortFieldValueMapper: (data, _) => data[0].toString(),
          yValueMapper: (data, _) => double.parse(data[3].toString()),
          binInterval: 1, // Set the bin interval to 1
        ),
      ],
    );
  }
}
