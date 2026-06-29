# Wireframes

![Wireframes](assets/wireframes_ui.png)

## Flujo de Navegación del Sistema - La Nota Barber Shop

Este documento describe el recorrido secuencial e interacciones que realizan los usuarios (Clientes y Administradores) para completar las tareas principales definidas dentro del Producto Mínimo Viable (MVP).

---

### 1. Flujo del Cliente: Reserva Autónoma de Turnos (CU 1)
Este flujo representa el camino crítico del sistema público. Está diseñado con un enfoque "Mobile-First" para un scroll vertical continuo y fluido.

#### Paso 1: Acceso y Selección de Servicio
* **Pantalla de Origen:** El cliente ingresa a la URL pública del sistema desde el navegador de su teléfono celular (Safari iOS).
* **Interacción:** Lo primero que visualiza es la cabecera con la identidad de la Peluquería y el listado del catálogo de servicios. El usuario debe tocar una tarjeta de servicio (por ejemplo, "Corte de Pelo Clásico"). Al hacerlo, el componente de selección radial (`RadioButton`) se marca en negro, indicando que el servicio fue añadido al itinerario.

#### Paso 2: Selección Cronológica (Fecha y Hora)
* **Interacción:** El sistema habilita la interacción con el módulo del calendario y la grilla horaria que se encuentran inmediatamente abajo. 
* **Acción:** El usuario toca un día disponible en la cuadrícula del mes actual (los días pasados o no laborales se muestran deshabilitados y no permiten clics). Tras seleccionar el día, la grilla de horarios se actualiza en tiempo real mostrando los bloques de tiempo libres. El cliente selecciona un horario (por ejemplo, "09:00 hs") tocando el botón correspondiente.

#### Paso 3: Registro de Datos y Confirmación
* **Interacción:** El usuario se desplaza hacia la sección inferior donde se encuentran los campos de entrada de texto (*inputs*).
* **Acción:** Introduce su nombre completo y teléfono de contacto mediante el teclado nativo del dispositivo móvil.
* **Finalización del Flujo:** Una vez completados los campos, el usuario se posiciona sobre el botón `[ Confirmar Reserva ]`. Al presionarlo, los datos se envían al servidor, finalizando el proceso de reserva y bloqueando ese horario para otros clientes.

---

### 2. Flujo del Administrador: Gestión y Cancelación de Turnos (CU 2 y CU 3)
Este flujo describe el camino que realiza el Peluquero en su día a día para mantener la agenda limpia y actualizada desde su dispositivo de trabajo.

#### Paso 1: Consulta de la Agenda Diaria
* **Pantalla de Origen:** El administrador accede a la sección privada del sistema (`/admin`) e inicia sesión.
* **Visualización:** Se despliega la pantalla de control principal con un menú hamburguesa (`☰`) para navegación global y una barra horizontal de "burbujas de fechas" rápidas. Al tocar una burbuja (por ejemplo, "Mar 29"), el sistema renderiza una lista vertical con todos los turnos asignados a ese día, ordenados cronológicamente.

#### Paso 2: Disparo de la Acción de Cancelación
* **Acción:** El Peluquero identifica en la lista el turno que desea dar de baja (por ejemplo, el de las "09:30 hs de Carlos Gómez") y presiona el botón de interacción rápida marcado con una cruz `[X]` situado a la derecha de la tarjeta.

#### Paso 3: Confirmación Mediante Ventana Emergente (Modal)
* **Interrupción del Flujo:** El sistema congela la pantalla de la agenda aplicando una capa oscura traslúcida (`Overlay`) y despliega un cuadro de diálogo emergente (`Bottom Sheet / Modal`) en el centro exacto de la pantalla. Esto evita que el administrador realice clics accidentales en el fondo.
* **Toma de Decisión:** El modal muestra un mensaje de advertencia confirmando los datos del turno a eliminar. El administrador tiene dos opciones apiladas ergonómicamente:
    * **Opción A (Confirmar):** Presiona el botón negro `[ Sí, Cancelar Turno ]`. El sistema procesa la baja, cierra el modal, refresca la lista de la agenda (removiendo visualmente el turno) y libera el espacio en la web pública.
    * **Opción B (Abortar):** Presiona el botón secundario con borde gris `[ Volver Atrás ]`. El modal se cierra de inmediato y la agenda permanece intacta sin realizar cambios en la base de datos.