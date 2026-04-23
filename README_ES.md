## 1. ¿Qué logramos con este script?

Este script automatiza la creación de respaldos de tus mundos de Minecraft Bedrock en Windows. Utilizando el potencial de **PowerShell**, el script localiza las carpetas de tus mundos, las empaqueta individualmente en el formato nativo `.mcworld` y las sincroniza directamente con tu cuenta de **OneDrive** configurada en el sistema.

![Estado de sincronización](img/onedrive_sync_status.png)

### El origen del proyecto
Esta solución nació durante mi proceso de aprendizaje con **Bash** y el descubrimiento del mundo del *scripting*. Buscaba una herramienta práctica que permitiera:
* **Seguridad:** Mantener un historial de copias ante posibles archivos corruptos por actualizaciones, errores de mods o borrados accidentales.
* **Portabilidad:** Facilitar la transición entre plataformas. Al generar archivos `.mcworld`, puedes descargar el respaldo desde OneDrive e importarlo directamente en dispositivos Android o iPadOS.

*Nota de desarrollo: Dado que mi experiencia previa se centraba en Bash, utilicé **Gemini** como apoyo para traducir esa lógica a la sintaxis de PowerShell. Esto me permitió construir una herramienta robusta entendiendo cómo cada comando gestiona la compresión y el respaldo de los datos del juego.*

> **Nota sobre la interfaz:** Verás que las capturas de pantalla de esta guía muestran el sistema en español, pero la disposición de los menús y botones es idéntica en cualquier idioma de Windows.

## 2. Requisitos previos

Para que el script funcione y se sincronice sin problemas, tu entorno debe cumplir con los siguientes puntos:

* **Cuenta de Microsoft:** Debes tener una sesión iniciada o logueada en tu sistema operativo.
* **OneDrive instalado:** La aplicación de escritorio de OneDrive debe estar instalada y vinculada a tu cuenta.
* **OneDrive en el arranque:** Debes tener habilitado a OneDrive como aplicación de inicio para asegurar que la sincronización en segundo plano siempre esté activa.
  
  ![Aplicaciones de arranque en el Administrador de tareas](img/startup_apps_taskmanager.png)

* **Carpeta de destino en OneDrive:** Crear o verificar que ya tengas creada una carpeta llamada `MINECRAFT` en la raíz de tu OneDrive. *(Nota: El script está programado para intentar crearla si no existe, pero es buena práctica verificar su ubicación).*
  
  ![Carpeta de destino en OneDrive](img/onedrive_folder.png)

* **Carpeta de origen en tu PC:** Verificar la ruta local y asegurarte de que la carpeta de los mundos de Minecraft Bedrock exista en su ubicación predeterminada dentro de tu equipo.
  
  ![Carpeta de mundos de Minecraft Bedrock](img/minecraft_bedrock_folder.png)

## 3. Automatizar la ejecución del script

Para que no tengas que preocuparte de hacer los respaldos manualmente, configuraremos Windows para que ejecute el script (`Minecraft-Backup-PowerShell-V1.ps1`) por ti en segundo plano.

### 3.1. Abrir el Programador de tareas
Busca **"Programador de tareas"** en tu menú de inicio de Windows y ábrelo. En el panel derecho (bajo el menú *Acciones*), haz clic en **Crear tarea...** (Asegúrate de no elegir "Crear tarea básica"). Esto abrirá una nueva ventana con varias pestañas donde configuraremos toda la automatización.

![Crear Tarea en el Programador de Tareas](img/task_scheduler_step1.png)

### 3.2. Ajustes en la Pestaña General

Una vez abierta la ventana, en la pestaña **General**, configuraremos la identidad y los permisos básicos de la tarea:
* **Nombre:** Asigna un nombre identificativo (por ejemplo, "Respaldo Minecraft").
* **Descripción:** Añade una breve descripción para saber qué hace la tarea.
* **Opciones de seguridad:** Asegúrate de marcar **"Ejecutar solo cuando el usuario haya iniciado sesión"** y, muy importante, **"Ejecutar con los privilegios más altos"**. Esto último garantiza que PowerShell tenga los permisos necesarios para comprimir y mover los archivos. 

El resto de los ajustes en esta pestaña los dejaremos tal cual están.

![Ajustes en la pestaña General](img/task_scheduler_step2.png)

### 3.3. Ajustes en la Pestaña Desencadenadores

Aquí configuraremos los horarios y la frecuencia con la que se ejecutará el script. En esta pestaña, haz clic en el botón **Nuevo...** situado en la parte inferior.

![Pestaña Desencadenadores](img/task_scheduler_step3.png)

Se abrirá una nueva ventana llamada "Nuevo desencadenador". Aquí haremos lo siguiente:

![Configuración del Nuevo Desencadenador](img/task_scheduler_step4.png)

* **Iniciar la tarea:** Selecciona **"Según una programación"**.
* **Frecuencia:** Escoge cada cuánto tiempo quieres que se ejecute. En mi caso, seleccioné **Semanalmente**.
* **Inicio y recurrencia:** Establece la fecha y hora de inicio; de ahí en adelante se ejecutará a esa misma hora. Luego, selecciona cada cuántas semanas y en qué días se realizará el respaldo. Yo lo configuré **cada 2 semanas, los días lunes**.
* **Configuración avanzada:** Activa la casilla **"Detener la tarea si se ejecuta durante más de:"**. Yo le asigne **30 minutos**, pero *ojo: esto dependerá de cuántos mundos tengas y cuán grandes sean*. Un respaldo pesado tomará más tiempo y no significa que el proceso se haya estancado o congelado, así que ajusta este tiempo a tu medida.
* Por último, revisa que esté activa la opción **"Habilitado"** en la parte inferior y haz clic en **Aceptar**.

### 3.4. Ajustes en la Pestaña Acciones

Aquí configuraremos lo que queremos que haga la tarea. En este caso, haremos que se ejecute PowerShell con permisos altos y en segundo plano, para que este a su vez ejecute nuestro script. Esto es necesario porque en Windows, por norma general, la ejecución directa de scripts `.ps1` está bloqueada por medidas de seguridad del sistema.

Ve a la pestaña **Acciones** y haz clic en el botón **Nueva...**.

![Pestaña Acciones](img/task_scheduler_step5.png)

Se abrirá una ventana de "Nueva acción". Aquí haremos lo siguiente:

![Configuración de Nueva Acción](img/task_scheduler_step6.png)

* **Acción:** Selecciona **"Iniciar un programa"**.
* **Programa o script:** Escribe `powershell.exe`
* **Agregar argumentos (opcional):** Copia y pega exactamente la siguiente línea:

```powershell
-ExecutionPolicy Bypass -WindowStyle Hidden -File "RUTA\Minecraft-Bedrock-Backup-PowerShell-V1.ps1"
```

> **(OJO: Es importante saber en qué carpeta tendrán el script .ps1 y es esa la ruta o carpeta que pondrán en RUTA)**

Una vez copiada la línea anterior con tu ruta ajustada, le damos en **Aceptar**.

### 3.5. Ajustes en la Pestaña Condiciones

En esta pestaña, debemos verificar que **todas las opciones estén desactivadas**. Esto asegura que, bajo ninguna circunstancia (como la activación del ahorro de energía o el uso de batería en una laptop), se vaya a detener u omitir la ejecución del script.

![Pestaña Condiciones](img/task_scheduler_step7.png)

### 3.6. Ajustes en la Pestaña Configuración

Aquí vamos a dar y quitar permisos para definir el comportamiento de la tarea. Asegúrate de tener activado y configurado estrictamente lo siguiente:

* **Permitir que la tarea se ejecute a petición:** (Nos permite ejecutarla manualmente en cualquier momento).
* **Ejecutar tarea lo antes posible si no hubo un inicio programado:** (Permite que el script se ejecute si no se pudo realizar antes, por ejemplo, si la computadora estaba apagada a la hora programada).
* **Detener la tarea si se ejecuta durante más de:** `30 minutos` (Aquí dependerá nuevamente de si tus mundos son muy grandes o si tienes muchos).
* **Detener tarea en ejecución si no finaliza cuando se solicite.**

El resto de las opciones las dejamos tal cual están.

![Pestaña Configuración](img/task_scheduler_step8.png)

Una vez revisado todo esto, haz clic en **Aceptar**. ¡Con este paso, habremos configurado correctamente la automatización total de nuestro script!

## 4. Prueba de funcionamiento

Para comprobar que todo funciona correctamente, vamos a ejecutar manualmente el script desde el mismo Programador de tareas. 

1. En la pantalla principal, haz clic en **Biblioteca del Programador de tareas**, que se encuentra en el panel izquierdo.
2. Luego, en el panel central, verás una lista de todas las tareas programadas de tu sistema. Busca la tarea que acabamos de crear y haz clic sobre ella para seleccionarla.
3. Finalmente, en el panel derecho (bajo la sección de *Elemento seleccionado*), haz clic en **Ejecutar**.

![Ejecutar tarea manualmente](img/task_scheduler_step9.png)

Una vez ejecutada, ve directamente a tu carpeta de OneDrive. ¡Allí podrás ver en tiempo real cómo se están respaldando tus mundos en formato `.mcworld`!

![Respaldos completados en OneDrive](img/onedrive_minecraftbackups_folder.png)

---
**¡Listo!** Tu sistema automatizado de respaldos está configurado y funcionando.
