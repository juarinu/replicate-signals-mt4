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
int    dia=Day();;
int    mes=Month();;
int    ano=Year();;
int    minutos;
int    hora;
bool   valid=false;
int    ticket;
bool   status=true, showMessage=false; 
extern double LoteManual=0.01; 
string txtValid="";
int    OrdemAntigaId;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1); 
//---
   
   DBConnection = MySqlConnect("localhost", "root", "311072", "forex", 3306, "", 0);
      if (DBConnection==-1)
      {
        Print("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription);
        return (1);
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
                   
             }else{
                   txtValid="#Assinatura - Cursor opening failed. Error: "+MySqlErrorDescription;
             }    
         }else{ status=false; txtValid="Você não possui licença para receber estes sinais."; }
      }MySqlCursorClose(Cursorrr); 
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
    VerifiaOrdens();
   }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Seleciona dados                                                  |
//+------------------------------------------------------------------+
int RecebeSinal()
  {
//---
    minutos=Minute()+3;
    hora=Hour()+1;
    
    string Query;
    int    i,Cursor,Rows;
 
    int       vId;
    double    vStopLoss;
    double    vTakeProfit;
    int       vOrdem;
    double    vPreco;
    string    vSimbolo;

    Query = "SELECT id, preco, stoploss, takeprofit, ordem, simbolo FROM `fx` WHERE dia="+dia+" AND mes="+mes+" AND ano="+ano+" AND hora="+hora+" AND minutos>"+(Minute()-1)+" AND minutos<"+minutos+"";
    Cursor = MySqlCursorOpen(DBConnection, Query);
    
    Print(Query);
    
    if (Cursor >= 0)
     {
       Rows = MySqlCursorRows(Cursor);
       Print(Rows);
       for (i=0; i<Rows; i++)
         if (MySqlCursorFetchRow(Cursor))
            {
             vId = MySqlGetFieldAsInt(Cursor, 0); // id
             vPreco = MySqlGetFieldAsDouble(Cursor, 1); 
             vStopLoss = MySqlGetFieldAsDouble(Cursor, 2); 
             vTakeProfit = MySqlGetFieldAsDouble(Cursor, 3); 
             vOrdem = MySqlGetFieldAsInt(Cursor, 4); 
             vSimbolo = MySqlGetFieldAsString(Cursor, 5); 

                if(vOrdem == 0 && OrdemAntigaId!=vId){
                  ticket = OrderSend(vSimbolo,vOrdem,LoteManual,Ask,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",0,0,Blue);
                  OrdemAntigaId=vId;
                }
                
                if((vOrdem == 2 || vOrdem == 4) && OrdemAntigaId!=vId){
                  ticket = OrderSend(vSimbolo,vOrdem,LoteManual,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",0,0,Blue);
                  OrdemAntigaId=vId;
                }
                
               ////////////////////////////////////
                
                if(vOrdem == 1 && OrdemAntigaId!=vId){
                  ticket = OrderSend(vSimbolo,vOrdem,LoteManual,Bid,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",0,0,Red);
                  OrdemAntigaId=vId;
                }
                
                if((vOrdem == 3 || vOrdem == 5) && OrdemAntigaId!=vId){
                  ticket = OrderSend(vSimbolo,vOrdem,LoteManual,vPreco,0,vStopLoss,vTakeProfit,"Sinal - Savio Trader",0,0,Red);
                  OrdemAntigaId=vId;
                }
             }
         }else{ Print ("#Sinais - Cursor opening failed. Error: ", MySqlErrorDescription); }
         
      MySqlCursorClose(Cursor); 
      
    return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Verifica Stop/Take                                               |
//+------------------------------------------------------------------+
void VerificaStop(){

int tickett=0;
double stopp=0.0, takee=0.0, vStopLosss=0.0, vTakeProfitt=0.0;

string Queryy;
int    l,Cursorr,Rowss;

for(int i=0; i<=OrdersTotal(); i++){
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      tickett = OrderTicket(); 
      takee = OrderTakeProfit();
      stopp = OrderStopLoss();

    Queryy = "SELECT stoploss, takeprofit FROM `fx` WHERE id="+tickett+"";
    Cursorr = MySqlCursorOpen(DBConnection, Queryy);
 
    if (Cursorr >= 0)
     {
       Rowss = MySqlCursorRows(Cursorr);
       
       for (l=0; l<Rowss; l++){
         if (MySqlCursorFetchRow(Cursorr))
            {
             vStopLosss = MySqlGetFieldAsDouble(Cursorr, 0); 
             vTakeProfitt = MySqlGetFieldAsDouble(Cursorr, 1); 
             
             if((vStopLosss != takee || vTakeProfitt != stopp) && (vStopLosss != 0 || vTakeProfitt != 0)){
               if(OrderSelect(tickett,SELECT_BY_TICKET,MODE_TRADES)){
                  tickett = OrderModify(tickett,OrderOpenPrice(),vStopLosss,vTakeProfitt,0,clrNONE); 
               }
             }
            }
        } 
      
     }else{ Print ("#StopTake - Cursor opening failed. Error: ", MySqlErrorDescription); }
       MySqlCursorClose(Cursorr);    
   }
  }
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Verifica se a ordem está aberta                                   |
//+------------------------------------------------------------------+
int VerifiaOrdens(){ 
   int id=0, Queryy, Cursorr, Rowss;
   
   if(OrdersTotal()>0){
      for(int ie=0; ie<=OrdersTotal(); ie++){
         if(OrderSelect(ie,SELECT_BY_POS)){
            id=OrderTicket();
            Queryy = "SELECT id FROM `fx` WHERE id="+id+"";
            Cursorr = MySqlCursorOpen(DBConnection, Queryy);
 
               if (Cursorr >= 0)
               {
                  Rowss = MySqlCursorRows(Cursorr);
                  if(Rowss == 0 && OrderComment() == "Sinal - Savio Trader"){
                    int tick = OrderClose(id,OrderLots(),OrderOpenPrice(),0,Yellow);
                  }
               }
      
            MySqlCursorClose(Cursorr);    
          }
      }
   }
   return(0);
} 
//+------------------------------------------------------------------+

