import 'package:flutter/material.dart';

import '../../../../../common/common.dart';
import '../../../clients.dart';

typedef OnAddContact = ValueChanged<Contact>;
typedef OnEditContact = void Function(Contact oldValue, Contact newValue);
typedef OnDeleteContact = ValueChanged<Contact>;

class ContactsList extends StatelessWidget {
  final OnAddContact onAdd;
  final OnEditContact onEdit;
  final OnDeleteContact onDelete;
  final List<Contact> contacts;

  const ContactsList(
    this.contacts, {
    Key? key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: kMediumEdgeInsets.copyWith(top: 0, bottom: 0),
      title: const Text('Contatos'),
      children: [
        for (final contact in contacts)
          ActionsSlider(
            onDelete: () => onDelete(contact),
            child: ContactListTile(
              contact,
              onTap: () => showContactForm(context, contact),
            ),
          ),
        Center(
          child: Padding(
            padding: kSmallEdgeInsets,
            child: SecondaryButton(
              child: const Text('Adicionar contato'),
              onPressed: () => showContactForm(context),
            ),
          ),
        ),
      ],
    );
  }

  void showContactForm(BuildContext context, [Contact? initialValue]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditContactForm(
          initialValue: initialValue,
          onCancel: () {
            Navigator.of(context).pop();
          },
          onSave: (contact) {
            if (initialValue != null) {
              onEdit(initialValue, contact);
            } else {
              onAdd(contact);
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactListTile(
    this.contact, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.contact),
      onTap: onTap,
    );
  }
}

class EditContactForm extends StatefulWidget {
  final Contact? initialValue;
  final ValueChanged<Contact> onSave;
  final VoidCallback onCancel;

  const EditContactForm({
    Key? key,
    required this.onSave,
    required this.onCancel,
    this.initialValue,
  }) : super(key: key);

  @override
  _EditContactFormState createState() => _EditContactFormState();
}

class _EditContactFormState extends State<EditContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _contactController.text = widget.initialValue!.contact;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kMediumEdgeInsets,
      child: Center(
        child: Material(
          child: Padding(
            padding: kMediumEdgeInsets,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.initialValue != null
                        ? 'Editar contato'
                        : 'Adicionar contato',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  kMediumSpacerVertical,
                  AppTextFormField(
                    name: 'Contato',
                    controller: _contactController,
                  ),
                  kMediumSpacerVertical,
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          child: const Text('Cancelar'),
                          onPressed: _cancel,
                        ),
                      ),
                      kSmallSpacerHorizontal,
                      Expanded(
                        child: PrimaryButton(
                          child: Text(widget.initialValue != null
                              ? 'Salvar'
                              : 'Adicionar'),
                          size: null,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _cancel() {
    widget.onCancel();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final contact = Contact(
        id: widget.initialValue?.id,
        contact: _contactController.text,
      );
      widget.onSave(contact);
    }
  }
}
