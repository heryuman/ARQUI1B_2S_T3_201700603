.global _start          // Define el punto de entrada global para el enlazador ld

.section .data

// Textos informativos para la salida en consola
mensaje_original:
    .ascii "Arreglo original:  "
longitud_mensaje_original = . - mensaje_original

mensaje_burbuja:
    .ascii "Arreglo BubbleSort: "
longitud_mensaje_burbuja = . - mensaje_burbuja

mensaje_seleccion:
    .ascii "Arreglo SelectSort: "
longitud_mensaje_seleccion = . - mensaje_seleccion

caracter_salto_linea:
    .ascii "\n"

caracter_espacio:
    .ascii " "

// Arreglos de prueba 10 elementos de 64 bits = 8 bytes por número
arreglo_burbuja:
    .quad 45, 12, 89, 3, 67, 23, 90, 1, 34, 56
tamano_arreglo = (. - arreglo_burbuja) / 8    // 80 bytes / 8 bytes = 10 elementos

arreglo_seleccion:
    .quad 45, 12, 89, 3, 67, 23, 90, 1, 34, 56

// Búfer en memoria reservado para la conversión de enteros a formato ASCII
bufer_conversion_numero:
    .skip 32                            // Reserva 32 bytes en la sección de datos

.section .text

_start:
    ldr x0, =mensaje_original         // Pasa la dirección del mensaje inicial
    mov x1, longitud_mensaje_original      // Pasa la longitud del texto
    bl imprimir_cadena_texto      // Llama a la función para escribir en consola

    ldr x0, =arreglo_burbuja // Pasa la dirección del arreglo no ordenado
    mov x1, tamano_arreglo // Pasa la cantidad de elementos 10
    bl imprimir_elementos_arreglo // Imprime el arreglo en pantalla

    ldr x0, =arreglo_burbuja// Parámetro 1 x0: Dirección base del arreglo
    mov x1, tamano_arreglo  // Parámetro 2 x1: Cantidad de elementos
    bl ordenamiento_burbuja // Ejecuta la función de ordenamiento

    // Imprimir el resultado obtenido con Bubble Sort
    ldr x0, =mensaje_burbuja  // Pasa el encabezado
    mov x1, longitud_mensaje_burbuja //pasa longitud mensaje burbuja
    bl imprimir_cadena_texto

    ldr x0, =arreglo_burbuja  // Pasa la dirección del arreglo ya ordenado
    mov x1, tamano_arreglo
    bl imprimir_elementos_arreglo// Muestra los números en orden ascendente

    ldr x0, =arreglo_seleccion // Parámetro 1 x0: Dirección base
    mov x1, tamano_arreglo// Parámetro 2 x1: Cantidad de elementos
    bl ordenamiento_seleccion // Ejecuta la función de ordenamiento

    // Imprimir el resultado obtenido con Selection Sort
    ldr x0, =mensaje_seleccion// Pasa el encabezado
    mov x1, longitud_mensaje_seleccion
    bl imprimir_cadena_texto

    ldr x0, =arreglo_seleccion// Pasa la dirección del arreglo ya ordenado
    mov x1, tamano_arreglo // pasa tamaño del arreglo              
    bl imprimir_elementos_arreglo// Muestra los números en orden ascendente

    mov x8, 93// Identificador de la syscall exit en Linux ARM64
    mov x0, 0 // Código de salida 0 
    svc 0 // Genera la interrupción al sistema operativo

// FUNCIÓN: ordenamiento_burbuja
// Entrada:
//   x0 = dirección base del arreglo de enteros de 64 bits
//   x1 = cantidad total de elementos en el arreglo
ordenamiento_burbuja:
    // Preservación del Frame Pointer y registros protegidos según la convención AAPCS64
    stp x29, x30, [sp, -48]! // Reserva 48 bytes en el Stack y guarda x29 FP y x30 LR
    mov x29, sp              // Establece la base del nuevo marco de pila
    stp x19, x20, [sp, 16]   // Preserva x19 y x20
    stp x21, x22, [sp, 32]   // Preserva x21 y x22

    // Validación de seguridad: si el arreglo tiene 1 o 0 elementos, ya está ordenado
    cmp x1, 1
    ble fin_ordenamiento_burbuja

    mov x19, x0 // x19 = Dirección de memoria base del arreglo
    mov x20, x1 // x20 = N Cantidad total de elementos

    mov x21, 0 // x21 contador de indice 

ciclo_externo_burbuja:
    cmp x21, x20   // compara contador
    b.ge fin_ordenamiento_burbuja// Si indice_i >= N, finaliza el algoritmo

    mov x22, 0       // x22 = indice_j Contador del ciclo interno, reinicia en 0
    sub x9, x20, x21 // x9 = N - indice_i
    sub x9, x9, 1    // x9 = Limite_j = N - indice_i - 1

ciclo_interno_burbuja:
    cmp x22, x9     // compara indice
    b.ge siguiente_pasada_ciclo_externo_burbuja  // Si indice_j >= Limite_j, pasa al siguiente ciclo i

    // Cálculo de direcciones de memoria: direccion = base + indice_j * 8 bytes
    lsl x10, x22, 3   // x10 = indice_j * 8 Desplazamiento para enteros de 64 bits
    add x11, x19, x10 // x11 = Dirección exacta de memoria de arreglo[j]

    ldr x12, [x11]    // x12 = Valor almacenado en arreglo[j]
    ldr x13, [x11, 8] // x13 = Valor almacenado en arreglo[j + 1]

    // Comparación entre elementos contiguos para determinar el orden
    cmp x12, x13  // Compara arreglo[j] contra arreglo[j + 1]
    b.ls omitir_intercambio_burbuja // Si arreglo[j] <= arreglo[j+1], están bien ordenados

intercambiar_elementos_burbuja:
    // Si arreglo[j] > arreglo[j+1], intercambia las posiciones en memoria 
    str x13, [x11] // Almacena arreglo[j+1] en la posición j
    str x12, [x11, 8] // Almacena arreglo[j] en la posición j+1

omitir_intercambio_burbuja:
    add x22, x22, 1  // indice_j++ Avanza a la siguiente pareja de elementos
    b ciclo_interno_burbuja // Regresa al inicio del ciclo interno

siguiente_pasada_ciclo_externo_burbuja:
    add x21, x21, 1  // indice_i++ Avanza una pasada completa
    b ciclo_externo_burbuja // Regresa al inicio del ciclo externo

fin_ordenamiento_burbuja:
    // Restauración de registros y de la pila 
    ldp x21, x22, [sp, 32] // Restaura x21 y x22
    ldp x19, x20, [sp, 16] // Restaura x19 y x20
    ldp x29, x30, [sp], 48 // Restaura Frame Pointer y Link Register, libera 48 bytes
    ret  // Retorna a la función invocadora

// FUNCIÓN: ordenamiento_seleccion 
// Entrada:
//   x0 = dirección base del arreglo de enteros de 64 bits
//   x1 = cantidad total de elementos en el arreglo
ordenamiento_seleccion:
    stp x29, x30, [sp, -64]! // Preservación del Stack Frame Reserva 64 bytes alineados
    mov x29, sp
    stp x19, x20, [sp, 16] // Preserva x19 y x20
    stp x21, x22, [sp, 32] // Preserva x21 y x22
    stp x23, x24, [sp, 48] // Preserva x23 y x24

    // Validación de seguridad para arreglos de tamaño 1 o menor
    cmp x1, 1
    ble fin_ordenamiento_seleccion

    mov x19, x0 // x19 = Dirección base del arreglo
    mov x20, x1 // x20 = N Cantidad total de elementos

    mov x21, 0 // x21 = indice_i Punto inicial de búsqueda, de 0 a N-2
    sub x9, x20, 1// x9 = N - 1

ciclo_externo_seleccion:
    cmp x21, x9  // ¿Se han colocado los elementos en sus posiciones?
    b.ge fin_ordenamiento_seleccion // Si indice_i >= N - 1, el arreglo ya está ordenado

    mov x22, x21 // x22 = indice_minimo Asume inicialmente que arreglo[i] es el mínimo
    add x23, x21, 1 // x23 = indice_j = indice_i + 1 Empieza a buscar desde el siguiente elemento

buscar_minimo_seleccion:
    cmp x23, x20  // ¿Llegamos al final del arreglo en el ciclo de búsqueda?
    b.ge verificar_e_intercambiar_minimo // Si indice_j >= N, procede a colocar el mínimo en su lugar

    // Cargar el valor de arreglo[j]
    lsl x10, x23, 3 // x10 = indice_j * 8
    ldr x12, [x19, x10] // x12 = Valor en arreglo[j]

    // Cargar el valor del menor número encontrado hasta ahora: arreglo[indice_minimo]
    lsl x11, x22, 3  // x11 = indice_minimo * 8
    ldr x13, [x19, x11] // x13 = Valor en arreglo[indice_minimo]

    cmp x12, x13  // Compara arreglo[j] contra el arreglo[indice_minimo] actual
    b.hs omitir_actualizacion_minimo // Si arreglo[j] >= arreglo[indice_minimo], no hay cambio

actualizar_indice_minimo:
    mov x22, x23   // Guarda la posición j como la nueva posición del número mínimo

omitir_actualizacion_minimo:
    add x23, x23, 1   // indice_j++ Avanza a inspeccionar el siguiente elemento
    b buscar_minimo_seleccion // Continúa la búsqueda en el resto del arreglo

verificar_e_intercambiar_minimo:
    // Si el valor mínimo ya estaba en la posición inicial indice_minimo == indice_i, no hace falta intercambio
    cmp x22, x21
    b.eq siguiente_pasada_ciclo_externo_seleccion

    // Intercambio de valores en memoria: cambia arreglo[i] con arreglo[indice_minimo]
    lsl x10, x21, 3  // x10 = indice_i * 8
    lsl x11, x22, 3  // x11 = indice_minimo * 8

    ldr x12, [x19, x10] // x12 = Valor en arreglo[i]
    ldr x13, [x19, x11] // x13 = Valor en arreglo[indice_minimo]

    str x13, [x19, x10] // Escribe el valor mínimo en la posición i
    str x12, [x19, x11] // Mueve el antiguo valor i a la posición donde estaba el mínimo

siguiente_pasada_ciclo_externo_seleccion:
    add x21, x21, 1   // indice_i++
    b ciclo_externo_seleccion  // Vuelve al ciclo principal

fin_ordenamiento_seleccion:
    // Restauración de registros protegidos y retorno
    ldp x23, x24, [sp, 48]
    ldp x21, x22, [sp, 32]
    ldp x19, x20, [sp, 16]
    ldp x29, x30, [sp], 64 // Libera el marco de pila de 64 bytes
    ret


imprimir_elementos_arreglo:
    stp x29, x30, [sp, -32]!
    mov x29, sp
    stp x19, x20, [sp, 16]

    mov x19, x0 // x19 = Dirección del arreglo
    mov x20, x1 // x20 = Total de elementos
    mov x21, 0  // x21 = Contador de posición actual

ciclo_impresion_elementos:
    cmp x21, x20   // ¿Ya se imprimieron todos los elementos?
    b.ge fin_impresion_elementos

    lsl x10, x21, 3 // Posición actual * 8 bytes
    ldr x0, [x19, x10] // Carga el número entero de 64 bits
    bl convertir_e_imprimir_numero // Convierte a texto e imprime

    ldr x0, =caracter_espacio  // Imprime un espacio separador entre números
    mov x1, 1
    bl imprimir_cadena_texto

    add x21, x21, 1    // Posición++
    b ciclo_impresion_elementos

fin_impresion_elementos:
    ldr x0, =caracter_salto_linea  // Imprime salto de línea final
    mov x1, 1
    bl imprimir_cadena_texto

    ldp x19, x20, [sp, 16]
    ldp x29, x30, [sp], 32
    ret

convertir_e_imprimir_numero:
    stp x29, x30, [sp, -16]!
    mov x29, sp

    ldr x1, =bufer_conversion_numero
    add x1, x1, 30 // Apunta al final del búfer para llenar de derecha a izquierda
    mov x2, 10   // Divisor para base 10

ciclo_conversion_ascii:
    udiv x3, x0, x2 // x3 = x0 / 10
    msub x4, x3, x2, x0 // x4 = x0 - x3 * 10 Obtiene el residuo
    add x4, x4, '0'// Convierte el dígito numérico a su equivalente ASCII
    strb w4, [x1]// Guarda el carácter en el búfer
    sub x1, x1, 1// Mueve el puntero un byte a la izquierda
    mov x0, x3  // El cociente pasa a ser el nuevo dividendo
    cbnz x0, ciclo_conversion_ascii  // Mientras el cociente sea distinto de 0, repite el ciclo

    add x1, x1, 1 // Ajusta el puntero al primer carácter del texto
    ldr x2, =bufer_conversion_numero
    add x2, x2, 31
    sub x2, x2, x1 // Calcula la longitud de la cadena generada

    mov x0, x1 // Pasa la dirección inicial del texto generado
    mov x1, x2 // Pasa la longitud calculada
    bl imprimir_cadena_texto

    ldp x29, x30, [sp], 16
    ret

imprimir_cadena_texto:
    mov x2, x1 // Parámetro 3: Longitud del buffer
    mov x1, x0 // Parámetro 2: Dirección de la cadena
    mov x0, 1  // Parámetro 1: Salida estándar stdout = 1
    mov x8, 64 // Syscall 64 = sys_write en Linux ARM64
    svc 0  // Ejecuta la llamada al sistema
    ret