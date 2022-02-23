.data
  string0: .asciiz "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
  string1: .asciiz "Enter a Character: "
  string2: .asciiz "Enter a Pattern: "
  string3: .asciiz "Morse Code: "
  string4: .asciiz "ASCII: "
  string5: .asciiz "End of Program\n"
  string6: .asciiz "[Error] no ASCII2MC!\n"
  string7: .asciiz "[Error] no MC2ASCII!\n"
  string8: .asciiz "[Error] Invalid combination!\n"

  endLine: .asciiz "\n"

  dict: .word 0x55700030, 0x95700031, 0xA5700032, 0xA9700033, 0xAA700034, 0xAAB00035, 0x6AB00036, 0x5AB00037, 0x56B00038, 0x55B00039, 0x9C000041, 0x6AC00042, 0x66C00043, 0x6B000044, 0xB0000045, 0xA6C00046, 0x5B000047, 0xAAC00048, 0xAC000049, 0x95C0004A, 0x6700004B, 0x9AC0004C, 0x5C00004D, 0x6C00004E, 0x5700004F, 0x96C00050, 0x59C00051, 0x9B000052, 0xAB000053, 0x70000054, 0xA7000055, 0xA9C00056, 0x97000057, 0x69C00058, 0x65C00059, 0x5AC0005A
  s_dsh: .byte '-'
  s_dot: .byte '.'
  s_spc: .byte ' '
  buffer: .space 20

.text
main:
  
  li $v0, 4                 # print "Select Operation Mode [0=ASCII to MC, 1=MC to ASCII]:"
  la $a0, string0  
  syscall                   # syscall print string0 

  li $v0, 5
  syscall                   # syscall Read int 

  bne $v0, $0, MC2A

A2MC:
  li $v0, 4                 # print "Enter a Letter:" 
  la $a0, string1
  syscall                   # syscall print string1

  li $t0, 1                 # Define length
  li $v0, 12                # Read character
  syscall                   # syscall Read character
  move $t0,$v0              # Transfer the char entered to the temporary value
  
  li $t2, 1                 # Define length
  li $v0, 12                # Read NULL character 
  syscall                   # syscall Read character

  la $t2, dict              # Load address of dir
  li $t3, 0                 # Initialize index
  li $t4, 36                # Initialize boundary

LoopA2MC:
  lb $t5, ($t2)             # Load value to be compared
  beq $t0, $t5, FndA2MC     # Compare values
  addi $t2, $t2, 4          # Next symbol
  addi $t3, $t3, 1          # Next index
  blt $t3, $t4, LoopA2MC    # Evaluate index condition
  j ErrorA2MC

FndA2MC:
  li $v0, 4                 # print "Morse Code:" 
  la $a0, string3
  syscall                   # syscall print string3

  lw $t3, ($t2)             # Load value to be printed
  li $t4, 0x80000000        # Load bitmask

snext:
  and $t5, $t3, $t4         # Apply bitmask
  beq $t5, $0, caseZ        # Zero Found

caseO:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, pdot         # 10 Found

caseE:
  li $v0, 4                 # Print string code
  la $a0, endLine           # Print NewLine
  syscall                   # syscall print value
  j EXIT                    # End

caseZ:
  sll $t3, $t3, 1           # Shift Left
  and $t5, $t3, $t4         # Apply bitmask  
  sll $t3, $t3, 1           # Shift Left
  beq $t5, $0, caseN        # 00 Found

pdash:
  li $v0, 11                # Print char
  lb $a0, s_dsh             # Load value to be printed
  syscall                   # Print value
  j snext

pdot:
  li $v0, 11                # Print char
  lb $a0, s_dot             # Load value to be printed
  syscall                   # Print value
  j snext

caseN:
  li $v0, 4                 # print "Error, Invalid combination!" 
  la $a0, string8
  syscall                   # syscall print string
  j EXIT

ErrorA2MC:
  li $v0 , 4                # print "Error no ASCII2MC!" 
  la $a0 , string6
  syscall                   # syscall print string6

  j EXIT
  
MC2A:
  li $v0 , 4
  la $a0 , string2        
  syscall

#--------------------------------------------------------------#
#-------------------- Write your code Here --------------------#
#--------------------------------------------------------------#

  li $v0, 8                 # Read morse code string from user
  la $a0, buffer            # load byte space into address
  li $a1, 20                # allot the byte space for string
  syscall                   # syscall Read string
  move $t0,$a0              # Transfer the char entered to the temporary value, t0 now holds the string 

  # li $v0 , 4              # Print string code, for debugging
  # la $a0 , endLine        # Print NewLine
  # syscall                 # syscall print value
  
  li $t1, 0                 # starts at index 0, t1 is i, t0 is the array, want to put value we want in t5
  lb $t2, s_dsh             # hold value of dash for comparison
  lb $t3, s_dot             # hold value of dot for comparison
  li $t8, 10                # Holds the ascii value of "\n"
  li $t7, 32                # Final shift left amount to left justify value

indexLoop:
  add $t5, $t1, $t0         # first index of $t5 is the index we want
  lb $t4, 0($t5)            # t4 holds what we want -> either dot or dash or \n
  
  # li $v0, 4               # Print string
  # add $a0, $t0, $0        # Print out inputted morse code
  # syscall                 # syscall print string

checkVal:                   #t6 holds the number we're appending
  beq $t4,$t8, finalShift   #check if $t4 == \n, j to the next branch thing if it is \n

  # li $v0, 1               # print Morse code binary value ($t6)
  # add $a0, $t6,$0  
  # syscall                 # syscall print int 

  beq $t4,$t2,addDash       # check if $t4 == dot or dash or nothing
  beq $t4,$t3,addDot        # add in 1,2,3 depending on value
  
  
  j EXIT                    # Invalid Character
  
addDot:                     # adds 2 to $t6
  addi $t6, $t6, 2
  sll $t6, $t6, 2
  addi $t1, $t1, 1          # next array is just 1 more than previous
  addi $t7,$t7,-2           # Subtract from the final shift left amount 
  j indexLoop               # repeat for next index

addDash:                    # adds 1 to $t6
  addi $t6, $t6, 1
  sll $t6, $t6, 2
  addi $t1, $t1, 1          # next array is just 1 more than previous
  addi $t7,$t7,-2           # Subtract from the final shift left amount
  j indexLoop               # repeat for next index

finalShift:
  addi $t7,$t7,-2           # Subtract from the final shift left amount
  addi $t6, $t6, 3
  sll $t6,$t6,$t7
  la $t2, dict              # Load address of dir
  li $t3, 0                 # Initialize index
  li $t4, 36                # Initialize boundary
  li $t7, 0xffffff00
  
  # li $v0, 1               # print Morse code binary value ($t6)
  # add $a0, $t6,$0  
  # syscall                 # syscall print int 

  # li $v0, 1               # print Final bitshift amount
  # add $a0, $t7,$0  
  # syscall                 # syscall print int

LoopMC2A:
  lw $t5, ($t2)             # Load value to be compared
  and $t5,$t5,$t7

  # li $v0, 1               # print Final bitshift amount
  # add $a0, $t5,$0  
  # syscall                 # syscall print int

  # li $v0, 4               # Print string code
  # la $a0, endLine         # Print NewLine
  # syscall                 # syscall print value

  # li $v0, 1               # print Final bitshift amount
  # add $a0, $t6,$0  
  # syscall                 # syscall print int

  # li $v0, 4               # Print string code
  # la $a0, endLine         # Print NewLine
  # syscall                 # syscall print value


  beq $t6, $t5, FndMC2A     # Compare values
  addi $t2, $t2, 4          # Next symbol
  addi $t3, $t3, 1          # Next index
  blt $t3, $t4, LoopMC2A    # Evaluate index condition
  j ErrorMC2A

FndMC2A:
  li $v0, 4                 # print "Ascii: " 
  la $a0, string4
  syscall                   # syscall print string4

  lw $t3, ($t2)             # Load value to be printed
  li $t4, 0x000000ff        # Load bitmask
  and $t3,$t3,$t4

  li $v0, 11                # print "Enter a Letter:" 
  move $a0, $t3
  syscall                   # syscall print string1

  li $v0, 4                 # Print string code
  la $a0, endLine           # Print NewLine
  syscall                   # syscall print value

  j EXIT

#--------------------------------------------------------------#

ErrorMC2A:
  li $v0 , 4                # print "Error no MC2ASCII!" 
  la $a0 , string7
  syscall                   # syscall print string7

  j EXIT

EXIT:		 
  li $v0, 4
  la $a0, string5
  syscall

  li $a0, 0
  li $v0, 17              #exit
  syscall
