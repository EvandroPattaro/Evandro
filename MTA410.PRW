# include "rwmake.ch"
# include "ap5mail.ch"
/*/
_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+--------------------+-------------------------+----------------+¦¦
¦¦¦   GMPR  ¦ Função: MTA410     ¦ Autor: Evandro Pattaro  ¦ Data: 04/04/12 ¦¦¦
¦¦+---------+--------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦ PE Pedido de Venda				  	    ¦¦¦
¦¦+---------+---------------------------------------------------------------+¦¦
¦¦¦  USO    ¦ Alerta de alteração de PV		   		            ¦¦¦
¦¦+---------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 
  

User Function MTA410()

Local _lRetPE:= .T.

ELSEIF SM0->M0_CODIGO == '08'
	_lRetPE:= MTA410_08()
	IF ALTERA
		_lRetPE:= MTA410_09()
	ENDIF		 
ENDIF  
	

RETURN(_lRetPE)

/*/
_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+--------------------+-------------------------+----------------+¦¦
¦¦¦   GMPR  ¦ Função: MTA410_09  ¦ Autor: Evandro Pattaro  ¦ Data: 28/08/12 ¦¦¦
¦¦+---------+--------------------+-------------------------+----------------+¦¦
¦¦¦  USO    ¦ 										        ¦¦¦
¦¦+---------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/ 

Static Function MTA410_09()
  
Local _cCpoSX3		:=""
Local _aAltera 		:={}
Local _nPosgrid     	:=0
Local _nQtitem 		:=0
Local i             	:=0
Local _nNumAtual 	:=0
Local _cflag		:=""    



	DBSELECTAREA("SC6")
	SC6->(DBSETORDER(1))

	SC6->(DBGOTOP())
	SC6->(DBSEEK(XFILIAL("SC5")+M->C5_NUM),.T.)
	
	DO WHILE  SC6->(!Eof()) .AND. ALLTRIM(SC6->C6_NUM) == M->C5_NUM    
	
		_nQtitem += 1
	
		DBSELECTAREA("SX3")
		SX3->(DBSETORDER(1))
		SX3->(DBGOTOP())
		MsSeek("SC6",.T.)
	

		DO WHILE  SX3->(!Eof())  .AND. ALLTRIM(SX3->X3_ARQUIVO) == "SC6"		
			
			IF SX3->X3_CONTEXT <> "V" 
			
				_cCpoSX3:= ALLTRIM(SX3->X3_CAMPO) 
					 
				_nPosgrid:=0
				_nPosgrid:= aScan(aHeader,{|x| AllTrim(x[2])==_cCpoSX3})  
				
				IF _nPosgrid == NIL .OR. _nPosgrid == 0
					SX3->(DBSKIP())
					LOOP
				ENDIF	
				
				IF SC6->&_cCpoSX3 <> acols[VAL(SC6->C6_ITEM)][_nPosgrid]
				          
							  
					IF SX3->X3_TIPO == "C"
						AADD(_aAltera,{acols[VAL(SC6->C6_ITEM)][2],SX3->X3_DESCRIC,SC6->&_cCpoSX3,acols[VAL(SC6->C6_ITEM)][_nPosgrid]})
					Elseif SX3->X3_TIPO == "N"	  
						AADD(_aAltera,{acols[VAL(SC6->C6_ITEM)][2],SX3->X3_DESCRIC,STR(SC6->&_cCpoSX3),STR(acols[VAL(SC6->C6_ITEM)][_nPosgrid])})	  
					Elseif SX3->X3_TIPO == "D"	  
						AADD(_aAltera,{acols[VAL(SC6->C6_ITEM)][2],SX3->X3_DESCRIC,DTOC(SC6->&_cCpoSX3),DTOC(acols[VAL(SC6->C6_ITEM)][_nPosgrid])})
					Elseif SX3->X3_TIPO == "M"	  
						AADD(_aAltera,{acols[VAL(SC6->C6_ITEM)][2],SX3->X3_DESCRIC,MEMOREAD(SC6->&_cCpoSX3),MEMOREAD(acols[VAL(SC6->C6_ITEM)][_nPosgrid])})
					Endif
				   
	            		ENDIF
	            
	            		_cCpoSX3:=""
	       		ENDIF
	       	
			SX3->(DBSKIP())
		
		ENDDO
		SC6->(DBSKIP())	
	ENDDO 
	
	
		
	
	IF _nQtitem < LEN(aCols) 
		_cFlag := "D"   
	ELSEIF _nQtitem > LEN(aCols) 
		_cFlag := "A"   
	ENDIF

	
	MsgRun(PadC("Aguarde. Notificando Alteração!",100),,{|| CursorWait(),MTA410_09MAIL(_aAltera,_cFlag),CursorArrow()})


Return .T.

//************************************************************************************    
//ENVIA NOTIFICAÇÃO DA ALTERAÇÃO
//************************************************************************************    


Static Function MTA410_09MAIL(_aAltera,_cFlag)

Local _cBody     :="" 
Local _cItens	 :=""
Local _cSerMail	 := alltrim(GetMV("MV_RELSERV"))
Local _cConta  	 := alltrim(GetMV("MV_RELACNT"))
Local _cSenha	 := alltrim(GetMV("MV_RELPSW"))
Local _nTimeOut  := GetMv("MV_RELTIME")
Local _cDest	 := "execucao@alcoolferreira.com.br;claudia.cordeiro@alcoolferreira.com.br;janaina.aparecida@alcoolferreira.com.br;evandro.pattaro@grupompr.com.br"
Local i

Local _lEnviado	 := .F.
Local _lConectou := .F.
Local _cMailError:= ""
Local _cCor:= "White"
Local _cTitulo   := OemtoAnsi("(AF) - Alerta de Alteração no Pedido de Venda")

Local _cCliente	 := M->C5_CLIENTE+" -- "+M->C5_NOMCLI
Local _cUser	 := U_FRID(3)
Local _cPedido	 := M->C5_NUM


	_cBody += "<p align=left><b><font face=Verdana size=1 color=#FF6600>"  
	_cBody += "PEDIDO: "  
	_cBody += "<font face=Verdana size=1 color=#6E6E6E>"
	_cBody += + _cPedido
	
	_cBody += "<p align=left><b><font face=Verdana size=1 color=#FF6600>"  
	_cBody += "CLIENTE: "  
	_cBody += "<font face=Verdana size=1 color=#6E6E6E>"
	_cBody += + _cCliente
	
	_cBody += "<p align=left><b><font face=Verdana size=1 color=#FF6600>"  
	_cBody += "USUÁRIO: "  
	_cBody += "<font face=Verdana size=1 color=#6E6E6E>"
	_cBody += + _cUser
	
	IF _cFlag == "A" 		
		_cBody += "<p align=left><b><font face=Verdana size=1 color=#FF6600>"  
		_cBody += "Item adicionado ao pedido! "  	
	ELSEIF _cFlag == "D"		  		
		_cBody += "<p align=left><b><font face=Verdana size=1 color=#FF6600>"  
		_cBody += "Item removido do pedido!"  	
	ENDIF
	For i:=1 to Len(_aAltera)
		    		
			_cItens += "<tr>"
			_cItens += " <td align='center' width='18%' bgcolor='#FFA366'><font size='1' face='Arial'>" + ALLTRIM(_aAltera[i][1]) + "</td>"
			_cItens += " <td align='center' width='18%' bgcolor='#FFA366'><font size='1' face='Arial'>" + ALLTRIM(_aAltera[i][2]) + "</td>"
			_cItens += " <td align='center' width='18%' bgcolor='#FFA366'><font size='1' face='Arial'>" + ALLTRIM(_aAltera[i][3]) + "</td>"
			_cItens += " <td align='center' width='18%' bgcolor='#FFA366'><font size='1' face='Arial'>" + ALLTRIM(_aAltera[i][4]) + "</td>"

			_cItens += "</tr>"
			      
	Next i 
	
	
	_cBody += "<table border='0' align='center' cellpadding='1' cellspacing='1' bgColor=#ffffff bordercolor='#000000' width='100%'> "
	_cBody += " <tr>"
	_cBody += "   <td align='center' width='12%' bgcolor='#6E6E6E'> "
	_cBody += "   <font size='1' color='white' face='Arial'><b>PRODUTO</b></font></td>"
	
	_cBody += "   <td align='center' width='12%' bgcolor='#6E6E6E'> "
	_cBody += "   <font size='1' color='white' face='Arial'><b>DESCRIÇÃO</b></font></td>" 
	
	_cBody += "   <td align='center' width='12%' bgcolor='#6E6E6E'>"
	_cBody += "   <font size='1' color='white' face='Arial'><b>ANTES</b></font></td>"  
	
	_cBody += "   <td align='center' width='12%' bgcolor='#6E6E6E'>"
	_cBody += "   <font size='1' color='white' face='Arial'><b>DEPOIS</b></font></td>"
	_cBody += "</tr>"
	_cBody += _cItens
	_cBody += "</table> <br>"
	
	
	
	
 
	
	CONNECT SMTP SERVER _cSerMail ACCOUNT _cConta PASSWORD _cSenha TIMEOUT _nTimeOut Result _lConectou 
	IF GETMV("MV_RELAUTH") == .T.
		MailAuth(_cConta,_cSenha)	   
	ENDIF
	if !(_lConectou)
		GET MAIL ERROR _cMailError
	else 
	
		SEND MAIL FROM alltrim(_cConta) ;
		To alltrim(_cDest);
		SUBJECT	alltrim(_cTitulo) ;
		Body _cBody FORMAT TEXT RESULT _lEnviado
		
		if !(_lEnviado)
			GET MAIL ERROR _cMailError 
			alert(_cMailError)
		endif
		
		DISCONNECT SMTP SERVER
	endif 
	


Return .T.


