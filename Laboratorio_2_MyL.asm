.data

	inputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/input.txt"
	textoClaro: .space 1024
	longitudMensaje: .word 0
	
	textoClaveCorta: .asciiz "Ingrese la palabra que desea utilizar como clave corta (no mayor a 12 caracteres):   "
	claveCorta: .space 12	# Cantidad maxima de caracteres en la clave corta
	
	claveExtendida: .space 1024
	
	outputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/criptogram.txt"
	mensajeCifrado: .space 1024
	
	decodedOutputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/decoded.txt"
	mensajeDecifrado: .space 1024
	
	textoDeErrorDocumento: .asciiz "No se pudo leer el documento"

.text

	main:
		#--------------------------- Cifrado --------------------------#
	
		# Leer mensaje de inputFile
		la $a1, inputFile
		la $a3, textoClaro
		jal leerMensaje
		
		# Leer clave corta
		jal leerClaveCorta
		
		# Crear clave extendida
		jal crearClaveExtendida
		
		# Cifrar mensaje
		jal cifrarMensaje
		
		# Escribir mensaje cifrado
		la $a1, outputFile
		la $a3, mensajeCifrado
		jal escribir
		
		
		#--------------------------- Decifrado --------------------------#
		
		# Leer mensaje de outputFile
		la $a1, outputFile
		la $a3, mensajeCifrado
		jal leerMensaje
		
		# Decifrar mensaje
		jal decifrarMensaje
		
		# Escribir mensaje decifrado
		la $a1, decodedOutputFile
		la $a3, mensajeDecifrado
		jal escribir
		
	li $v0, 10
	syscall
		
	
		
				
#---------------------------------------- DECLARACION DE FUNCIONES ----------------------------------------#
	
	# Descripción:
	#	- Recibe a traves de $a1 una direccion de archivo de
	#	  texto para abrir, leer y cierrar utilizando
	#	  los SYSCALL 13, 14 y 16 respectivamente
	#	- Almacena el mensaje leido en el buffer que se le
	#	  pasa como argumento a traves de $a3
	#	- Contiene un error handler para dejarle saber al
	#	  usuario si el archivo indicado no se pudo abrir
	#	- Como al leer el archivo, $v0 almacena el total de
	#	  caracteres leidos, entonces este valor se almacena
	#	  en el buffer longitudMensaje
	#
	# Entradas:
	#	$a1: contiene la dirección del archivo de texto que se va a leer
	#	$a3: contiene en buffer en donde se almacenará el mensaje leido
	leerMensaje:
	
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
    		
    		la $t1, longitudMensaje
		sw $s0, 0($t1)
    		
    		#-------------------------- Cerrar archivo --------------------------#
    		li $v0, 16
        	move $a0, $t0
        	syscall
        	
        jr $ra
        
        
        escribir:
        # Esta funcion se encarga de la apertura, escritura y cierre ideal para el archivo de texto
	# a manejar dentro del codigo partir de direccion_archivo_guardar dentro de la carpeta.
        	#--------------------------- Abrir archivo --------------------------#
        	li $v0, 13
    		la $a0, ($a1)
    		li $a1, 1               # 1 para escritura
    		li $a2, 0 
    		syscall
    		move $t0, $v0
    		
    		bltz $t0, errorHandlerDocumento
    		
    		#--------------------------- Escribir mensaje cifrado ---------------------------#
    		li $v0, 15
    		move $a0, $t0
    		la $a1, ($a3)
    		lw $a2, longitudMensaje
    		syscall
    		
    		#-------------------------- Cerrar archivo --------------------------#
    		li $v0, 16
		move $a0, $t0
       	 	syscall
        
        jr $ra
        
        
        leerClaveCorta:
        
        	li $v0, 4
		la $a0, textoClaveCorta
		syscall
		
		li $v0, 8
		la $a0, claveCorta
		li $a1, 12
		syscall
		
        jr $ra
        
        
        crearClaveExtendida:
        
        	la $t6, claveExtendida
        	la $s1, claveCorta
        	
        	copiarClaveCorta:
        		li $t0, 0	     
			li $t1, 12
			la $s1, claveCorta
       
     	   	recorrerClaveCorta:
        		beq $t0, $t1, completarClaveExtendida
    			add $t2, $s1, $t0   
			lb $t4, 0($t2)       
		
			add $t2, $t6, $t0   
			sb $t4, 0($t2)       

			addi $t0, $t0, 1  
			j recorrerClaveCorta
        
        		completarClaveExtendida:
       	 			la $s0, textoClaro
				li $t0, 0		
				li $t1, 1012
    		
    		recorrerMensaje:
    			beq $t0, $t1, terminarCompletado

			add $t2, $s0, $t0    
			lb $t4, 0($t2)     
	
			add $t2, $t6, $t0
			sb $t4, 12($t2)     

			addi $t0, $t0, 1 
			j recorrerMensaje

		terminarCompletado:
		
       	 jr $ra
        
        
        cifrarMensaje:
        
        	move $s2, $t6
		la $t6, mensajeCifrado
		li $t0, 0              
		lw $t1, longitudMensaje         
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
        
               
                             
        decifrarMensaje:
        
        	la $s0, mensajeCifrado
		la $s2, claveExtendida
		la $t6, mensajeDecifrado
		li $t0, 0                  
		lw $t1, longitudMensaje           
		li $t7, 128
        
    		
    		recorrerTextoCifrado:
    		
    			beq $t0, $t1, terminarDecifrado
	
		
			add $t2, $s0, $t0
			lb $t4, 0($t2)
	
		
			add $t2, $s2, $t0
			lb $t5, 0($t2)
	
		
			sub $t3, $t4, $t5
			addi $t3, $t3, 128
			rem $t3, $t3, $t7	
		
		
			add $t2, $t6, $t0
			sb $t3, 0($t2)
	
			addi $t0, $t0, 1
			j recorrerTextoCifrado
    			
    		terminarDecifrado:
    		
        jr $ra
     	
    		
#--------------------------------------------- ERROR HANDLERS ---------------------------------------------#

	errorHandlerDocumento:
		li $v0, 4
    		la $a0, textoDeErrorDocumento
    		syscall
    		
    		li $v0, 10
    		syscall
    		
	jr $ra
