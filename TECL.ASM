; TECL.ASM — Versión compatible con DOSBox y Emuladores

[BITS 16]
[ORG 0x100]     ; programa .COM

start:
    ; === ESPERAR TECLA MEDIANTE BIOS (Compatible con DOSBox) ===
    ; La función AH=00h de la INT 16h suspende la ejecución de forma segura
    ; hasta que el usuario presione una tecla.
    MOV AH, 00h
    INT 16h     ; Al regresar: AH = Scancode, AL = Caracter ASCII

    ; === LECTURA DEL SCANCODE ===
    ; Movemos el Scancode (que la BIOS leyó del puerto 60h/64h) a BL
    MOV BL, AH  

    ; === MOSTRAR SCANCODE EN PANTALLA (Conversión Hexadecimal) ===
    
    ; 1. Procesar el Nibble Alto (los 4 bits de la izquierda)
    MOV AH, 02h ; Función DOS: imprimir carácter
    MOV DL, BL
    SHR DL, 4   ; Dejar solo el nibble alto
    ADD DL, 30h ; Convertir a ASCII
    CMP DL, 3Ah ; ¿Es mayor que '9'?
    JL .printH
    ADD DL, 07h ; Ajuste para letras A-F
.printH:
    INT 21h     ; Imprimir primer dígito

    ; 2. Procesar el Nibble Bajo (los 4 bits de la derecha)
    MOV DL, BL
    AND DL, 0Fh ; Enmascarar para dejar solo el nibble bajo
    ADD DL, 30h ; Convertir a ASCII
    CMP DL, 3Ah ; ¿Es mayor que '9'?
    JL .printL
    ADD DL, 07h ; Ajuste para letras A-F
.printL:
    INT 21h     ; Imprimir segundo dígito

    ; === IMPRIMIR SALTO DE LÍNEA ===
    MOV AH, 02h
    MOV DL, 0Dh ; CR
    INT 21h
    MOV DL, 0Ah ; LF
    INT 21h

    ; === TERMINAR PROGRAMA ===
    MOV AH, 4Ch
    INT 21h     ; Volver a DOS