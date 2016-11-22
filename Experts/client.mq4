//+------------------------------------------------------------------+
//|                                                       client.mq4 |
//|                                                        Jam Sávio |
//|                               https://www.facebook.com/jaamsavio |
//+------------------------------------------------------------------+
#property copyright "Replicar Sinais - Created by Jam Sávio - Client"
#property link      "https://www.facebook.com/jaamsavio"
#property version   "1.00"
#include "..\Include\MqlMySql.mqh"

//--- parameters
int    DBConnection;
int    dia,mes,ano;
bool   valid=false;
int    ticket;
bool   status=true, showMessage=false; 
extern double LoteManual=0.00;
double Lote; 
string txtValid="";
int    id_anterior;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      dia=Day();
      mes=Month();
      ano=Year();
      
//--- create timer
   EventSetTimer(1); 
//---
   
   DBConnection = MySqlConnect("52.89.190.145", "jam", "311072", "forex", 3306, "", 0);
      if (DBConnection==-1)
      {
        Print("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription);
        return (1);
      }else{
        Print("Conectado com sucesso ao servidor MySQL");
      }
      
      
  //------------- 
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }

//+------------------------------------------------------------------+
//| Validação                                                        |
//+------------------------------------------------------------------+
void Validacao(){
    string Queryyy;
    int    iii,Cursorrr,Rowsss;
    
    int vDia, vMes, vAno;
    string vNome;
    
   Queryyy = "SELECT nome,dia,mes,ano FROM fx_assinaturas WHERE id='"+AccountNumber()+"'";
   Cursorrr = MySqlCursorOpen(DBConnection, Queryyy);

   if (Cursorrr >= 0)
     {
       Rowsss = MySqlCursorRows(Cursorrr);
       if(Rowsss > 0){
         for (iii=0; iii<Rowsss; iii++) 
             if (MySqlCursorFetchRow(Cursorrr))
                 {
                    vNome = MySqlGetFieldAsString(Cursorrr, 0); 
                    vDia = MySqlGetFieldAsInt(Cursorrr, 1); 
                    vMes = MySqlGetFieldAsInt(Cursorrr, 2); 
                    vAno = MySqlGetFieldAsInt(Cursorrr, 3);
                    vDia=vDia+1; 
             
                    if((vDia-dia)<=5 && (vDia-dia)>0 && vMes==mes && vAno==ano){
                       txtValid = "Favor entrar em contato para renová-la.";
                       txtValid = vNome+", faltam "+((vDia)-dia)+" dia(s) para expirar sua licença."; 
                    }
             
                    if((vDia-dia)<=0 && (vMes-mes)<=0 && (vAno-ano)<=0){
                       txtValid = "Desculpe "+vNome+", sua licença expirou.";
                       status=false;
                    }
             
                    if((vDia-dia)>=6 || vMes>=mes || vAno>=ano){
                        if(vMes>mes || vAno>ano){
                           int cal=0;
                           vMes=(vMes-mes)*30;
                           vAno=(vAno-ano)*360; 
                           cal=(vDia-dia)+vMes+vAno;
                           txtValid=vNome+", faltam "+cal+" dia(s) para expirar sua licença."; 
                         }else{
                           txtValid=vNome+", faltam "+((vDia)-dia)+" dia(s) para expirar sua licença."; 
                         }
                    }
                 MySqlCursorClose(Rowsss);  
             }else{
                   txtValid="#Assinatura - Cursor opening failed. Error: "+MySqlErrorDescription;
             }    
         }}else{ status=false; txtValid="Você não possui licença para receber estes sinais."; }
      } 

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Validacao();
   if(showMessage!=true){
      Alert(txtValid);
      showMessage=true;
   }
   
   if(status!=0){
    RecebeSinal();
    VerificaStop();
    VerificaOrdens();
   }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Seleciona dados                                                  |
//+------------------------------------------------------------------+
int RecebeSinal()
  {
//---
    string Query;
    int    i,Cursor,Rows;
 
    int       vId;
    double    vStopLoss;
    double    vTakeProfit;
    int       vOrdem;
    double    vPreco;
    string    vSimbolo;
    double    vSaldo;
    double    vLote;

    Query = "SELECT id, preco, stoploss, takeprofit, ordem, simbolo, lote, saldo_master FROM `fx` ORDER BY numero DESC LIMIT 1";
    Cursor = MySqlCursorOpen(DBConnection, Query);
    
    if (Cursor >= 0)
     {
       Rows = MySqlCursorRows(Cursor);

       for (i=0; i<Rows; i++)
         if (MySqlCursorFetchRow(Cursor)) 
            {
             vId = MySqlGetFieldAsInt(Cursor, 0); // id
             vPreco = MySqlGetFieldAsDouble(Cursor, 1); 
             vStopLoss = MySqlGetFieldAsDouble(Cursor, 2); 
             vTakeProfit = MySqlGetFieldAsDouble(Cursor, 3); 
             vOrdem = MySqlGetFieldAsInt(Cursor, 4); 
             vSimbolo = MySqlGetFieldAsString(Cursor, 5); 
             vLote = MySqlGetFieldAsDouble(Cursor, 6); 
             vSaldo = MySqlGetFieldAsDouble(Cursor, 7); 
             
             //Verifica se a ordem ja esta aberta 
             int contador = 0;
             for(int k=0; k<=OrdersTotal(); k++){
               if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)){
                  if(OrderMagicNumber()==vId){
                     contador++;
                  }
               }
             }
  
             if(contador==0){
             
             // Calcula o lote   
             if(vLote==0.01 && AccountBalance()<vSaldo){ Lote = vLote; }else{
                Lote=vLote*(AccountBalance()/vSaldo);
             }
              
                if(vOrdem == 0 && id_anterior!=vId){
                  if(LoteManual==0.00){
                      ticket = OrderSend(vSimbolo,vOrdem,Lote,MarketInfo(vSimbolo,MODE_ASK),3,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Blue);
                  }else{
                      ticket = OrderSend(vSimbolo,vOrdem,LoteManual,MarketInfo(vSimbolo,MODE_ASK),3,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Blue);
                  }
                  id_anterior=vId;
                }
                
                if((vOrdem == 2 || vOrdem == 4) && id_anterior!=vId){
                  if(LoteManual==0.00){
                      ticket = OrderSend(vSimbolo,vOrdem,Lote,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Blue);
                  }else{
                      ticket = OrderSend(vSimbolo,vOrdem,LoteManual,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Blue);
                  }
                  id_anterior=vId;
                  if(ticket == -1){ Print(GetLastError()); }
                }
                
               ////////////////////////////////////
                
                if(vOrdem == 1 && id_anterior!=vId){
                  if(LoteManual==0.00){
                      ticket = OrderSend(vSimbolo,vOrdem,Lote,MarketInfo(vSimbolo,MODE_BID),3,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Red);
                  }else{
                      ticket = OrderSend(vSimbolo,vOrdem,LoteManual,MarketInfo(vSimbolo,MODE_BID),3,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Red);   
                  }
                  id_anterior=vId;
                }
                
                if((vOrdem == 3 || vOrdem == 5) && id_anterior!=vId){
                  if(LoteManual==0.00){
                      ticket = OrderSend(vSimbolo,vOrdem,Lote,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Red);
                  }else{
                      ticket = OrderSend(vSimbolo,vOrdem,LoteManual,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",vId,0,Red);    
                  }
                  id_anterior=vId;
                  if(ticket == -1){ Print(GetLastError()); }
                }
              }
            }
                   MySqlCursorClose(Rows); 
         }else{ Print ("#Sinais - Cursor opening failed. Error: ", MySqlErrorDescription); }
         
      
    return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Verifica Stop/Take                                               |
//+------------------------------------------------------------------+
void VerificaStop(){

int magic=0;
double stopp=0.0, takee=0.0, vStopLosss=0.0, vTakeProfitt=0.0;

string Queryy;
int    l,Cursorr,Rowss;

for(int i=0; i<=OrdersTotal(); i++){
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      magic = OrderMagicNumber(); 
      takee = OrderTakeProfit();
      stopp = OrderStopLoss();

    Queryy = "SELECT stoploss, takeprofit FROM `fx` WHERE id="+magic+"";
    Cursorr = MySqlCursorOpen(DBConnection, Queryy);
 
    if (Cursorr >= 0)
     {
       Rowss = MySqlCursorRows(Cursorr);

       for (l=0; l<Rowss; l++){
         if (MySqlCursorFetchRow(Cursorr))
            {
             vStopLosss = MySqlGetFieldAsDouble(Cursorr, 0); 
             vTakeProfitt = MySqlGetFieldAsDouble(Cursorr, 1); 
             
             if((vStopLosss != stopp || vTakeProfitt != takee) && (vStopLosss != 0 || vTakeProfitt != 0)){
               if(OrderSelect(OrderTicket(),SELECT_BY_TICKET,MODE_TRADES)){
                  int tick = OrderModify(OrderTicket(),OrderOpenPrice(),vStopLosss,vTakeProfitt,0,clrYellow); 
                     if(tick==-1){
                        Print(GetLastError());
                     }
               }
             }
            }
        } 
       MySqlCursorClose(Rowss); 
     }else{ Print ("#VerificaStop - Cursor opening failed. Error: ", MySqlErrorDescription); }
         
     }
  }
}

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Verifica se a ordem está aberta                                   |
//+------------------------------------------------------------------+
int VerificaOrdens(){ 
   if(OrdersTotal()>0){
      string Query;
      int    Cursor,Rows,Reg;
      
      for(int i=0; i<=OrdersTotal(); i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
            int mNumber = OrderMagicNumber(); 
            
            Query = "SELECT * FROM `fx` WHERE id="+mNumber+"";
            Cursor = MySqlCursorOpen(DBConnection, Query);
            
            if(Cursor >= 0){
               Rows = MySqlCursorRows(Cursor);
               
               if(Rows == 0){
                  if(OrderType()==0){
                     Reg = OrderClose(OrderTicket(),OrderLots(),Bid,0,Yellow);
                  }
                  
                  else if(OrderType()==1){
                     Reg = OrderClose(OrderTicket(),OrderLots(),Ask,0,Yellow); 
                  }
                  
                  else if(OrderType()==2 || OrderType()==4 || OrderType()==3 || OrderType()==5){
                     Reg = OrderDelete(OrderTicket());
                  }
               }
               
               MySqlCursorClose(Rows);
            }else{ Print ("#VerificaOrdens - Cursor opening failed. Error: ", MySqlErrorDescription); }
         }
      }
   }
                
   return(0);
} 
//+------------------------------------------------------------------+


