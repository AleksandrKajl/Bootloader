;Boot loader
;donldr.asm
;Created by Alexandr Kail
;Fasm, CP1251
		ORG		7C00H	
START:
;CS=DS
		MOV		AX,CS
		MOV		DS,AX
;нопхдекъхл ярщй		
			CLI
		MOV		SS,AX
		MOV		SP,START
			STI
;опх гюцпсгйх б DL оепедю╗ряъ мнлеп гюцпсгнвмнцн дхяйю			
		MOV		[BOOT_D],DL			
;бшаепюел бхдхнпефхл
;б AH=0
		MOV		AH,3
;80x25 16 жбермши		
	INT		10H		
		
;онксвюел мювюкн оепбнцн яейрнпю хг PARTITION TABLE.
		MOV		EBX,[7C00H+1C6H]
		MOV		[FIRST_SEC],EBX		
;бмняхл б оюйер дхяйнбнцн юдпеяю
		MOV		DWORD[LBA_ADDR],EBX			
;бшгшбюел EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI юдпея оюйерю дхяйнбнцн юдпеяю
		MOV		DL,[BOOT_D]
		MOV		AH,42H				;б AH мнлеп бшгшбючыеи тсмйжхх
	INT		13H
	
;гюцпсгхкх BOOT SECTOR(BS) он юдпеяс 7E00H

		MOV		AX,7E0H
		MOV		FS,AX
		MOV		DL,[FS:0+0DH]			;оюксвюхел вхякн яейрнпнб б йкюярепе
		MOV		[NUM_SEC_CL],DL			;янупюмъел	
;вхякн яейрнпнб пег. накюярх дюммшу
		MOV		DX,[FS:0+0EH]
		MOV		[NUM_SEC_RESA],DX			
;йнкхвеярбн яейрнпнб гюм. ндмни йнохеи FAT
		MOV		EDX,[FS:0+24H]
		MOV		[NUM_SEC_FAT],EDX
;пюяявхршбюел юдпея йнпмебнцн йюрюкнцю(йнк. яей. ндмни йнохх FATx2+йнк. яей. пег.накюярх+мюв. оепбнцн яейрнпю)
		SAL		EDX,1
		ADD		DX,[NUM_SEC_RESA]
		ADD		EDX,[FIRST_SEC]	
;онксвеммне гмювемхе янупнмъхл б оепелеммни		
		MOV		[R_DIR],EDX
;бмняхл б оюйер дхяйнбцн юдпеяю	
		MOV		DWORD[LBA_ADDR],EDX					
;бшгшбюел EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI юдпея оюйерю дхяйнбнцн юдпеяю
		MOV		DL,[BOOT_D]			;б DL мнлеп дхяйю
		MOV		AH,42H				;б AH мнлеп бшгшбючыеи тсмйжхх
	INT		13H
	
;яйюмхпсел йнпмебни йюрюкнц мю мюкхвхъ ъдпю 
		MOV		SI,0			;(мювюкн щкелемрнб йюрюкнцю)
		MOV		DI,NAME_KERN	;мюгбюмхе ъдпю(ялеыемхе ярпнйх)
		
LOOP_REC:
		MOV		CX,31		;яв╗рвхй аюир дн якедсчыеи гюохях тюр
		MOV		DL,0		;яв╗рвхй янбоюбьху яхлбнкнб
		
LOOP_A:
		LODS	BYTE[FS:SI]	;гюцпсфюел яхлбюк хг DS:SI
		CMP		AL,[DI]		;япюбмхбюел я оепбшл яхлбнкнл мюгбюмхъ ъдпю
	JE	@F					
		CMP		AL,0		;япюбмхбюел мю йнмеж гюохяеи FAT
	JE .END
		ADD		SI,CX		;сярюмюбкхбюел SI мю якедсчыхе 32 ахрю йнпм. йюрюкнцю
	JMP	LOOP_A				;б жхйке ю оюйю еярэ яюбоюдемхъ	
	
.END:
	JMP	_ERR				;ондбеьхбюел йнлоэчреп еякх ъдпн ме мюидемн
	
LOOP_B:
		LODS	BYTE[FS:SI]	;гюцпсфюел яхлбнк
		CMP		AL,[DI]		;япюбмхбюел я NAME_KERN
	JE	@F
		ADD		SI,CX		;сярюмюбкхбюел SI мю якедсыхе 32 ахрю йнпм. йюрюкнцю
	JMP	LOOP_REC

@@:
		INC		DL			;сбекхвхбюел яв╗рвхй яхлбнкнб
		CMP		DL,11		;ъдпн щрн хкх мер?
	JE	END_LOOP		
		DEC	 	CX			;слемэьюел яв╗рвхй
		INC		DI			;якедсчыхи яхлбнк мюгбюмхъ
	JMP	LOOP_B	
	
END_LOOP:	
		ADD		SI,9					;ярюпьее якнбн оепбнцн йкюярепю
		MOV		BX,WORD[FS:SI]
		SAL		EBX,16					;ядбхцюел б ярюпьсч онкнбхмс
		ADD		SI,6					;лкюдьее якнбн оепбнцн йкюярепю тюикю
		MOV		BX,WORD[FS:SI]
		ADD		SI,2					;пюглеп тюикю б аюирюу
		MOV		EAX,DWORD[FS:SI]
		MOV		[SIZE_F],EAX			;янупюмъел пюглеп тюикю
		
		XOR		DX,DX
		MOV		CX,200H					;декхл пюглеп ъдпю мю пюглеп яейрнпю
			DIV		CX		
		CMP		DX,0					;опнбепъел еярэ кх нярюрнй
	JNE	L1
@@:	
		MOV		[NUM_BTRAN],AL			;янупюмъел б оюйере дхяй. юдпеяю
;юдпея мюьецн тюикю б яейрнпюу
		SUB		EBX,2					;мювюкэмши йкюяреп т.-2 пегепбмшу йкюярепю
		XOR		EAX,EAX
		MOV		AL,[NUM_SEC_CL]			;слмнфюел мю йнк. яей. б йкюярепе
		MUL		EBX	
;ярюпьюъ онкнбхмю б EDX, лкюдьюъ б EAX	
		ADD		EAX,[R_DIR]
;бмняел б онйер дхяйнбнцн юдпеяю
		MOV		DWORD[LBA_ADDR],EAX		;!!!
;бшгшбюел EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI юдпея оюйерю дхяйнбнцн юдпеяю
		MOV		DL,[BOOT_D]			;б DL мнлеп дхяйю
		MOV		AH,42H				;б AH мнлеп бшгшбючыеи тсмйжхх
	INT		13H

;оепедю╗л сопюбкемхе ъдпс	
		JMP	7E0H:0

L1:		
		INC		AL						;сбекхвебюел еякх еярэ нярюрнй
	JMP	@b		
;бшбндел яннаыемхе еякх ъдпн ме мюидемн		
_ERR:						
		MOV		AX,0B800H
		MOV		ES,AX
		XOR		DI,DI
		MOV		SI,MSG					;юдпея ярпнйх яхлбнкнб
		MOV		AH,00000100B
		
.LOOP:
		MOV		AL,[SI]
		CMP		AL,0
	JE	.END
			STOSW	
		INC		SI
	JMP	.LOOP
			
.END:
		MOV		AH,1
		MOV		CX,2000H
	INT		10H
	
	JMP	$	
	
NAME_KERN	DB	'KERNEL  SYS',0
MSG			DB	'Kernel not found',0
	
R_DIR			DD	?		;йнпмебни йюрюкнц
FIRST_SEC		DD	?		;мювюкн оепбнцн яейрнпю мю дхяйе
NUM_SEC_CL		DB	?		;вхякн яейрнпнб б йкюярепе
NUM_SEC_RESA	DW	?		;вхякн яейрнпнб пегепбмни накюярх
NUM_SEC_FAT		DD	?		;йнкхвеярбн яейрнпнб гюм. ндмни йнохеи тюр
BOOT_D			DB	?		;мнлеп гюцпсгнвмнцн дхяйю
SIZE_F			DD	?		;пюглеп тюикю
	
PAC_D_ADDR:					;оюйер дхяйнбнцн юдпеяю
P_SIZE			DB	10H		;пюглеп оюйерю б аюирюу
				DB	0		;гюпегепбхпнбюмн = 0
NUM_BTRAN		DB	1		;вхякн оепеднбюелшу акнйнб(1-7FH)еякх FFH хяонкэгсеряъ 64 пюг. юдпеяюжхъ
				DB	0		;гюпегепбхпнбюмн = 0
ADDR_BUF_L		DW	0		;юдпея астепю оюлърх б ноепюрхбмни 
ADDR_BUF_H		DW	7E0H	;оюлърх (FFFF:FFFF)-опхгмюй кхмеимни юдпеяюжхх оюлърх 			
LBA_ADDR		DQ	0		;юаяюкчрмши мнлеп мювюкэм. акнйю	
			