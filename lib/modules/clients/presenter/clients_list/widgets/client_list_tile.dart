import 'package:flutter/material.dart';
import 'package:kitchen_helper/common/common.dart';

import '../../../clients.dart';

class ClientListTile extends StatelessWidget {
  final ListingClientDto client;
  final VoidCallback onTap;

  const ClientListTile(
    this.client, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatTile(
      child: Text(
        client.name,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              fontWeight: FontWeight.w400,
            ),
      ),
      onTap: onTap,
    );
  }
}
