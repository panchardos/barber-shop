import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_theme.dart';

enum AdminSection { agenda, servicios, configuracion, historial }

class AdminScaffold extends StatelessWidget {
  final AdminSection selected;
  final Widget body;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.selected,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menú',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Panel Control'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.adminConfiguracion,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _AdminDrawer(selected: selected),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final AdminSection selected;

  const _AdminDrawer({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppColors.azulNoche,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LA NOTA',
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Panel de administración',
                    style: TextStyle(color: AppColors.grisBorde, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.calendar_today_outlined,
              label: 'Agenda',
              selected: selected == AdminSection.agenda,
              onTap: () => _navegar(context, AdminSection.agenda),
            ),
            _DrawerItem(
              icon: Icons.content_cut_outlined,
              label: 'Servicios',
              selected: selected == AdminSection.servicios,
              onTap: () => _navegar(context, AdminSection.servicios),
            ),
            _DrawerItem(
              icon: Icons.access_time_outlined,
              label: 'Configuración',
              selected: selected == AdminSection.configuracion,
              onTap: () => _navegar(context, AdminSection.configuracion),
            ),
            _DrawerItem(
              icon: Icons.history,
              label: 'Historial',
              selected: selected == AdminSection.historial,
              onTap: () => _navegar(context, AdminSection.historial),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Volver al sitio'),
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navegar(BuildContext context, AdminSection section) {
    final navigator = Navigator.of(context);
    if (section == selected) {
      navigator.pop();
      return;
    }

    final route = switch (section) {
      AdminSection.agenda => AppRoutes.admin,
      AdminSection.servicios => AppRoutes.adminServicios,
      AdminSection.configuracion => AppRoutes.adminConfiguracion,
      AdminSection.historial => AppRoutes.adminHistorial,
    };
    navigator.pop();
    navigator.pushReplacementNamed(route);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.negro : AppColors.grisTexto,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.negro,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.grisFondo,
      onTap: onTap,
    );
  }
}
