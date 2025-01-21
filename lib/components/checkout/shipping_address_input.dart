import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/validate_service.dart';
class ShippingAddressInput extends StatefulWidget {
  final HashMap addressValues;
  final void Function () validateInput;

  const ShippingAddressInput(this.addressValues, this.validateInput, {super.key});
  @override
  State<ShippingAddressInput> createState() => _ShippingAddressInputState();
}

class _ShippingAddressInputState extends State<ShippingAddressInput> {
  HashMap addressValues = HashMap();

  InputDecoration customBorder(String hintText, IconData textIcon){
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black)
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent)
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent)
      ),
      hintText: hintText,
      prefixIcon: Icon(textIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    ValidateService _validateService = new ValidateService();
    return Column(
      children: <Widget>[
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              style: const TextStyle(fontSize: 16.0),
              decoration: customBorder('Full Name',Icons.person),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['name'] = val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              style: const TextStyle(fontSize: 16.0),
              decoration: customBorder('Mobile number',Icons.call),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"^[^._]+$")),
                LengthLimitingTextInputFormatter(10)
              ],
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['mobileNumber'] = val
            )
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              style: const TextStyle(fontSize: 16.0),
              decoration: customBorder('PIN code', Icons.code),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"^[^._]+$")),
                LengthLimitingTextInputFormatter(6)
              ],
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['pinCode']= val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              style: const TextStyle(fontSize: 16.0),
              decoration: customBorder('Flat, House no, Apartment', Icons.home),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) =>widget.addressValues['address']= val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              style: const TextStyle(fontSize: 16.0),
              decoration: customBorder('Area, Colony, Street, Sector, Village', Icons.location_city),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['area']= val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              decoration: customBorder('Landmark', Icons.location_city),
              style: const TextStyle(fontSize: 16.0),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['landMark']= val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              decoration: customBorder('City', Icons.location_city),
              style: const TextStyle(fontSize: 16.0),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['city']= val
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 80.0,
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.black),
            child: TextFormField(
              decoration: customBorder('State', Icons.location_city),
              style: const TextStyle(fontSize: 16.0),
              keyboardType: TextInputType.text,
              validator: (value) => _validateService.isEmptyField(value!),
              onSaved: (val) => widget.addressValues['state']= val
            ),
          ),
        ),
        ButtonTheme(
          // borderSide: BorderSide(color: Colors.black,width: 1.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          minWidth: MediaQuery.of(context).size.width /3.2,
          child: OutlinedButton(
            style: const ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: Colors.black,width: 1.8)))),
            onPressed: (){
              widget.validateInput();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
      ],
    );
  }
}
