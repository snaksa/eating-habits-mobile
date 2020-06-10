import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';
import '../../providers/medicine-provider.dart';
import './widgets/medicine-summary.dart';
import '../../widgets/dialog.dart' as dialog;

class MedicineListScreen extends StatefulWidget {
  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<MedicineProvider>(context).fetchMedicineRecords().then(
        (_) {
          setState(() {
            _isLoading = false;
          });
        },
      ).catchError((error) {
        dialog.Dialog('An error occured', error.message, {
          'Okay': () {
            Navigator.of(context).pop();
            if (error.status == 403) {
              Navigator.of(context).popAndPushNamed(AuthScreen.routeName);
            }
          },
        }).show(context);
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        child: Consumer<MedicineProvider>(
          builder: (ctx, provider, _) => this._isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                )
              : provider.medicines.length <= 0
                  ? Center(
                      child: const Text('No records yet'),
                    )
                  : Container(
                      height: double.infinity,
                      child: ListView.builder(
                        itemCount: provider.medicines.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return MedicineSummary(
                            provider.medicines[index],
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
