

DATA SEGMENT PARA 'DATA'
    
    ;VARIABLES   
    CHOICE DW 05H
    LIST DW 100 DUP(?)
    LINK DW 100 DUP(?)  
    LISTSIZE DW 100
    INDEX DW 0
    CURSORPLACE DB 0  
    
    CR	EQU 13  ;DEVICE CONTROL 3 ?
    LF	EQU 10  ;LINE FEED OR NEW LINE
    
    
    
    ;MAIN MENU STRINGS
    MAINMENUENTRY DB "WELCOME TO MY ASSEMBLY PROJECT$"   
    MAINMENUCHOICEONE DB "ENTER 1 TO CREATE A LIST$"
    MAINMENUCHOICETWO DB "ENTER 2 TO LIST THE ELEMENTS OF THE LIST$"
    MAINMENUCHOICETHREE DB "ENTER 3 TO ADD AN ELEMENT TO THE LIST$"
    MAINMENUCHOICESELECT DB "ENTER YOUR CHOICE: $"     
              
    ;SUBMENU ONE STRINGS
    SUBMENUONEENTRY DB "WELCOME TO THE SUBMENU ONE$"
    SUBMENUONEEXP DB "HERE YOU CAN CREATE A LIST$"
    SUBMENUONEQUESTION DB "HOW MANY ELEMENTS WOULD YOU LIKE TO HAVE ON YOUR LIST$"      
        
             
    ;SUBMENU TWO STRINGS
    SUBMENUTWOENTRY DB "WELCOME TO THE SUBMENU TWO$"
    SUBMENUTWOEXP DB "HERE YOU CAN SEE THE LIST YOU HAVE CREATED$"
    SUBMENUTWOORDERED DB "ORDERED LIST: $"
    SUBMENUTWOUNORDERED DB "UNORDERED LIST: $"  
    SUBMENUTWOLINKS DB "LINKS: $"

               
    ;SUBMENU THREE STRINGS
    SUBMENUTHREEENTRY DB "WELCOME TO THE SUBMENU THREE$"
    SUBMENUTHREEEXP DB "HERE YOU CAN ADD AN ELEMENT TO THE LIST$"
   
    ;COMMON STRINGS            
    GETELEMENTQUESTION DB "ENTER THE ELEMENT: $"
    EXITSUBMENU DB "ENTER ANYTHING TO EXIT SUBMENU$" 
    UNKNOWNMSG DB "YOU TYPED AN UNKNOWN COMMAND! $"
    EXITMSG DB "ENTER Q TO EXIT$"      
    STUDENTINFO DB "ANIL KUTAY UCAN : 20011025$"  
    HATA DB "DIKKAT !!! SAYI VERMEDINIZ YENIDEN GIRIS YAPINIZ.!!! $"
    
      
DATA ENDS

STCK SEGMENT PARA STACK 'STCK'
    DW   128  DUP(0)
STCK ENDS

CODE SEGMENT PARA 'CODE'   
    ASSUME CS:CODE, DS:DATA, SS:STCK
        

START PROC FAR
    
        ; SET SEGMENT REGISTERS:   
        PUSH DS
        XOR AX,AX
        PUSH AX
        MOV AX, DATA
        MOV DS, AX
    
        ; ADD YOUR CODE HERE

MLOOP:  
        CALL MAINMENU
        MOV AX, WORD PTR CHOICE
        CMP AL, 'q' ; CHECK IF PRESSED BUTTON IS Q
        JE LEXIT
        CMP AL, 'Q' ; CHECK IF PRESSED BUTTON IS Q
        JE LEXIT
  
        JMP MLOOP  
        
LEXIT:    
          
        RETF
START ENDP  


MAINMENU PROC NEAR 
        ;CLEAR THE TERMINAL
        CALL CLEAR 
          
        ;SHOW THE MENU
        LEA DX,MAINMENUENTRY
        CALL PRINT

        LEA DX,MAINMENUCHOICEONE
        CALL PRINT

        LEA DX,MAINMENUCHOICETWO
        CALL PRINT 
        
        LEA DX,MAINMENUCHOICETHREE
        CALL PRINT  

        LEA DX,EXITMSG
        CALL PRINT 

        LEA DX,MAINMENUCHOICESELECT
        CALL PRINT     
        
        ;GET INPUT
        CALL GETN
        
        
        ; ACT ACCORDING TO THE WANTED CHOICE
        MOV AX, WORD PTR CHOICE 
        CMP AX, 1;
        JE FIRST 
        CMP AX,2 ;2 IN ASCII 
        JE SEC
        CMP AX,3 ;2 IN ASCII 
        JE THR 
        
        ;IF OTHER BUTTONS PRESSED EXIT
        JMP MEXIT
        

FIRST:  
        CALL SUBMENUONE
        JMP MEXIT
SEC:
        CALL SUBMENUTWO
        JMP MEXIT
THR:
        CALL SUBMENUTHREE

MEXIT: 
        RET   
        
MAINMENU ENDP   

SUBMENUONE PROC NEAR
        ;CLEAR THE TERMINAL
        CALL CLEAR    
        
        ;SHOW THE MENU
        LEA DX,SUBMENUONEENTRY
        CALL PRINT

        LEA DX,SUBMENUONEEXP
        CALL PRINT 
        
        LEA DX,SUBMENUONEQUESTION
        CALL PRINT   
        
        LEA DX,EXITMSG
        CALL PRINT 
        
        CALL GETN 
        CALL CLEAR  
        
        MOV CX,WORD PTR CHOICE      ;GET THE INPUT TO CX
        CMP CL,'q'
        JE OEXIT
        CMP CL,'Q'
        JE OEXIT
        CMP CX,0H                   ;COMPARE CX WITH 0. IF THE GIVEN NUMBER IS BELOW ONE EXIT
        JLE OEXIT

        
GETE:   
        LEA DX,GETELEMENTQUESTION
        CALL PRINT
        
        CALL GETN
        CALL ADDELEMENT  
        CALL CLEAR

        LOOP GETE

OEXIT: 
       
        RET
SUBMENUONE ENDP 

SUBMENUTWO PROC NEAR

                CALL CLEAR                      ;CLEAR THE TERMINAL 
                
                LEA DX,SUBMENUTWOENTRY
                CALL PRINT                      ;PRINT THE SUBMENU ENTRY
                
                LEA DX,SUBMENUTWOEXP
                CALL PRINT                      ;PRINT THE SUBMENU EXPLANATION    

                
                MOV CX, WORD PTR INDEX          ;CX WILL BE USED TO FIND THE SMALLEST ELEMENT IN THE LIST
                SHR CX,1                        ;LIST IS WORD TYPE, SO WE NEED TO DIVIDE CX BY 2 
                CMP CX,0H                       ;THUS WE NEED TO LOOP N-1 TIMES. IF N EQUALS 0 EXIT BECAUSE THERE IS NO ELEMENT TO SHOW
                JE EXIT 

                ;FIND THE SMALLEST VALUE: 
                XOR AX,AX                       ;AX -> SMALLEST ELEMENT TO COMPARE
                XOR BX,BX                       ;BX -> INDEX OF THE SMALLEST ELEMENT
                XOR DI,DI                       ;DI -> INDEX OF THE CURRENT ELEMENT
                
                DEC CX                          ;WE NEED TO LOOP N-1 TIME THUS WE JUST DECREASED THE VALUE BY ONE
                CMP CX,0H                       ;IF N-1 = 0, THEN THERE IS NO NEED TO COMPARE. THERE IS ONLY ONE ELEMENT
                JE CMPEXIT

                MOV AX, WORD PTR LIST[BX]       ;MOVE THE FIRST ELEMENT OF THE LIST TO AX. ASSUME THE FIRST ELEMENT IS THE SMALLEST  
 
                 
FINDSMALLEST:   
                ADD DI,2                        ;BECAUSE THE LIST IS WORD, WE NEED TO INCREASE DI BY 2
                CMP AX, WORD PTR LIST[DI]       ;COMPARE MIN ELEMENT WITH CURRENT LIST ELEMENT 
                JLE SMALLER                     ;IF CURRENT ELEMENT IS SMALLER CHANGE AX AND BX, ELSE DO NOTHING             

                MOV AX, WORD PTR LIST[DI]       ;CHANGE AX TO THE MIN ELEMENT'S VALUE
                MOV BX, DI                      ;CHANGE BX TO THE MIN ELEMENT'S INDEX
                
SMALLER:        
                LOOP FINDSMALLEST

CMPEXIT:                
                ;PRINT THE LIST : 1. ORDERED, 2.UNORDERED, 3.LINKS

                LEA DX,SUBMENUTWOORDERED
                CALL PRINT                      ;PRINT ORDERED LIST
                MOV CX,WORD PTR INDEX           ;PRINT ALL ELEMENTS, THE LOOP WILL BE FOR N TIMES
                SHR CX,1                        ;LIST IS WORD TYPE, SO WE NEED TO DIVIDE CX BY 2 

PRINTORDERED:   
                MOV AX, WORD PTR LIST[BX]       ;MOVE THE WANTED ELEMENT TO AX TO PRINT
                CALL PUTN                       ;PRINT THE WANTED ELEMENT

                MOV BX, WORD PTR LINK[BX]       ;MOVE TO THE NEXT ELEMENT BY LOOKING AT THE LINK   
                LOOP PRINTORDERED 
                
                CALL INCROW                          ;GET TO THE NEW ROW

                ;//////////////////////////////////////////////////////////////////////////////////////////////

                LEA DX,SUBMENUTWOUNORDERED
                CALL PRINT                      ;PRINT UNORDERED LIST
                MOV CX, WORD PTR INDEX          ;PRINT ALL ELEMENTS OF THE LIST, THE LOOP WILL BE FOR N TIMES
                SHR CX,1                        ;LIST IS WORD TYPE, SO WE NEED TO DIVIDE CX BY 2 
                XOR BX,BX                       ;BX -> CURRENT ELEMENT OF THE LIST. STARTS AT 0

PRINTUNORDERED:

                MOV AX, WORD PTR LIST[BX]       ;MOV THE CURRENT ELEMENT TO AX TO PRINT
                CALL PUTN

                ADD BX, 2                       ;BECAUSE THE LIST IS WORD DEFINED, WE NEED TO INCREASE BX BY 2
                LOOP PRINTUNORDERED

                CALL INCROW                     ;GET TO THE NEW ROW

                ;///////////////////////////////////////////////////////////////////////////////////////////////

                LEA DX,SUBMENUTWOLINKS
                CALL PRINT                      ;PRINT LINKS
                MOV CX, WORD PTR INDEX          ;PRINT ALL ELEMENTS OF THE LINKS, THE LOOP WILL BE FOR N TIMES
                SHR CX,1                        ;LIST IS WORD TYPE, SO WE NEED TO DIVIDE CX BY 2 
                XOR BX,BX                       ;BX -> CURRENT ELEMENT OF THE LINKS. STARTS AT 0

PRINTLINKS:

                MOV AX, WORD PTR LINK[BX]       ;MOV THE CURRENT ELEMENT TO AX TO PRINT
                CMP AX,0H
                JLE TNEGATIVE
                SHR AX,1                        ;DIVIDE AX BY 2, BECAUSE THE LINKS ARE IN WORDS FORMAT
TNEGATIVE:
                CALL PUTN

                ADD BX, 2                       ;BECAUSE THE LIST IS WORD DEFINED, WE NEED TO INCREASE BX BY 2
                LOOP PRINTLINKS


 
EXIT: 
        CALL INCROW                             ;GET TO THE NEW ROW
        LEA DX,EXITSUBMENU
        CALL PRINT 
        CALL GETN
        
        RET
        
SUBMENUTWO ENDP

SUBMENUTHREE PROC NEAR
        ;CLEAR THE TERMINAL
        CALL CLEAR   
        
        ;SHOW THE MENU
        LEA DX,SUBMENUTHREEENTRY
        CALL PRINT 
        
        LEA DX,SUBMENUTHREEEXP
        CALL PRINT 

        LEA DX,  GETELEMENTQUESTION
        CALL PRINT 
        
        CALL GETN    
        CALL ADDELEMENT     
        
        RET 
SUBMENUTHREE ENDP 




;MY FUNCTIONS

;USED TO PRINT STRING ENDING WITH $ THE OFFSET OF THE TEXT SHOULD BE IN DX
PRINT   PROC NEAR  
        PUSH AX

        MOV AH, 09H
        INT 21H  
        CALL INCROW

        POP AX
        RET
PRINT   ENDP    


INCROW  PROC NEAR 
        ;STORE REGISTERS IN STACK TO PRESERVE
        PUSH AX
        PUSH BX
        PUSH DX

        ;INCROW FUNCTION IS USED TO SHIFT THE CURSOR ONE ROW BELOW
        INC BYTE PTR CURSORPLACE
        MOV DH, BYTE PTR CURSORPLACE
        MOV DL, 0
        MOV BH, 0  
        
        MOV AH, 02H
        INT 10H

        ;GET REGISTERS BACK TO THEIR ORIGINAL FORM
        POP DX
        POP BX
        POP AX

        RET
INCROW  ENDP 

RESETROW    PROC NEAR 
        ;STORE REGISTERS IN STACK TO PRESERVE 
        PUSH AX
        PUSH BX
        PUSH DX

        ;RESETROW IS USED TO SET THE CURSOR TO THE STARTING POSITION
        MOV BYTE PTR CURSORPLACE, 0
        MOV DH, 0
        MOV DL, 0
        MOV BH, 0  
        
        MOV AH, 02H
        INT 10H 

        ;GET REGISTERS BACK TO THEIR ORIGINAL FORM
        POP DX
        POP BX
        POP AX 
        
        RET
RESETROW ENDP

CLEAR   PROC NEAR
        
        ;STORE REGISTERS IN STACK TO PRESERVE 
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
         
        ;CLEAR FUNCTION IS USED TO CLEAR THE SCREEN. IF YOU MAKE THE SCREEN BIGGER THIS WON'T WORK

        MOV CX, 0000H    ; EKRANIN SOL ÜST KÖSESI SATIR/SÜTUN ADRESI
        MOV DX, 184FH    ; EKRANIN SAG ALT KÖSESI SATIR/SÜTUN ADRESI
        MOV BH, 07H      ; ATTRIBUTE BYTE
        MOV AX, 0600H    ; AH = 06H PENCEREYI YUKARI KAYDIR
        INT 10H          ; 10H NUMARALI KESMEYI ÇAGIR   
        
        CALL RESETROW
        
        ;FOR MY ASSEMBLY PROJECT CAN BE DISCARDED 
        LEA DX,STUDENTINFO
        CALL PRINT  
        CALL INCROW

        ;GET REGISTERS BACK TO THEIR ORIGINAL FORM
        POP DX
        POP CX
        POP BX
        POP AX

        RET  
CLEAR   ENDP   


ADDELEMENT PROC NEAR 

        ;STORE REGISTERS IN STACK TO PRESERVE 
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DI
        PUSH SI

        ; ADD ELEMENT IN AX TO LIST[BX]

        MOV BX, WORD PTR INDEX          ;ASSIGN INDEX TO BX    
        MOV AX, WORD PTR CHOICE         ;ASSIGN THE NEW NUMBER TO AX 
        MOV WORD PTR LIST[BX], AX       ;ADD THE NUMBER TO THE LIST 
        ADD WORD PTR INDEX, 2           ;THE LIST IS WORD SO WE NEED TO INCREASE INDEX BY TWO
        
        ;THIS IS TO ADJUST THE LINKS

        
        XOR SI,SI                       ; TO REACH LIST ELEMENTS

        ;IF THERE IS ONLY ONE NUMBER IN THE LIST            
        MOV AX, WORD PTR INDEX
        CMP AX, 0002H
        JE AFIRST    
        

        ;ELSE THERE IS MORE THAN ONE ELEMENT, SO WE WILL LOOP THROUGH WHOLE LIST   
        
        XOR AX,AX                       ;AX -> COMPARED VALUE 
        XOR BX,BX                       ;BX -> LOWEST NUMBER'S INDEX; ASSUME THE FIRST ELEMENT IS THE SMALLEST
        XOR DI,DI                       ;DI -> GREATEST NUMBER BEFORE THE NEW NUMBER'S INDEX
        XOR CX,CX                       ;CX -> USED FOR FOR LOOP -> WE WILL LOOP N-1 TIME
        
        MOV DI, WORD PTR LISTSIZE       ;ASSIGN DI TO THE LAST PLACE IN LIST 
        SUB DI,2
        MOV WORD PTR LIST[DI],8000H     ;ASSING LAST ELEMENT OF THE LIST TO THE SMALLEST SIGNED NUMBER     

                

        
        ;DETERMINE LOOP TIME = N-1 TIME
        MOV CX, WORD PTR INDEX 
        SHR CX,1                        ;DIVIDE BY TWO BECAUSE THE LIST IS WORD TYPED  
        DEC CX                          ;MAKE N, N-1
        
        
        ;TRY TO FIND THE GREATEST VALUE BEFORE THE CHOICE  
        
AFIND:   
        MOV AX, WORD PTR LIST[SI]       ;GET THE FIRST ELEMENT OF THE LIST TO AX
        CMP AX, WORD PTR CHOICE         ;COMPARE IT WITH THE NEW GIVEN NUMBER(CHOICE)
        JGE ASMALLER                     ;IF THE ELEMENT FROM LIST IS BIGGER DO NOTHING
        
        CMP AX, WORD PTR LIST[DI]       ;COMPARE THE LIST ELEMENTS AND FIND OUT WHICH IS CLOSER TO THE GIVEN NUMBER
        JLE ASMALLER                     ;IF AX GREATER THAN LIST[DI], CHANGE DI
        MOV DI, SI                      ;DI NOW STORES THE INDEX OF AX          
        
                                            
ASMALLER: 
        CMP AX, WORD PTR LIST[BX]       ;COMPARE CURRENT LIST ELEMENT WITH THE SMALLEST THOUGHT ONE                  
        JGE ABIGGER                      ;IF AX IS SMALLER CHANGE BX TO AX'S INDEX        
        MOV BX, SI

                                                    
ABIGGER:                                        
        ADD SI,2                        ;SET SI TO THE NEXT ELEMENT (WORD TYPE)
        LOOP AFIND                       ;THEN LOOP

        MOV AX, WORD PTR LIST[BX]       ;GET THE SMALLEST VALUE OF THE LIST TO AX REGISTER 
        CMP AX, WORD PTR CHOICE         ;COMPARE NEW ELEMENT WITH THE SMALLEST ELEMENT
        JGE ASMALLEST                    ;IF THE NEW ELEMENT IS SMALLER, THEN ONLY THE LINK OF THE NEW ELEMENT WILL BE CHANGED     
    
        ;ELSE THERE ARE 2 LINKS TO CHANGE:

        MOV AX, WORD PTR LINK[DI]       ;GET THE LINK OF THE MAX VALUE BEFORE THE NEW ADDED ELEMENT TO AX

        MOV SI, WORD PTR INDEX          ;SI NOW STORES THE INDEX OF THE NEW ADDED ELEMENT
        SUB SI,2

        MOV WORD PTR LINK[DI], SI       ;CHANGE THE LINK OF THE MAX VALUE BEFORE THE NEW ADDED ELEMENT TO THE NEW ADDED ONE'S INDEX
        MOV WORD PTR LINK[SI], AX       ;CHANGE THE NEW ADDED ONE'S LINK TO THE ONE'S BEFORE THIS ONE

        JMP AEXIT                        ;EXIT
        
        

ASMALLEST: 
        ;CHANGE LINK OF THE NEW ADDED VALUE    

        MOV SI, WORD PTR INDEX          ;GET THE INDEX OF THE NEW ADDED VALUE
        SUB SI,2                    

        MOV WORD PTR LINK[SI], BX       ;CHANGE THE NEW ADDED ONE'S LINK TO THE PREVIOUS SMALLEST ONE 
        JMP AEXIT
        
        
        
AFIRST:
        ;THERE IS ONLY ONE ELEMENT IN THE LIST. THUS IT'S LINK'S VALUE WILL BE -1
        MOV WORD PTR LINK[SI], -1

        
        
AEXIT:
            
        ;GET REGISTERS BACK TO THEIR ORIGINAL FORM
        POP SI
        POP DI
        POP CX
        POP BX
        POP AX 

        RET
ADDELEMENT ENDP  

;FUNCTIONS FROM THE BOOK

GETC	PROC NEAR
        ;------------------------------------------------------------------------
        ; KLAVYEDEN BASILAN KARAKTERI AL YAZMACINA ALIR VE EKRANDA GÖSTERIR. 
        ; ISLEM SONUCUNDA SADECE AL ETKILENIR. 
        ;------------------------------------------------------------------------
        MOV AH, 1H
        INT 21H
        RET 
GETC	ENDP 

PUTC	PROC NEAR
        ;------------------------------------------------------------------------
        ; AL YAZMACINDAKI DEGERI EKRANDA GÖSTERIR. DL VE AH DEGISIYOR. AX VE DX 
        ; YAZMAÇLARININ DEGERLERI KORUMAK IÇIN PUSH/POP YAPILIR. 
        ;------------------------------------------------------------------------
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET 
PUTC 	ENDP 

GETN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; KLAVYEDEN BASILAN SAYIYI OKUR, SONUCU AX YAZMACI ÜZERINDEN DONDURUR. 
        ; DX: SAYININ ISARETLI OLUP/OLMADIGINI BELIRLER. 1 (+), -1 (-) DEMEK 
        ; BL: HANE BILGISINI TUTAR 
        ; CX: OKUNAN SAYININ ISLENMESI SIRASINDAKI ARA DEGERI TUTAR. 
        ; AL: KLAVYEDEN OKUNAN KARAKTERI TUTAR (ASCII)
        ; AX ZATEN DÖNÜS DEGERI OLARAK DEGISMEK DURUMUNDADIR. ANCAK DIGER 
        ; YAZMAÇLARIN ÖNCEKI DEGERLERI KORUNMALIDIR. 
        ;------------------------------------------------------------------------
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1	                        ; SAYININ SIMDILIK + OLDUGUNU VARSAYALIM 
        XOR BX, BX 	                        ; OKUMA YAPMADI HANE 0 OLUR. 
        XOR CX,CX	                        ; ARA TOPLAM DEGERI DE 0’DIR. 
NEW:
        CALL GETC	                        ; KLAVYEDEN ILK DEGERI AL’YE OKU. 
        CMP AL,CR 
        JE FIN_READ	                        ; ENTER TUSUNA BASILMIS ISE OKUMA BITER
        CMP AL, 'q'                         ; AL q ISE ÇIK
        JE  FIN_GETN
        CMP AL, 'Q'                         ; AL Q ISE ÇIK
        JE  FIN_GETN
        CMP  AL, '-'	                        ; AL ,'-' MI GELDI ? 
        JNE  CTRL_NUM	                        ; GELEN 0-9 ARASINDA BIR SAYI MI?
        
NEGATIVE:
        MOV DX, -1	                        ; - BASILDI ISE SAYI NEGATIF, DX=-1 OLUR
        JMP NEW		                        ; YENI HANEYI AL
CTRL_NUM:
        CMP AL, '0'	                        ; SAYININ 0-9 ARASINDA OLDUGUNU KONTROL ET.
        JB ERROR 
        CMP AL, '9'
        JA ERROR		                    ; DEGIL ISE HATA MESAJI VERILECEK
        SUB AL,'0'	                        ; RAKAM ALINDI, HANEYI TOPLAMA DÂHIL ET 
        MOV BL, AL	                        ; BL’YE OKUNAN HANEYI KOY 
        MOV AX, 10 	                        ; HANEYI EKLERKEN *10 YAPILACAK 
        PUSH DX		                        ; MUL KOMUTU DX’I BOZAR ISARET IÇIN SAKLANMALI
        MUL CX		                        ; DX:AX = AX * CX
        POP DX		                        ; ISARETI GERI AL 
        MOV CX, AX	                        ; CX DEKI ARA DEGER *10 YAPILDI 
        ADD CX, BX 	                        ; OKUNAN HANEYI ARA DEGERE EKLE 
        JMP NEW 		                ; KLAVYEDEN YENI BASILAN DEGERI AL 
ERROR:
        LEA DX,HATA
        CALL PRINT                              ; HATA MESAJINI GÖSTER 
        JMP GETN_START                          ; O ANA KADAR OKUNANLARI UNUT YENIDEN SAYI ALMAYA BASLA 
FIN_READ:
        MOV AX, CX	                        ; SONUÇ AX ÜZERINDEN DÖNECEK 
        CMP DX, 1	                        ; ISARETE GÖRE SAYIYI AYARLAMAK LAZIM 
        JE FIN_GETN
        NEG AX		                        ; AX = -AX

FIN_GETN:
        MOV WORD PTR CHOICE,AX              ;SAVE THE RESULT IN CHOICE VARIABLE
        POP DX
        POP CX
        POP BX
        RET 
GETN 	ENDP 

PUTN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX DE BULUNAN SAYIYI ONLUK TABANDA HANE HANE YAZDIRIR. 
        ; CX: HANELERI 10’A BÖLEREK BULACAGIZ, CX=10 OLACAK
        ; DX: 32 BÖLMEDE ISLEME DÂHIL OLACAK. SONCU ETKILEMESIN DIYE 0 OLMALI 
        ;------------------------------------------------------------------------
        PUSH CX
        PUSH DX 	
        XOR DX,	DX 	                        ; DX 32 BIT BÖLMEDE SONCU ETKILEMESIN DIYE 0 OLMALI 
        PUSH DX		                        ; HANELERI ASCII KARAKTER OLARAK YIGINDA SAKLAYACAGIZ.
                                                ; KAÇ HANEYI ALACAGIMIZI BILMEDIGIMIZ IÇIN YIGINA 0 
                                                ; DEGERI KOYUP ONU ALANA KADAR DEVAM EDELIM.
        MOV CX, 10	                        ; CX = 10
        CMP AX, 0
        JGE CALC_DIGITS	
        NEG AX 		                        ; SAYI NEGATIF ISE AX POZITIF YAPILIR. 
        PUSH AX		                        ; AX SAKLA 
        MOV AL, '-'	                        ; ISARETI EKRANA YAZDIR. 
        CALL PUTC
        POP AX		                        ; AX’I GERI AL 
        
CALC_DIGITS:
        DIV CX  		                ; DX:AX = AX/CX  AX = BÖLÜM DX = KALAN 
        ADD DX, '0'	                        ; KALAN DEGERINI ASCII OLARAK BUL 
        PUSH DX		                        ; YIGINA SAKLA 
        XOR DX,DX	                        ; DX = 0
        CMP AX, 0	                        ; BÖLEN 0 KALDI ISE SAYININ ISLENMESI BITTI DEMEK
        JNE CALC_DIGITS	                        ; ISLEMI TEKRARLA 
        
DISP_LOOP:
                                                ; YAZILACAK TÜM HANELER YIGINDA. EN ANLAMLI HANE ÜSTTE 
                                                ; EN AZ ANLAMLI HANE EN ALTA VE ONU ALTINDA DA 
                                                ; SONA VARDIGIMIZI ANLAMAK IÇIN KONAN 0 DEGERI VAR. 
        POP AX		                        ; SIRAYLA DEGERLERI YIGINDAN ALALIM
        CMP AX, 0 	                        ; AX=0 OLURSA SONA GELDIK DEMEK 
        JE END_DISP_LOOP 
        CALL PUTC 	                        ; AL DEKI ASCII DEGERI YAZ
        JMP DISP_LOOP                           ; ISLEME DEVAM

        
END_DISP_LOOP:
        MOV AL, 32
        CALL PUTC
        POP DX 
        POP CX
        RET
PUTN 	ENDP 

PUT_STR	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX DE ADRESI VERILEN SONUNDA 0 OLAN DIZGEYI KARAKTER KARAKTER YAZDIRIR.
        ; BX DIZGEYE INDIS OLARAK KULLANILIR. ÖNCEKI DEGERI SAKLANMALIDIR. 
        ;------------------------------------------------------------------------
	PUSH BX 
        MOV BX,	AX			        ; ADRESI BX’E AL 
        MOV AL, BYTE PTR [BX]	                ; AL’DE ILK KARAKTER VAR 
PUT_LOOP:   
        CMP AL,0		
        JE  PUT_FIN 			        ; 0 GELDI ISE DIZGE SONA ERDI DEMEK
        CALL PUTC 			        ; AL’DEKI KARAKTERI EKRANA YAZAR
        INC BX 				        ; BIR SONRAKI KARAKTERE GEÇ
        MOV AL, BYTE PTR [BX]
        JMP PUT_LOOP			        ; YAZDIRMAYA DEVAM 
PUT_FIN:
	POP BX
	RET 
PUT_STR	ENDP
        

        

CODE ENDS
    END START ; SET ENTRY POINT AND STOP THE ASSEMBLER.
