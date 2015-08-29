#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.ch"  
#INCLUDE "AP5MAIL.ch" 
#INCLUDE "TOPCONN.ch"


/*/
___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+----------------------+-----------------+¦¦
¦¦¦   AF    ¦ Função: FALTEDT  ¦ Autor: Evandro Pattaro ¦Data: 24/10/14 ¦¦¦
¦¦+---------+------------------+----------------------------------------+¦¦
¦¦¦Descrição¦ Alterar data de validade dos lotes                        ¦¦¦
¦¦+---------+-----------------------------------------------------------+¦¦
¦¦¦  USO    ¦ SIGAEST                                                   ¦¦¦
¦¦+---------+-----------------------------------------------------------+¦¦  
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/           

User function FALTEDT()

Local _cLote:=SPACE(10)  
Local _cDataAV:=CTOD(" / / ")
Local _cDataF:=CTOD(" / / ")


U_CRIATAB()        

IF ! U_FRID(2)$ALLTRIM(GETMV("MV_DATAL")) 
             
     ALERT("Usuário sem acesso a esta rotina!")
     ZZ_->( dbCloseArea())    
     
     RETURN(.F.)  
ENDIF



@ 000,000 To 450,670 Dialog  DataR  Title " Alteração de datas de validade "

@ 014,060 Say "Numero do Lote: "               OF DataR  PIXEl                                            
@ 012,120 MSGET _cLote   SIZE 045,009 F3 "SB8L" PICTURE "@!" OF DataR  PIXEL
  
@ 012,180 Button "Confirmar" Size 50,13 Action U_PREETAB(_cLote) OF DataR PIXEL 
                 
                 
@ 150,060 Say " Nova Validade : "       OF DataR  PIXEL 
@ 150,120 MSGET _cDataAV   SIZE 045,009 OF DataR  PIXEL        
                
@ 150,180 Button "Alterar" Size 50,13 Action        {||U_ALTERDTV(_cLote,DTOS(_cDataAV)),U_PREETAB(_cLote),_cDataAV :=CTOD(" / / ")}  OF DataR PIXEL 
                
   
@ 190,060 Say " Nova Fabricação : "      OF DataR  PIXEL 
@ 190,120 MSGET _cDataF   SIZE 045,009          OF DataR  PIXEL        
                
@ 190,180 Button "Alterar" Size 50,13 Action {||U_ALTERDTF(_cLote,DTOS(_cDataF)),U_PREETAB(_cLote),_cDataF :=CTOD(" / / ")}  OF DataR PIXEL
                
                
                
@ 030,010 To 140,330 Browse "ZZ_" Fields aCam Mark "Z1_OK" Object OBRW  
                
ACTIVATE MSDIALOG DataR CENTERED 
                
ZZ_->( dbCloseArea())
                
                                                         
Return()



/*/
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦    AF   ¦ Função: CRIATAB  ¦ Autor: Evandro Pattaro      ¦ Data: 24/10/14 ¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦Descrição¦ Cria tabela temporaria                                          ¦¦¦
¦¦+---------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CRIATAB()

Local cArq := CriaTrab(NIL,.f.)  


Public aCam:= {} 
Public aReg:= {} 

//CRIANDO CAMPOS DA TABELA
AAdd(aCam,{"Z1_OK"      ,""}) 
AAdd(aCam,{"Z1_FILIAL"  ,"Filial","@!"}) 
AAdd(aCam,{"Z1_PRODUTO" ,"Codigo","@!"})
AAdd(aCam,{"Z1_DESC"    ,"Descrição","@!"})
AAdd(aCam,{"Z1_LOCAL"   ,"Local","@!"})
AAdd(aCam,{"Z1_DATAF"   ,"Data de Fabricação"})
AAdd(aCam,{"Z1_DATAV"   ,"Data de Validade"})

AAdd(aReg,{"Z1_OK"        ,"C",02,0})
AAdd(aReg,{"Z1_FILIAL"  ,"C",02,0}) 
AAdd(aReg,{"Z1_PRODUTO" ,"C",15,0})
AAdd(aReg,{"Z1_DESC"    ,"C",50,0}) 
AAdd(aReg,{"Z1_LOCAL"   ,"C",02,0})
AAdd(aReg,{"Z1_DATAF"   ,"D",08,0}) 
AAdd(aReg,{"Z1_DATAV"   ,"D",08,0})


DbCreate(cArq,aReg)
Dbusearea(.T.,"DBFCDX",cArq,"ZZ_",.T.,.F.)
ZZ_->(dbCommitAll())  


Return()


/*/
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦    AF   ¦ Função: PREETAB  ¦ Autor: Evandro Pattaro      ¦ Data: 24/10/14 ¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦Descrição¦ Pesquisa Lote e Preenche tabela temporaria                      ¦¦¦
¦¦+---------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/


User Function PREETAB(_cLote) 

Local _cQuery := "" 

Public _nValTOT:=0 
Public _nValPAR:=0

_cQuery := " SELECT B8_FILIAL,B8_PRODUTO,B1_DESC,B8_LOCAL,B8_DATA,B8_DTVALID "
_cQuery += " FROM SB8080 "
_cQuery += " INNER JOIN SB1080 ON B8_PRODUTO = B1_COD "
_cQuery += " WHERE B8_LOTECTL ='"+_cLote+"' AND B8_FILIAL='"+xFilial('SB8')+"' "  
_cQuery := ChangeQuery(_cQuery) 
TCQUERY _cQuery NEW ALIAS "SB8_"     
                                       

ZZ_->(dbGoTop())


DO WHILE ZZ_->(!EOF())

	RECLOCK("ZZ_",.F.)
 	ZZ_->(DBDELETE())
  	ZZ_->(MSUNLOCK())
                               
   	ZZ_->(DBSKIP())
                
ENDDO 


DBSELECTAREA("SB8_") 

SB8_->(dbGoTop())

Do While SB8_->(!Eof()) 
                
	Reclock("ZZ_",.T.) 
                
 	ZZ_->Z1_OK:= THISMARK()                    
  	ZZ_->Z1_FILIAL   := ALLTRIM(SB8_->B8_FILIAL)                               
   	ZZ_->Z1_PRODUTO  := ALLTRIM(SB8_->B8_PRODUTO)
    ZZ_->Z1_DESC     := ALLTRIM(SB8_->B1_DESC)
    ZZ_->Z1_LOCAL    := ALLTRIM(SB8_->B8_LOCAL)
    ZZ_->Z1_DATAF    := STOD(SB8_->B8_DATA)                    
    ZZ_->Z1_DATAV    := STOD(SB8_->B8_DTVALID) 
                
                                 
    ZZ_->(MsUnlock())
                
    SB8_->(DbSkip())               
                 
ENDDO

IF SELECT("SB8_")<>0
	SB8_->(DBCLOSEAREA())
ENDIF   


ZZ_->(dbGoTop())

_nValPAR:=_nValTOT

Return()
  
/*/
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦    AF   ¦ Função: ALTERDT  ¦ Autor: Evandro Pattaro      ¦ Data: 24/10/14 ¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦Descrição¦ Altera data de validade do lote                                 ¦¦¦
¦¦+---------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function ALTERDTV(_cLote,_cDataAV)

Local _cQuery 
Local _lSelec:=.F.
                               
                               
ZZ_->(dbGoTop())       //Altera _lSelect para .T. caso algum Z1_OK Esteja marcado
Do While ZZ_->(!Eof())      
                                     
	If ZZ_->(MARKED("Z1_OK"))                                    
 		_lSelec:=.T.
   	ENDIF   
    ZZ_->(dbSkip())

Enddo   
                
                
if empty(_cDataAV)== .T. //Valida a nova data esta vazia
	ALERT("Preencher o campo nova data! ")
	RETURN()
ENDIF

IF  _lSelec == .F.     //Valida se algum lote foi selecionado
	Alert ("Nenhum lote foi selecionado")
	RETURN()
ENDIF

IF MSGBOX("Confirma a alteração do lote '"+_cLote+"' para validade '" + DTOC(STOD(_cDataAV))+ " ?","Atenção","YESNO") == .T. 
	ZZ_->(dbGoTop())
                                                
	//Execulta a query apenas na Z1_OK que estiver MARKED
 	DO WHILE ZZ_->(!Eof())
  		If ZZ_->(MARKED("Z1_OK"))
                                                                                                              
    		_cQuery := "UPDATE SB8080 "
      		_cQuery += "SET B8_DTVALID ='"+_cDataAV+"' "
        	_cQuery += "WHERE B8_LOTECTL = '"+_cLote+"' "
         	_cQuery += "AND (B8_PRODUTO = '"+ZZ_->Z1_PRODUTO+"' AND B8_LOCAL = '"+ZZ_->Z1_LOCAL+"') "
          	_cQuery += "AND B8_FILIAL = '"+xFilial('SB8')+ "' "
                                               
           	TCSqlExec(_cQuery)//Funcão que executa UPDATE SQL.
                                                                                                                                                                                                                                          
        ENDIF
                                               
        ZZ_->(DBSKIP())                                             
    ENDDO
ELSE
                
	RETURN()           
                               
ENDIF
                
MsgInfo("Data de validade alterada com sucesso","Alterar")
                               
                               
RETURN(_cDataAV)

/*/
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦    AF   ¦ Função: ALTERDT  ¦ Autor: Evandro Pattaro      ¦ Data: 24/10/14 ¦¦¦
¦¦+---------+------------------+-----------------------------+----------------+¦¦
¦¦¦Descrição¦ Altera data de validade do lote                                 ¦¦¦
¦¦+---------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function ALTERDTF(_cLote,_cDataF)

Local _cQuery 
Local _lSelec:=.F.
                               
                               
ZZ_->(dbGoTop())       //Altera _lSelect para .T. caso algum Z1_OK Esteja marcado
Do While ZZ_->(!Eof())      
                                     
	If ZZ_->(MARKED("Z1_OK"))                                    
 		_lSelec:=.T.
   	ENDIF   
    ZZ_->(dbSkip())

Enddo   
                
                
if empty(_cDataF)== .T. //Valida a nova data esta vazia
	ALERT("Preencher o campo nova data! ")
	RETURN()
ENDIF

IF  _lSelec == .F.     //Valida se algum lote foi selecionado
	Alert ("Nenhum lote foi selecionado")
	RETURN()
ENDIF

IF MSGBOX("Confirma a alteração do lote '"+_cLote+"' para fabricação '" + DTOC(STOD(_cDataF))+ " ?","Atenção","YESNO") == .T. 
	ZZ_->(dbGoTop())
                                                
	//Execulta a query apenas na Z1_OK que estiver MARKED
 	DO WHILE ZZ_->(!Eof())
  		If ZZ_->(MARKED("Z1_OK"))
                                                                                                              
    		_cQuery := "UPDATE SB8080 "
      		_cQuery += "SET B8_DATA ='"+_cDataF+"' "
        	_cQuery += "WHERE B8_LOTECTL = '"+_cLote+"' "
         	_cQuery += "AND (B8_PRODUTO = '"+ZZ_->Z1_PRODUTO+"' AND B8_LOCAL = '"+ZZ_->Z1_LOCAL+"') "
          	_cQuery += "AND B8_FILIAL = '"+xFilial('SB8')+ "' "
                                               
           	TCSqlExec(_cQuery)//Funcão que executa UPDATE SQL.
                                                                                                                                                                                                                                          
        ENDIF
                                               
        ZZ_->(DBSKIP())                                             
    ENDDO
ELSE
                
	RETURN()           
                               
ENDIF
                
MsgInfo("Data de fabricação alterada com sucesso","Alterar")
                               
                               
RETURN(_cDataF)
