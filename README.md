# Laboratorio: Entrada y Salida Avanzados

**Curso:** Arquitectura de Computadores  
**Herramientas:** NASM 2.x + DOSBox 0.74-3  
**Directorio de trabajo:** `C:\U9P1\` dentro de DOSBox

---

## Descripción

Este laboratorio implementa en ensamblador x86 el acceso directo a puertos de E/S mediante las instrucciones `IN` y `OUT`, aplicando la técnica de polling para sincronización con dos dispositivos: el controlador de teclado 8042 y el puerto paralelo LPT1.

---

## Archivos

| Archivo | Descripción |
|---|---|
| `TECL.ASM` | Lee el scancode del teclado haciendo polling sobre el puerto 64h |
| `POLL_T.ASM` | Polling con contador de timeout para evitar bloqueo infinito |
| `LPT1.ASM` | Envía el carácter 'A' al puerto paralelo LPT1 con protocolo Centronics |

---

## Prerrequisitos

- DOSBox 0.74 o superior
- NASM 2.x disponible en el PATH de DOSBox
- Conocimiento de instrucciones IN/OUT e INT 21h

---

## Configuración del Entorno

Desde DOSBox, crear el directorio de trabajo y verificar NASM:

```
MOUNT C C:\DOSBOX
C:
mkdir U9P1
cd U9P1
nasm -v
```

Copiar los archivos `.ASM` en `C:\U9P1\`.

---

## Compilar y Ejecutar

```
nasm -f bin TECL.ASM   -o TECL.COM
nasm -f bin POLL_T.ASM -o POLL_T.COM
nasm -f bin LPT1.ASM   -o LPT1.COM
```

Ejecutar cada programa escribiendo su nombre:

```
TECL
POLL_T
LPT1
```

---

## Descripción de Cada Programa

### TECL.ASM — Lectura del teclado con polling

Este programa interactúa directamente con el controlador de teclado clásico Intel 8042. Su objetivo es capturar el scancode (el código de hardware único) de cualquier tecla presionada y mostrarlo en la pantalla en formato hexadecimal (por ejemplo, al presionar la A, debe imprimir 1E). Para lograrlo, realiza un sondeo (polling) en el registro de estado buscando el bit OBF (Output Buffer Full) y luego convierte el valor binario a caracteres ASCII legibles.

**Resultado esperado:** Al presionar "A" (scancode 1Eh), muestra `1E`.

---

### POLL_T.ASM — Polling con timeout

Igual que TECL pero con un contador en el registro `CX` inicializado en `MAX_RETRY`. Si `CX` llega a 0 sin recibir dato, muestra el mensaje de timeout y termina. Usa la instrucción `LOOP` que decrementa `CX` automáticamente y salta si `CX ≠ 0`.

**Para probar timeout:** Dejar `MAX_RETRY EQU 0005h` y ejecutar sin presionar ninguna tecla.  
**Resultado esperado:** `Timeout: sin respuesta del dispositivo`

**Para uso normal:** Cambiar a `MAX_RETRY EQU 0FFFFh`.

---

### LPT1.ASM — Escritura al puerto paralelo

Implementa el protocolo Centronics sobre los puertos `0x378`–`0x37A`:

**Comportamiento en DOSBox:** Este programa simula la transferencia de datos a través del Puerto Paralelo LPT1 (estándar Centronics), el cual se utilizaba históricamente para conectar impresoras. El flujo consiste en colocar el byte 41h (la letra 'A' en ASCII) en el puerto de datos (0x378) y generar un pulso eléctrico manual en la línea STROBE a través del puerto de control (0x37A), manteniendo la señal en bajo durante un microsegundo mediante un bucle de retraso (LOOP) para que el periférico procese el dato.

---

## Comportamiento Observado en DOSBox

| Programa | Comportamiento |
|---|---|
| `TECL.COM` | Espera una pulsación y muestra su scancode en hex |
| `POLL_T.COM` | Con `MAX_RETRY=0005h` muestra timeout sin presionar tecla |
| `LPT1.COM` | Ejecuta sin bloqueo; el acceso a puerto no genera error en DOSBox |

---

## Conceptos Clave

- **IN AL, puerto** — Lee 1 byte del puerto de E/S hacia AL
- **OUT puerto, AL** — Escribe 1 byte de AL hacia el puerto de E/S
- **TEST AL, máscara** — Verifica bits específicos sin modificar AL (AND lógico que solo afecta flags)
- **LOOP etiqueta** — Decrementa CX y salta si CX ≠ 0; útil para contadores de timeout y retardos
- **OBF (Output Buffer Full)** — Bit 0 del puerto 64h; vale 1 cuando el 8042 tiene un dato listo
- **STROBE#** — Señal activa en bajo del protocolo Centronics; indica al periférico que el dato es válido
