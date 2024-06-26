;Boot loader
;donldr.asm
;Created by Alexandr Kail
;Fasm, CP1251
		ORG		7C00H	
START:
;CS=DS
		MOV		AX,CS
		MOV		DS,AX
;���������� ����		
			CLI
		MOV		SS,AX
		MOV		SP,START
			STI
;��� �������� � DL ���������� ����� ������������ �����			
		MOV		[BOOT_D],DL			
;�������� ����������
;� AH=0
		MOV		AH,3
;80x25 16 �������		
	INT		10H		
		
;�������� ������ ������� ������� �� PARTITION TABLE.
		MOV		EBX,[7C00H+1C6H]
		MOV		[FIRST_SEC],EBX		
;������ � ����� ��������� ������
		MOV		DWORD[LBA_ADDR],EBX			
;�������� EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI ����� ������ ��������� ������
		MOV		DL,[BOOT_D]
		MOV		AH,42H				;� AH ����� ���������� �������
	INT		13H
	
;��������� BOOT SECTOR(BS) �� ������ 7E00H

		MOV		AX,7E0H
		MOV		FS,AX
		MOV		DL,[FS:0+0DH]			;��������� ����� �������� � ��������
		MOV		[NUM_SEC_CL],DL			;���������	
;����� �������� ���. ������� ������
		MOV		DX,[FS:0+0EH]
		MOV		[NUM_SEC_RESA],DX			
;���������� �������� ���. ����� ������ FAT
		MOV		EDX,[FS:0+24H]
		MOV		[NUM_SEC_FAT],EDX
;������������ ����� ��������� ��������(���. ���. ����� ����� FATx2+���. ���. ���.�������+���. ������� �������)
		SAL		EDX,1
		ADD		DX,[NUM_SEC_RESA]
		ADD		EDX,[FIRST_SEC]	
;���������� �������� ��������� � ����������		
		MOV		[R_DIR],EDX
;������ � ����� �������� ������	
		MOV		DWORD[LBA_ADDR],EDX					
;�������� EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI ����� ������ ��������� ������
		MOV		DL,[BOOT_D]			;� DL ����� �����
		MOV		AH,42H				;� AH ����� ���������� �������
	INT		13H
	
;��������� �������� ������� �� ������� ���� 
		MOV		SI,0			;(������ ��������� ��������)
		MOV		DI,NAME_KERN	;�������� ����(�������� ������)
		
LOOP_REC:
		MOV		CX,31		;�ר���� ���� �� ��������� ������ ���
		MOV		DL,0		;�ר���� ��������� ��������
		
LOOP_A:
		LODS	BYTE[FS:SI]	;��������� ������ �� DS:SI
		CMP		AL,[DI]		;���������� � ������ �������� �������� ����
	JE	@F					
		CMP		AL,0		;���������� �� ����� ������� FAT
	JE .END
		ADD		SI,CX		;������������� SI �� ��������� 32 ���� ����. ��������
	JMP	LOOP_A				;� ����� � ���� ���� ����������	
	
.END:
	JMP	_ERR				;����������� ��������� ���� ���� �� �������
	
LOOP_B:
		LODS	BYTE[FS:SI]	;��������� ������
		CMP		AL,[DI]		;���������� � NAME_KERN
	JE	@F
		ADD		SI,CX		;������������� SI �� �������� 32 ���� ����. ��������
	JMP	LOOP_REC

@@:
		INC		DL			;����������� �ר���� ��������
		CMP		DL,11		;���� ��� ��� ���?
	JE	END_LOOP		
		DEC	 	CX			;��������� �ר����
		INC		DI			;��������� ������ ��������
	JMP	LOOP_B	
	
END_LOOP:	
		ADD		SI,9					;������� ����� ������� ��������
		MOV		BX,WORD[FS:SI]
		SAL		EBX,16					;�������� � ������� ��������
		ADD		SI,6					;������� ����� ������� �������� �����
		MOV		BX,WORD[FS:SI]
		ADD		SI,2					;������ ����� � ������
		MOV		EAX,DWORD[FS:SI]
		MOV		[SIZE_F],EAX			;��������� ������ �����
		
		XOR		DX,DX
		MOV		CX,200H					;����� ������ ���� �� ������ �������
			DIV		CX		
		CMP		DX,0					;��������� ���� �� �������
	JNE	L1
@@:	
		MOV		[NUM_BTRAN],AL			;��������� � ������ ����. ������
;����� ������ ����� � ��������
		SUB		EBX,2					;��������� ������� �.-2 ��������� ��������
		XOR		EAX,EAX
		MOV		AL,[NUM_SEC_CL]			;�������� �� ���. ���. � ��������
		MUL		EBX	
;������� �������� � EDX, ������� � EAX	
		ADD		EAX,[R_DIR]
;������ � ����� ��������� ������
		MOV		DWORD[LBA_ADDR],EAX		;!!!
;�������� EDD 
		MOV		SI,PAC_D_ADDR		;DS:SI ����� ������ ��������� ������
		MOV		DL,[BOOT_D]			;� DL ����� �����
		MOV		AH,42H				;� AH ����� ���������� �������
	INT		13H

;�������� ���������� ����	
		JMP	7E0H:0

L1:		
		INC		AL						;����������� ���� ���� �������
	JMP	@b		
;������� ��������� ���� ���� �� �������		
_ERR:						
		MOV		AX,0B800H
		MOV		ES,AX
		XOR		DI,DI
		MOV		SI,MSG					;����� ������ ��������
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
	
R_DIR			DD	?		;�������� �������
FIRST_SEC		DD	?		;������ ������� ������� �� �����
NUM_SEC_CL		DB	?		;����� �������� � ��������
NUM_SEC_RESA	DW	?		;����� �������� ��������� �������
NUM_SEC_FAT		DD	?		;���������� �������� ���. ����� ������ ���
BOOT_D			DB	?		;����� ������������ �����
SIZE_F			DD	?		;������ �����
	
PAC_D_ADDR:					;����� ��������� ������
P_SIZE			DB	10H		;������ ������ � ������
				DB	0		;��������������� = 0
NUM_BTRAN		DB	1		;����� ������������ ������(1-7FH)���� FFH ������������ 64 ���. ���������
				DB	0		;��������������� = 0
ADDR_BUF_L		DW	0		;����� ������ ������ � ����������� 
ADDR_BUF_H		DW	7E0H	;������ (FFFF:FFFF)-������� �������� ��������� ������ 			
LBA_ADDR		DQ	0		;���������� ����� �������. �����	
			