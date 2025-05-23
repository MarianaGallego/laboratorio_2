.data

	inputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura - Laboratorio 2/input.txt"
	mensaje: .space 1024
	longitudMensaje: .word 0
	
	textoClaveCorta: .asciiz "Ingrese la palabra que desea utilizar como clave corta:   "
	claveCorta: .space 1023
	
	textoDeErrorDocumento: .asciiz "No se pudo leer el documento"

.text

	main:
	
		# Leer mensaje de inputFile
		la $a3, inputFile
		jal leerMensaje
		
		# Leer clave corta
		jal leerClaveCorta
		
		# Mostrar mensaje leido
		jal mostrarMensaje
		
	li $v0, 10
	syscall
		
		
#---------------------------------------- DECLARACIÓN DE FUNCIONES ----------------------------------------#
		
	leerMensaje:

		#--------------------------- Abrir archivo --------------------------#
    		li $v0, 13
    		la $a0, ($a3)
    		li $a1, 0
    		li $a2, 0
    		syscall
    		move $t0, $v0

    		
    		bltz $t0, errorHandlerDocumento
    		
    		#--------------------------- Leer archivo ---------------------------#
    		li $v0, 14
    		move $a0, $t0
    		la $a1, mensaje
    		li $a2, 1024
    		syscall
    		
    		#-------------------------- Cerrar archivo --------------------------#
    		li $v0, 16
        	move $a0, $t0
        	syscall
        	
        	#------------------- Contar cantidad de bytes -------------------#
		la $t1, mensaje
		li $t2, 0

		contarWhile:
			lb $t3, 0($t1)

			addi $t1, $t1, 1
			addi $t2, $t2, 1
		
			beqz $t3, endContarWhile
		
			j contarWhile
		endContarWhile:
		
		sub $t2, $t2, 1
		
		la $t1, longitudMensaje
		sw $t2, 0($t1)
        	
        jr $ra
        
        
        leerClaveCorta:
        
        	li $v0, 4
		la $a0, textoClaveCorta
		syscall
		
		li $v0, 8
		la $a0, claveCorta
		li $a1, 1023
		syscall
        
        jr $ra
        
        
        
        mostrarMensaje:
        
        	la $t0, mensaje
        	
		mostrar_mensaje:
    			lb $t1, 0($t0)
    			beqz $t1, fin_mostrar_mensaje

    			li $v0, 11
    			move $a0, $t1
    			syscall

    			addi $t0, $t0, 1
    			j mostrar_mensaje

		fin_mostrar_mensaje:
		
		lw $a0, longitudMensaje
		li $v0, 1
		syscall
		
		li $v0, 4
		la $a0, claveCorta
		syscall
        	
    	jr $ra
    		
    		
#--------------------------------------------- ERROR HANDLERS ---------------------------------------------#

	errorHandlerDocumento:
	
		li $v0, 4
    		la $a0, textoDeErrorDocumento
    		syscall
    		
    		li $v0, 10
    		syscall
    		
	jr $ra
