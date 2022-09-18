import 'dart:io';

import 'package:agenda_contatos/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../helper/contact_helper.dart';

class ContactPage extends StatefulWidget {
  ContactPage(this.editedContact);

  Contact? editedContact;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  ImagePicker img = ImagePicker();
  ContactHelper helper = ContactHelper();
  late Contact contact;
  TextEditingController nameController = TextEditingController();
  String? nameErrorText;
  TextEditingController phoneController = TextEditingController();
  String? phoneErrorText;
  TextEditingController emailController = TextEditingController();
  String? emailErrorText;
  bool contactChanged = false;

  @override
  void initState() {
    super.initState();
    if(widget.editedContact != null){
      setState((){
        contact = widget.editedContact!;
        nameController.text = contact.name!;
        emailController.text = contact.email ?? '';
        phoneController.text = contact.phone ?? '';
      });
    }else{
      contact = Contact(null,null,null,null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(contact.name ?? 'Novo Contato'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(validadeFields()){
              contact.name = nameController.text;
              contact.email = emailController.text;
              contact.phone = phoneController.text;
              Navigator.pop(context,contact);
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  GestureDetector(
                    onTap: (){
                      img.pickImage(source: ImageSource.camera).then((imgSelected){
                        if(imgSelected != null){
                          setState((){
                            contact.img = imgSelected.path;
                            contactChanged = true;
                          });
                        }
                      });
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: contact.img != null ? BoxFit.cover : null,
                          image: contact.img != null ? FileImage(File(contact.img!)) : const AssetImage("images/person.jpg") as ImageProvider,
                        )
                      ),
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    errorText: nameErrorText,
                  ),
                  onChanged: (text){
                      setState((){
                        nameErrorText = null;
                        contact.name = text;
                        contactChanged = true;
                      });
                    },
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: emailErrorText
                  ),
                  onChanged: (text){
                    contactChanged = true;
                    setState((){
                      emailErrorText = null;
                    });
                    },
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    errorText: phoneErrorText,
                  ),
                  onChanged: (text){
                    contactChanged = true;
                    setState((){
                      phoneErrorText = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validadeFields(){
    if(nameController.text == null || nameController.text.trim() == ''){
      setState((){
        nameErrorText = 'Digite um nome para seu contato!';
      });
      return false;
    }
    if(emailController.text == null || emailController.text.trim() == ''){
      if(phoneController.text == null || phoneController.text.trim() == ''){
        setState((){
          emailErrorText = 'Email não definido!';
          phoneErrorText = 'Telefone não definido!';
        });
        return false;
      }
    }
    return true;
  }

  Future<bool> _requestPop(){
    print('Pop Request');
    if(contactChanged){
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text('Descartar Alterações?'),
              content: Text('Ao sair, você perderá todas as alterações.'),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text('Cancelar')),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child: Text('Sim')),
              ],
            );
          });
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }
}
