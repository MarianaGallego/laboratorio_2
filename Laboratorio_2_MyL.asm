.data

	inputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/input.txt"
	textoClaro: .space 1024
	longitudTexto: .word 0
	
	textoClaveCorta: .asciiz "Ingrese la palabra que desea utilizar como clave corta (no mayor a 12 caracteres):   "
	claveCorta: .space 12	# Cantidad maxima de caracteres en la clave corta
	longitudClaveCorta: .word 0
	
	claveExtendida: .space 1024
	
	outputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/criptogram.txt"
	textoCifrado: .space 1024
	
	decodedOutputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/decoded.txt"
	textoDescifrado: .space 1024
	
	textoDeErrorDocumento: .asciiz "No se pudo abrir el documento"

.text

	main:
		#--------------------------- Cifrado --------------------------#
	
		# Leer texto de inputFile
		la $a1, inputFile
		la $a3, textoClaro
		jal leerTexto
		
		# Leer clave corta
		jal leerClaveCorta
		
		# Crear clave extendida
		jal crearClaveExtendida
		
		# Cifrar texto
		jal cifrarTexto
		
		# Escribir texto cifrado
		la $a1, outputFile
		la $a3, textoCifrado
		jal escribir
		
		
		#--------------------------- Decifrado --------------------------#
		
		# Leer texto de outputFile
		la $a1, outputFile
		la $a3, textoCifrado
		jal leerTexto
		
		# Decifrar texto
		jal descifrarTexto
		
		# Escribir texto descifrado
		la $a1, decodedOutputFile
		la $a3, textoDescifrado
		jal escribir
		
	li $v0, 10
	syscall
		
	
		
				
#---------------------------------------- DECLARACION DE FUNCIONES ----------------------------------------#
	
	# Descripción:
	#	- Recibe a traves de $a1 una direccion de archivo de
	#	  texto para abrir, leer y cerrar utilizando
	#	  los SYSCALL 13, 14 y 16 respectivamente
	#	- Almacena el texto leido en el buffer que se le
	#	  pasa como argumento a traves de $a3
	#	- Contiene un error handler para dejarle saber al
	#	  usuario si el archivo indicado no se pudo abrir
	#	- Como al leer el archivo, $v0 almacena el total de
	#	  caracteres leidos, entonces este valor se almacena
	#	  en el buffer longitudTexto
	#
	# Entradas:
	#	$a1: contiene la dirección del archivo de texto que se va a leer
	#	$a3: contiene en buffer en donde se almacenará el texto leido
	leerTexto:
	
		#--------------------------- Abrir archivo --------------------------#	
    		li $v0, 13
    		la $a0, ($a1)
    		li $a1, 0
    		li $a2, 0
    		syscall
    		move $t0, $v0

    		bltz $t0, errorHandlerDocumento
    		
    		#--------------------------- Leer archivo ---------------------------#
    		li $v0, 14
    		move $a0, $t0
    		la $a1, ($a3)
    		li $a2, 1024
    		syscall
    		move $s0, $v0
    		
    		la $t1, longitudTexto
		sw $s0, 0($t1)
    		
    		#-------------------------- Cerrar archivo --------------------------#
    		li $v0, 16
        	move $a0, $t0
        	syscall
        	
        jr $ra
        
        
        # Descripción:
	#	- Recibe a traves de $a1 una direccion de archivo de
	#	  texto para abrir, escribir y cerrar utilizando
	#	  los SYSCALL 13, 15 y 16 respectivamente
	#	- Contiene un error handler para dejarle saber al
	#	  usuario si el archivo indicado no se pudo abrir
	#	- $a2 almacena el contenido de longitudTexto y
	#	  se utiliza para controlar cuantos caracteres se
	#	  deben escribir
	#
	# Entradas:
	#	$a1: contiene la dirección del archivo de texto en el que se va a escribir
	#	$a3: contiene en buffer que almacena los caracteres que se escribiran
        escribir:
        
        	#--------------------------- Abrir archivo --------------------------#
        	li $v0, 13
    		la $a0, ($a1)
    		li $a1, 1               # 1 para escritura
    		li $a2, 0 
    		syscall
    		move $t0, $v0
    		
    		bltz $t0, errorHandlerDocumento
    		
    		#---------------------- Escribir texto cifrado ----------------------#
    		li $v0, 15
    		move $a0, $t0
    		la $a1, ($a3)
    		lw $a2, longitudTexto
    		syscall
    		
    		#-------------------------- Cerrar archivo --------------------------#
    		li $v0, 16
		move $a0, $t0
       	 	syscall
        
        jr $ra
        
        
        # Descripción:
	#	- Utiliza el SYSCALL 4 para mostrarle al usuario
	#	  el texto almacenado en textoClaveCorta y pedirle
	#	  que ingrese la clave que desea usar
	#	- Utiliza el SYSCALL 8 para leer el string ingresado
	#	  por el usuario
	#	- Llama la funcion ajustarClaveCorta, y para esto le
	#	  resta -4 a $sp y en ese espacio almacena $ra que es
	#	  la direccion de memoria a la que debe volver cuando
	#	  termine de ejecutar la funcion
	#	- Utiliza el ciclo contarWhile para recorrer los
	#	  caracteres que acaba de leer y cuando termina de
	#	  contarlos, almacena la cantidad obtenida en el
	#	  espacio de memoria longitudClaveCorta
        leerClaveCorta:
        
        	li $v0, 4
		la $a0, textoClaveCorta
		syscall
		
		li $v0, 8
		la $a0, claveCorta
		li $a1, 1024
		syscall
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
    		
    		jal ajustarClaveCorta
    		
    		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#--------------------------- Contar caracteres ---------------------------#
		la $t1, claveCorta
		li $t2, 0

		contarWhile:
			lb $t3, 0($t1)
			
			beqz $t3, endContarWhile

			addi $t1, $t1, 1
			addi $t2, $t2, 1
		
			j contarWhile
		endContarWhile:
		
		la $t4, longitudClaveCorta
		sw $t2, 0($t4)
        
        jr $ra
        
        
        # Descripción:
	#	- Elimina el salto de linea que se almaceno
	#	  al final de la clave corta
	#	-Pone un cero como ultimo caracter
        ajustarClaveCorta:
        
		la $t0, claveCorta
		
		encontrarSalto:
    			lb $t1, 0($t0)
    			beqz $t1, eliminarSalto

    			addi $t0, $t0, 1
    			j encontrarSalto

		eliminarSalto:
    			addi $t0, $t0, -1
    			lb $t1, 0($t0)
    			li $t2, 10
	
    			beq $t1, $t2, reemplazar

    			j terminarAjuste

		reemplazar:
    			sb $zero, 0($t0)

		terminarAjuste:
		
        jr $ra
        
        
        # Descripción:
	#	- Llama las funciones copiarClaveCorta y
	#	  completarClaveExtendida que son las que se
	#	  encargan de conformar la clave extendida
	#	- Para cada llamado le resta -4 a $sp y en
	#	  ese espacio almacena $ra que es la direccion
	#	  de memoria a la que debe volver cuando
	#	  termine de ejecutar cada funcion
	#	- Aqui se le da valor a todos los parametros
	#	  que se utilizaran en las funciones invocadas
        crearClaveExtendida:
        
        	lw $s0, longitudTexto
        	lw $s1, longitudClaveCorta
        	
        	la $t3, claveCorta
        	la $t4, textoClaro
        	la $t5, claveExtendida
        	
        	li $t0, 0
        	li $t1, 0
        	li $t2, 0
        	
        	addi $sp, $sp, -4
		sw $ra, 0($sp)
    		
    		jal copiarClaveCorta
    		
    		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
    		
    		jal completarClaveExtendida
    		
    		lw $ra, 0($sp)
		addi $sp, $sp, 4
        
        jr $ra
        
        
        # Descripción:
	#	- Recorre el buffer que contiene la clave
	#	  corta y va copiando cada caracter en el
	#	  buffer claveExtendida
        copiarClaveCorta:
        
        	recorrerClaveCorta:
        	
        		beq $t0, $s1, terminarCopiaClave
    			lb $t6, 0($t3)
    			sb $t6, 0($t5)
    			addi $t3, $t3, 1
    			addi $t5, $t5, 1
    			addi $t0, $t0, 1
    			addi $t2, $t2, 1
    			
    			j recorrerClaveCorta
    			
    		terminarCopiaClave:
        
        jr $ra
        
        
        # Descripción:
	#	- Resta $s0 y $s1 para saber cuantos caracteres
	#	  del textoClaro debe tomar
	#	- Recorre el bufer que contiene el texto claro
	#	  y va almacenando los caracteres en el buffer
	#	  que contiene la clave extendida a partir de
	#	  la posicion dada por $t5, que contiene la 
	#	  posicion siguiente a la ultima posicion en
	#	  la que se almaceno un caracter.
	#	  El recorrido termina cuando el contador $t1 es 
	#	  igual al numero calculado de caracteres que debe tomar
        completarClaveExtendida:
        
        	sub $t7, $s0, $s1
    		
    		recorrerTexto:
    		
    			beq $t1, $t7, terminarCompletado

    			lb $t6, 0($t4)
    			sb $t6, 0($t5)
    			addi $t4, $t4, 1
    			addi $t5, $t5, 1
    			addi $t1, $t1, 1
    			j recorrerTexto

		terminarCompletado:
        
        jr $ra
        
        
        # Descripción:
	#	- Se encarga de cifrar cada caracter que esta en el
	#	  buffer textoClaro
	#	- Utiliza el ciclo recorrerTextoClaro para recorrer
	#	  los buffer textoClaro y claveExtendida y cifra
	#	  los caracteres utilizando la formula c = (m + k) mod l
	#
	# Registros utilizados:
	#   	$s0: direccion de textoClaro
	#   	$s2: direccion de claveExtendida
	#   	$t0: contador del bucle
	#   	$t1: longitusMensaje (límite del bucle)
	#   	$t2, $t3: resultado de operaciones aritmeticas
	#   	$t4, $t5: almacenamiento de caracteres extraidos
	#   	$t6: dirección base del textoCifrado (salida)
	#   	$t7: constante 128
        cifrarTexto:
        
        	la $s0, textoClaro
        	la $s2, claveExtendida
		la $t6, textoCifrado
		li $t0, 0              
		lw $t1, longitudTexto         
		li $t7, 128
		
        	recorrerTextoClaro:
        	
       	 		beq $t0, $t1, terminarCifrado	
	
			add $t2, $s0, $t0
			lb $t4, 0($t2)
	
			add $t2, $s2, $t0
			lb $t5, 0($t2)
	
			add $t3, $t5, $t4
			rem $t3, $t3, $t7	
	
			add $t2, $t6, $t0
			sb $t3, 0($t2)
	
			addi $t0, $t0, 1   
			 
			j recorrerTextoClaro
    			
		terminarCifrado:
		
        jr $ra
        
               
        # Descripción:
	#	- Se encarga de descifrar cada caracter que esta en el
	#	  buffer textoCifrado
	#	- Utiliza el ciclo recorrerTextoCifrado para recorrer
	#	  el buffer textoCifrado y a su vez va formando la
	#	  claveExtendida  de acuerdo al caracter que vaya
	#	  descifrando
	#	- Descifra los caracteres utilizando la formula
	#	  p = (c - k) mod l
	#
	# Registros utilizados:
	#   $s1: direccion de textoCifrado
	#   $s2: direccion de claveExtendida
	#   $t0: contador del bucle
	#   $t1: límite del bucle
	#   $t2, $t3: resultado de operaciones aritmeticas
	#   $t4, $t5: almacenamiento de caracteres extraidos
	#   $t6: dirección base del textoDescifrado (salida)
	#   $t7: constante 128                  
        descifrarTexto:
        
        	la $s1, textoCifrado
		la $s2, claveExtendida
		la $t6, textoDescifrado
		li $t0, 0                  
		lw $t1, longitudTexto           
		li $t7, 128
		li $t8, 0
        
    		recorrerTextoCifrado:
    		
    			beq $t0, $t1, terminarDescifrado
	
			add $t2, $s1, $t0
			lb $t4, 0($t2)
	
			add $t2, $s2, $t0
			lb $t5, 0($t2)
	
			sub $t3, $t4, $t5
			addi $t3, $t3, 128
			rem $t3, $t3, $t7
			
			rellenarClaveExtendida:	
						
				lw $t2, longitudClaveCorta
				
				beq $t2, $t8, claveCompleta
				
				add $t2, $s2, $t2
				add $t2, $t2, $t0
				sb $t3, 0($t2)
				addi $t8, $t8, 1
				
			claveCompleta:	
		
			add $t2, $t6, $t0
			sb $t3, 0($t2)
	
			addi $t0, $t0, 1
			
			j recorrerTextoCifrado
    			
    		terminarDescifrado:
        jr $ra
     	
    		
#--------------------------------------------- ERROR HANDLERS ---------------------------------------------#

	# Descripción:
	#	- Utiliza el SYSCALL 4 para mostrar los caracteres
	#	  almacenados en textoDeErrorDocumento, indicandole
	#	  al usuario que el archivo no se pudo abrir
	#	- Utiliza el SYSCALL 10 para terminar la ejecucion
	#	  del programa
	errorHandlerDocumento:
		li $v0, 4
    		la $a0, textoDeErrorDocumento
    		syscall
    		
    		li $v0, 10
    		syscall
    		
	jr $ra
