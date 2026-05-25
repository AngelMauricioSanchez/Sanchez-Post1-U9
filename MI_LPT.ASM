; MI_LPT.ASM — Envío de un carácter al puerto paralelo LPT1 (Versión Limpia)
; Compila: nasm -f bin MI_LPT.ASM -o MI_LPT.COM

[BITS 16]
[ORG 0x100]

DATA_PORT   EQU 0378h
STATUS_PORT EQU 0379h
CTRL_PORT   EQU 037Ah

start:
    ; === VERIFICACIÓN DE ESTADO (Seguro para DOSBox) ===
    ; Usamos DX para cargar la dirección del puerto de 16 bits (0379h)
    ; MOV DX, STATUS_PORT
    ; IN AL, DX
    ; TEST AL, 80h        ; bit 7: BUSY#
    ; JZ start            ; Si prefieres dejar el bucle, apunta a 'start' o déjalo comentado

    ; === ENVIAR CARÁCTER "A" (0x41) ===
    MOV AL, 41h
    MOV DX, DATA_PORT       ; Cargamos el puerto 0378h en DX
    OUT DX, AL              ; Enviamos el dato al bus D0-D7

    ; === PULSO STROBE (Bit 0 del puerto de control, activo en bajo) ===
    MOV DX, CTRL_PORT       ; Cargamos el puerto 037Ah en DX
    IN AL, DX               ; Leer el estado actual del puerto de control
    AND AL, 0FEh            ; STROBE = 0 (Activar señal de lectura, forzar bit 0 a 0)
    OUT DX, AL              ; Enviar el comando al puerto

    ; Retardo mínimo (~1µs en DOSBox para dar tiempo al periférico)
    MOV CX, 0Fh
.delay: 
    LOOP .delay

    OR AL, 01h              ; STROBE = 1 (Desactivar señal, forzar bit 0 a 1)
    OUT DX, AL              ; Enviar de vuelta al puerto de control

    ; === TERMINAR PROGRAMA ===
    MOV AH, 4Ch
    INT 21h                 ; Regresar a DOS con éxito