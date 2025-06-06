import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:services_app/models/service_model.dart';
import 'package:services_app/notifiers/ticket_notifier.dart';
import 'package:services_app/screens/home_screen.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});
  static const String routeName = '/create-service';

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateTimeController = TextEditingController();


  String? _name;
  String? _address;
  DateTime? _dateTime;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agendar Servicio")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nombre y Apellido",
                    hintText: "Ingresa tu nombre y apellido",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre y apellido';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _name = newValue;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Dirección",
                    hintText: "Ingresa tu dirección",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu dirección';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _address = newValue;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _dateTimeController,
                  decoration: InputDecoration(
                    labelText: "Fecha y Hora",
                    hintText: "Selecciona la fecha y hora",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona una fecha y hora';
                    }
                    return null;
                  },
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime(2100),
                    ).then((date) {
                      if (date != null && context.mounted) {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        ).then((time) {
                          if (time != null) {
                            // Logic to handle selected date and time
                            final selectedDateTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                            _dateTimeController.text =
                                "${selectedDateTime.toLocal()}";
                          }
                        });
                      }
                    });
                  },
                  onSaved: (newValue) {
                    _dateTime = DateTime.parse(newValue!);
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Mensaje",
                    hintText: "Escribe un mensaje (opcional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  maxLines: 5,
                  onSaved: (newValue) {
                    _message = newValue;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Al crear un servicio, aceptas nuestros términos y condiciones.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Selector<TicketNotifier, TicketStatus>(
        // Usamos Selector para escuchar solo cambios en el estado del
        // TicketNotifier. De esta forma evitamos llamar a context.watch y
        // limitamos las reconstrucciones al botón.
        selector: (_, notifier) => notifier.status,
        builder: (context, status, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: () async {
                if (_formKey.currentState == null ||
                    !_formKey.currentState!.validate()) {
                  return;
                }
                final service =
                    ModalRoute.of(context)?.settings.arguments as ServiceModel;
                _formKey.currentState?.save();

                final notifier = context.read<TicketNotifier>();
                try {
                  if (notifier.status == TicketStatus.loading) return;
                  await notifier.createTicket(
                    name: _name!,
                    address: _address!,
                    date: _dateTime!,
                    comment: _message,
                    serviceDocumentId: service.documentId,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Servicio creado exitosamente')),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.routeName,
                    (_) => false,
                  );
                } catch (err) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear el servicio: $err')),
                  );
                }
              },
              child: status == TicketStatus.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Crear Servicio"),
            ),
          );
        },
      ),
    );
  }
}
