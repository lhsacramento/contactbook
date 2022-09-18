import 'package:agenda_contatos/helper/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz,orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState(){
    super.initState();
    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            onSelected: selectOrderList,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar de A-Z'),
                value: OrderOptions.orderaz),
              const PopupMenuItem<OrderOptions>(
                  child: Text('Ordernar de Z-A'),
                  value: OrderOptions.orderza),
            ]),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index){
            return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        showOptions(context,index);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: contacts[index].img != null ? BoxFit.cover : null,
                    image: contacts[index].img != null ?
                    FileImage(File(contacts[index].img!)) :
                    const AssetImage("images/person.jpg") as ImageProvider,
                  )
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contacts[index].name ?? "",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      Text(contacts[index].email ?? "",style: const TextStyle(fontSize: 15),),
                      Text(contacts[index].phone ?? "",style: const TextStyle(fontSize: 15),),
                    ],
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showContactPage([Contact? c]) async {
    Contact? recContact = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(c))) as Contact?;
    if(recContact != null){
      if(c != null){
        await helper.updateContact(recContact);
      }else{
        await recContact.setId();
        await helper.saveContact(recContact);
      }
      getAllContacts();
    }
  }

  void getAllContacts(){
    helper.getAllContacts().then((listContact){
      setState((){
        contacts = listContact;
        selectOrderList(OrderOptions.orderaz);
      });
    });
  }

  void showOptions(BuildContext context,int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
          onClosing: (){},
          backgroundColor: Colors.black45,
          builder: (context){
            return Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        launchUrl(Uri.parse('tel:${contacts[index].phone!}'));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: const Text(
                        'Ligar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20),
                      ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                      showContactPage(contacts[index]);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                      helper.deleteContact(contacts[index].id!);
                      getAllContacts();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),

                ],
              ),
            );
          }
      );
    });
  }

  void selectOrderList(OrderOptions result){
    if(contacts.length > 1){
      switch(result){
        case OrderOptions.orderaz:
          contacts.sort((a,b){
            return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
          });
          break;
        case OrderOptions.orderza:
          contacts.sort((a,b){
            return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
          });
          break;
      }
      setState((){});
    }
  }
}
