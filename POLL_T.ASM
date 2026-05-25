; =============================================================
; POLL_T.ASM — Polling con timeout para el puerto de teclado
; =============================================================
[BITS 16]
[ORG 0x100]

MAX_RETRY EQU 0005h     ; <-- Cambiar a 0FFFFh para uso normal

; -------------------------------------------------------------
; SECCIÓN DE CÓDIGO
; -------------------------------------------------------------
start:

    MOV CX, MAX_RETRY   ; CX = número máximo de intentos

.poll:
    IN AL, 64h          ; Leer registro de estado del 8042
    TEST AL, 01h        ; Verificar bit 0 (OBF = Output Buffer Full)
    JNZ .dato_listo     ; Si OBF=1 (ZF=0), hay dato disponible

    LOOP .poll          ; Decrementar CX; si CX≠0, repetir polling
                        ; Si CX llega a 0, continúa a la siguiente línea

    MOV AH, 09h         ; INT 21h / AH=09h: imprimir cadena terminada en '$'
    MOV DX, msg_timeout ; DX apunta al mensaje de timeout
    INT 21h
    JMP .fin            ; Saltar al final del programa

.dato_listo:
    IN AL, 60h          ; Leer scancode del Data Port (puerto 60h)
    MOV AH, 02h         ; INT 21h / AH=02h: imprimir carácter en DL
    MOV DL, AL          ; DL = byte leído del puerto
    INT 21h             ; Mostrar el byte recibido

.fin:

    MOV AH, 4Ch
    XOR AL, AL          ; Código de salida = 0
    INT 21h

; -------------------------------------------------------------
; SECCIÓN DE DATOS
; -------------------------------------------------------------
msg_timeout DB 'Timeout: sin respuesta del dispositivo$'
            ; Cadena terminada en '$' requerida por INT 21h/AH=09h