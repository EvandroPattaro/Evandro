#Include 'Protheus.ch'
#include "RWMAKE.ch" 
#include "Topconn.ch" 



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦         ¦ Função: TRFBD ¦ Autor: Evandro Pattaro  ¦ Data: --/--/--    ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦Transferência de registros entre bancos de dados - SA1	  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦                                                             ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function TRFBD()
	Local oDlg
	Local oButton1
	Local oButton2
	Local oGet1 := SPACE(14)
	
	Local CNA
	
	U_GSA1_CNA()
	
	 IF ! U_FRID(2)$ALLTRIM(GETMV("MV_TRFBD") )

    	 ALERT("Usuário sem acesso a esta rotina!") 
    	 SA1_CNA->(DBCLOSEAREA())

     	RETURN(.F.)  
     ENDIF
	
	
	DEFINE MSDIALOG oDlg TITLE "Transferência de cadastro de Clientes (CNA - AF)"  From 000,000 TO 300, 670 PIXEL
	
	
	@ 026, 008 To 100,328 Browse "SA1_CNA" Fields aCam1  Object OBRW

	
	@ 105, 050 MSGET oGet1 SIZE 060, 010 PICTURE "@R 99.999.999/9999-99" OF oDlg PIXEL
	@ 104, 113 BUTTON oButton1 PROMPT "Pesquisar" ACTION {||U_CNASA1(oGet1)} SIZE 037, 012 OF oDlg PIXEL
	@ 104, 290 BUTTON oButton2 PROMPT "Transferir" ACTION {||U_TRANSFSA1(oGet1)}  SIZE 037, 012 OF oDlg PIXEL
	@ 107, 009 SAY oSay1 PROMPT "Digite o CNPJ :" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 017, 007 SAY CNA PROMPT "CNA" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	SA1_CNA->(DBCLOSEAREA())

RETURN()

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦         ¦ Função: GSA1_CNA ¦ Autor: Evandro Pattaro  ¦ Data: --/--/-- ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦ Gera tabela temporária					  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦                                                             ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
   


User Function GSA1_CNA()


	Local cArq1 	:= CriaTrab(NIL,.f.)  
		
	Public aCam1:= {} 
	Public aReg1:= {} 
	
	
	DBSELECTAREA("SX3")
	SX3->(DBSETORDER(1))       
	SX3->(DBGOTOP())
	MsSeek("SA1",.T.)
	
	DO WHILE SX3->(!Eof()) .AND. ALLTRIM(SX3->X3_ARQUIVO) == "SA1" 
		
		AAdd(aCam1,{SX3->X3_CAMPO,SX3->X3_TITULO,SX3->X3_PICTURE}) 

		AAdd(aReg1,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})	
	
		SX3->(DBSKIP())
	ENDDO
		
	DbCreate(cArq1,aReg1)
	Dbusearea(.T.,"DBFCDX",cArq1,"SA1_CNA",.T.,.F.)
	SA1_CNA->(dbCommitAll())  
                      
 Return()
 
 
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦         ¦ Função:QRY1      ¦ Autor: Evandro Pattaro  ¦ Data: --/--/-- ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦Gera Query busca cnpj    				          ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦                                                             ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/



User Function QRY1(_cEmp,_cCgc)
	Local _cQuery := "" 
	_cQuery := "SELECT * "
	_cQuery += "FROM "+_cEmp+" "
	_cQuery += "WHERE A1_CGC = '"+_cCgc+"' "
	
	_cQuery := ChangeQuery(_cQuery) 

Return(_cQuery)
	
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦         ¦ Função:          ¦ Autor: Evandro Pattaro  ¦ Data: --/--/-- ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦ Conecta no banco e popula a tabela 			  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦                                                             ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CNASA1(_cCgc)
	Public _nCon:= 0
	Public _cQry :=""
	Public _cEmp := "SA1020"
	Public _cCpoSx3:=""
	
	
	
dbSelectArea("SA1")
SA1->(dbsetorder(3))

IF dbSeek (xFilial("SA1") + _cCgc,.T.) 
	Alert("Cliente Já cadastrado!")
	Return()
endif
SA1->(dbclosearea("SA1"))			
_nCon:= TcLink("MSSQL/TOTVS","172.17.0.15",7890)
			
	IF _nCon<0
		Alert("Erro de conexao.")
		RETURN()
	ENDIF	
	
	
	SA1_CNA->(DBGOTOP())
	DO WHILE SA1_CNA->(!EOF())
	
		RECLOCK("SA1_CNA",.F.)
	   		SA1_CNA->(DBDELETE())
	   	SA1_CNA->(MSUNLOCK())
	   		
		SA1_CNA->(DBSKIP())
		
	ENDDO	
		

	_cQry :=U_QRY1(_cEmp,_cCgc)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), "QRY_CNA", .T., .F. )
	  
	IF SELECT("QRY_CNA") <> 0 
	
		DBSELECTAREA("SA1_CNA")
		QRY_CNA->(DBGOTOP())
	
		

		DO WHILE QRY_CNA->(!EOF())	
		
   			Reclock("SA1_CNA",.T.)
			
				FOR I:=1 TO LEN(aReg1)	
					
					_cCpoSx3 := ALLTRIM(aReg1[I][1])	
					
					FOR J:=1 TO 500				
						IF _cCpoSx3 == QRY_CNA->(FieldName(J))
							SA1_CNA->&_cCpoSx3 := IIF(aReg1[I][2]=="D",STOD(QRY_CNA->&_cCpoSx3),QRY_CNA->&_cCpoSx3)
							EXIT 	
						ENDIF
					NEXT	
						
									
				NEXT	
			
			SA1_CNA->(MSUNLOCK())
			
			QRY_CNA->(DBSKIP())
		
		ENDDO	
					
		QRY_CNA->(DBCLOSEAREA())
	
	ENDIF	
	
	TcUnlink(_nCon)
	
Return()



/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦         ¦ Função:          ¦ Autor: Evandro Pattaro  ¦ Data: --/--/-- ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦Transfere o registro					  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦                                                             ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/


user Function TRANSFSA1(_cCgc)

	Local _cCodcli := ""
	Local _cLoja := "01"
	Local _cVal := .F.
	Local _cCpoSx3:= ""
	Local aAreaAnt := GETAREA()
	Local _lSXE:=.F.
	
	TcUnlink(_nCon)
	
IF _cCgc <> ""
		
	SA1_CNA->(DBGOTOP()) 
	DO WHILE SA1_CNA->(!EOF())
	
		
		SA1->(dbsetorder(3))
		SA1->(DBGOTOP())
		IF SA1->(DbSeek(xFilial("SA1")+SUBSTR(_cCgc,1,8),.F.))
			
			
			 _cCodcli:= SA1->A1_COD  
			
			
			SA1->(dbsetorder(1))
			SA1->(DBGOTOP())
			IF SA1->(DbSeek(xFilial("SA1")+_cCodcli,.T.))
				DO WHILE SA1->(!EOF()) .AND. SA1->A1_COD == _cCodcli
					
					IF SA1->A1_LOJA > _cLoja
						_cLoja:=SA1->A1_LOJA
					ENDIF
					
					SA1->(DBSKIP())
				ENDDO	
				_cLoja :=  Soma1(_cLoja)
			ENDIF					
				
		ELSE
			_cCodcli :=GetSXENum("SA1","A1_COD")
			_lSXE:=.T.
		ENDIF
		
	
		IF MSGBOX("Código : "+_cCodcli+"| Loja : "+_cLoja+" Continua ?","Atenção","YESNO") == .T.
		
				dbSelectArea("SA1")
				RECLOCK("SA1", .T.) //Trava o registro		
				
				
				FOR I:=1 TO LEN(aReg1)
			
					_cCpoSx3 := ALLTRIM(aReg1[I][1])
					
					FOR J:=1 TO 500				
			
						IF _cCpoSx3 == ALLTRIM(SA1->(FieldName(J)))					
													
							IF ALLTRIM(_cCpoSx3) == "A1_COD"
								SA1->&_cCpoSx3 := _cCodcli
							ENDIF
							
							IF ALLTRIM(_cCpoSx3) == "A1_LOJA" 
								SA1->&_cCpoSx3 := _cLoja
							ENDIF	
							
							IF ALLTRIM(_cCpoSx3) <> "R_E_C_N_O_" .AND. ALLTRIM(_cCpoSx3) <> "A1_COD" .AND. ALLTRIM(_cCpoSx3) <> "A1_LOJA" 
								SA1->&_cCpoSx3 := SA1_CNA->&_cCpoSx3
							ENDIF	
							
							EXIT 	
			
						ENDIF
			
					NEXT
					
				NEXT
				SA1->(MsUnlock())     // Destrava o registro
				SA1->(DBCOMMITALL())
				
				IF _lSXE == .T.
					SA1->(ConfirmSX8())
				ENDIF	 
				
				MessageBox ("Gravado com sucesso."," ",0)
		ENDIF
		
		SA1_CNA->(DBSKIP())
	
	ENDDO

	
	SA1->(dbclosearea())
	SA1_CNA->(DBGOTOP())
	
else
	Alert("Digite o CNPJ do cliente!")
	return()
	
ENDIF		
		
			
	DO WHILE SA1_CNA->(!EOF())
	
		RECLOCK("SA1_CNA",.F.)
	   		SA1_CNA->(DBDELETE())
	   	SA1_CNA->(MSUNLOCK())
	   		
		SA1_CNA->(DBSKIP())
		
	ENDDO
	RESTAREA(aAreaAnt)


	
Return()