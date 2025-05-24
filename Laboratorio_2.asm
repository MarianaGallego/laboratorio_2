.data

	inputFile: .asciiz "C:/Users/maria/OneDrive - Universidad de Antioquia/Escritorio/Arquitectura/2025 - 1/Arquitectura_Laboratorio 2/input.txt"
	mensaje: .space 1024
	longitudMensaje: .word 0
	
	textoClaveCorta: .asciiz "Ingrese la palabra que desea utilizar como clave corta:   "
	claveCorta: .space 1023
	longitudClaveCorta: .word 0
	
	claveExtendida: .space 1024
	
	mensajeCifrado: .space 1024
	
	textoDeErrorDocumento: .asciiz "No se pudo leer el documento"

.text

	main:
	
		# Leer mensaje de inputFile
		la $a3, inputFile
		jal leerMensaje
		
		# Leer clave corta
		jal leerClaveCorta
		
		# Crear clave extendida
		jal crearClaveExtendida
		
		# Cifrar mensaje
		jal cifrarMensaje
		
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
    		move $s0, $v0
    		
    		la $t1, longitudMensaje
		sw $s0, 0($t1)
    		
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
		li $a1, 1023
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
        
        
        crearClaveExtendida:
        
        	lw $s0, longitudMensaje
        	lw $s1, longitudClaveCorta
        	
        	la $t3, claveCorta
        	la $t4, mensaje
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
        
        
        completarClaveExtendida:
        
        	sub $t7, $s0, $s1
    		
    		recorrerMensaje:
    		
    			beq $t1, $t7, terminarCompletado

    			lb $t6, 0($t4)
    			sb $t6, 0($t5)
    			addi $t4, $t4, 1
    			addi $t5, $t5, 1
    			addi $t1, $t1, 1
    			j recorrerMensaje

		terminarCompletado:
        
        jr $ra
        
        
        cifrarMensaje:
        
        	la $t0, mensaje
    		la $t1, claveExtendida
    		la $t2, mensajeCifrado
    		lw $t3, longitudMensaje
    		li $t4, 0
    		
    		cifrar:
    			beq $t4, $t3, terminarCifrado

    			lb $t5, 0($t0)
    			lb $t6, 0($t1)

    			# Convertir de ASCII a 0–25
    			li $t7, 'a'
   			sub $t5, $t5, $t7        # m = m - 'a'
    			sub $t6, $t6, $t7        # k = k - 'a'

    			add $t8, $t5, $t6        # m + k
    			li $t9, 26
    			rem $t8, $t8, $t9        # (m + k) mod 26

    			add $t8, $t8, $t7        # volver a ASCII: c + 'a'
    			sb $t8, 0($t2)           # guardar carácter cifrado en buffer

    			addi $t0, $t0, 1
    			addi $t1, $t1, 1
    			addi $t2, $t2, 1
    			addi $t4, $t4, 1
    			j cifrar

		terminarCifrado:
        
        jr $ra
        
        
        
        mostrarMensaje:
        
        	li $v0, 4
		la $a0, mensaje
		syscall
		
		lw $a0, longitudMensaje
		li $v0, 1
		syscall
		
		li $v0, 4
		la $a0, claveCorta
		syscall
		
		lw $a0, longitudClaveCorta
		li $v0, 1
		syscall
		
		li $v0, 4
		la $a0, claveExtendida
		syscall
		
		li $v0, 4
		la $a0, mensajeCifrado
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
