import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(const MortgageApp());
}

class MortgageApp extends StatelessWidget {
  const MortgageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mortgage Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MortgageCalculator(),
    );
  }
}

class MortgageCalculator extends StatefulWidget {
  const MortgageCalculator({super.key});

  @override
  _MortgageCalculatorState createState() => _MortgageCalculatorState();
}

class _MortgageCalculatorState extends State<MortgageCalculator> {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _downPaymentController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();
  final TextEditingController _homeOwnerInsuranceController =
      TextEditingController();
  final TextEditingController _propertyTaxController = TextEditingController();
  final TextEditingController _hoaFeesController = TextEditingController();

  double monthlyPayment = 0.0;
  double totalPayment = 0.0;
  double totalInterest = 0.0;

  @override
  void initState() {
    super.initState();
    _loanAmountController.addListener(calculateMortgage);
    _downPaymentController.addListener(calculateMortgage);
    _interestRateController.addListener(calculateMortgage);
    _loanTermController.addListener(calculateMortgage);
    _homeOwnerInsuranceController.addListener(calculateMortgage);
    _propertyTaxController.addListener(calculateMortgage);
    _hoaFeesController.addListener(calculateMortgage);
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _homeOwnerInsuranceController.dispose();
    _propertyTaxController.dispose();
    _hoaFeesController.dispose();
    super.dispose();
  }

  void calculateMortgage() {
    setState(() {
      double loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
      double downPayment = double.tryParse(_downPaymentController.text) ?? 0;
      double annualInterestRate =
          double.tryParse(_interestRateController.text) ?? 0;
      int loanTerm = int.tryParse(_loanTermController.text) ?? 0;
      double homeInsurance =
          double.tryParse(_homeOwnerInsuranceController.text) ?? 0;
      double propertyTax = double.tryParse(_propertyTaxController.text) ?? 0;
      double hoaFees = double.tryParse(_hoaFeesController.text) ?? 0;

      double monthlyInterestRate = (annualInterestRate / 100) / 12;
      int totalMonths = loanTerm * 12;

      double principalLoanAmount = loanAmount - downPayment;

      if (monthlyInterestRate > 0) {
        monthlyPayment = principalLoanAmount *
            (monthlyInterestRate * pow(1 + monthlyInterestRate, totalMonths)) /
            (pow(1 + monthlyInterestRate, totalMonths) - 1);
      } else {
        monthlyPayment = principalLoanAmount / totalMonths;
      }

      double additionalCosts = (homeInsurance + propertyTax + hoaFees) / 12;
      monthlyPayment += additionalCosts;

      totalPayment = monthlyPayment * totalMonths;
      totalInterest = totalPayment - principalLoanAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mortgage Calculator")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_loanAmountController, "Loan Amount"),
              _buildTextField(_downPaymentController, "Down Payment"),
              _buildTextField(
                  _interestRateController, "Annual Interest Rate (%)"),
              _buildTextField(_loanTermController, "Loan Term (years)"),
              _buildTextField(
                  _homeOwnerInsuranceController, "Home Owner's Insurance"),
              _buildTextField(_propertyTaxController, "Property Tax"),
              _buildTextField(_hoaFeesController, "HOA Fees"),
              const SizedBox(height: 20),
              if (totalPayment > 0) ...[
                _buildResultText("Monthly Payment", monthlyPayment),
                _buildResultText("Total Payment", totalPayment),
                _buildResultText("Total Interest", totalInterest, color: Colors.red),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1.2, // Ensures proper chart visibility
                  child: DonutChartWidget(
                    totalPayment - totalInterest > 0 ? totalPayment - totalInterest : 1,
                    totalInterest > 0 ? totalInterest : 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => calculateMortgage(),
    );
  }

  Widget _buildResultText(String label, double value, {Color color = Colors.black}) {
    return Text(
      "$label: \$${value.toStringAsFixed(2)}",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
    );
  }
}

class DonutChartWidget extends StatelessWidget {
  final double principal;
  final double totalInterest;

  const DonutChartWidget(this.principal, this.totalInterest, {super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: principal,
            title: "Principal",
            color: Colors.blue,
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: totalInterest,
            title: "Interest",
            color: Colors.red,
            radius: 80,
            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 5,
        centerSpaceRadius: 50, // Increases visibility
      ),
    );
  }
}