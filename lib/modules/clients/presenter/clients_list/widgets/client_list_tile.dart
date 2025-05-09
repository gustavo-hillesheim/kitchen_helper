import 'package:flutter/material.dart';

import '../../../../../common/common.dart';
import '../../../clients.dart';

class ClientListTile extends StatelessWidget {
  final ListingClientDto client;
  final VoidCallback onTap;

  const ClientListTile(
    this.client, {
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlatTile(
      onTap: onTap,
      child: Text(
        client.name,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
