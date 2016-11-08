//+------------------------------------------------------------------+
//|                                                       server.mq4 |
//|                                                        Jam Sávio |
//|                               https://www.facebook.com/jaamsavio |
//+------------------------------------------------------------------+
#property copyright "Replicar Sinais - Created by Jam Sávio - Server"
#property link      "https://www.facebook.com/jaamsavio"
#property version   "1.00"
#include "..\Include\MqlMySql.mqh"
//--- parameters
int      DBConnection;
int      TicketAfter;
int      TicketBefore;
double   StopLoss;
double   TakeProfit;
double   Preco;
int      TipOP; 
int      IdOrdem;
string   Simbolo; 
string   Corretora;
string   Minutos;
string   Hora;
string   Dia;
string   Mes;
string   Ano;   

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
      
   Simbolo=Symbol();
   Corretora=AccountCompany();              
   TicketAfter=0;
   TicketBefore=1;
   StopLoss=0.0;
   TakeProfit=0.0;
   TipOP=0;
   IdOrdem=0;
   Dia=Day();
   Mes=Month();
   Ano=Year();
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
      ModificaStop();
      VerificaDados();
      OrdensAbertas();                             
  }   
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Verifica Ordens e envia                                          |
//+------------------------------------------------------------------+
int VerificaDados(){

   for(int i=0; i<=OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
               TicketAfter=OrderTicket();
       }
     }
     
     if(TicketAfter!=TicketBefore){  
         if(OrderSelect(TicketAfter,SELECT_BY_TICKET,MODE_TRADES)){
                                    IdOrdem=OrderTicket();
                                    TicketBefore=TicketAfter;
                                    Preco=OrderOpenPrice();
                                    StopLoss=OrderStopLoss();
                                    TakeProfit=OrderTakeProfit();
                                    TipOP=OrderType();
                                    Simbolo=OrderSymbol();
                                    Hora=Hour()+1;
                                    Minutos=Minute();
                                    
                                    if(Hora==23){
                                       int n=24;
                                       Hora=n;
                                    }
                                    
                                    string Q;
                                    int C,R;

     
                                    Q = "SELECT id FROM fx WHERE id='"+IdOrdem+"'";
                                    C = MySqlCursorOpen(DBConnection, Q);
 
                                    if (C >= 0)
                                    {
                                        R = MySqlCursorRows(C);
                                        if(R==0){
                                           EnviarDados(); 
                                        }   
                                    }else
                                         {
                                           Print ("#VerificaDados - Cursor opening failed. Error: ", MySqlErrorDescription);
                                         }
   
                                  
                                        MySqlCursorClose(C);    
                                    }   
                                  }
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Enviar dados da operação
//+------------------------------------------------------------------+
int EnviarDados()
  {
//---
      string query;
      
      if(Simbolo == Symbol()){
         query = "INSERT INTO fx (id, corretora, preco, stoploss, takeprofit, ordem, simbolo, dia, mes, ano, hora, minutos) VALUES ('" + IdOrdem + "', '" +  Corretora + "', '" + Preco + "', '" + StopLoss + "', '" + TakeProfit + "', '" +  TipOP + "', '" + Simbolo + "', '" + Dia + "', '" + Mes + "', '" + Ano + "', '" + Hora + "', '" + Minutos + "')";
    
         if (!MySqlExecute(DBConnection, query))
         {
            Comment("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",query);
         }else{
               Alert("Sinal enviado! #"+Symbol());
         }  
      }
   
 
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Verifica se as ordens estão abertas                              |
//+------------------------------------------------------------------+
int OrdensAbertas(){
   
   string Q;
   int v,C,R,vID,count=0;  

    Q = "SELECT id FROM fx";
    C = MySqlCursorOpen(DBConnection, Q);
 
    if (C >= 0)
     {
       R = MySqlCursorRows(C);
        for (v=0; v<R; v++){
         if (MySqlCursorFetchRow(C))
            {
             vID = MySqlGetFieldAsInt(C, 0); 
            
            if(OrdersTotal()>0){
             for(int c=0; c<=OrdersTotal(); c++){
                if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES)){
                   if(OrderTicket()==vID){
                     count++;
                   }
                }
              }
            }else{
               count=0;
            }
                             
             if(count == 0){
               string Qe;
               Qe = "DELETE FROM fx WHERE id='"+vID+"'";
               
               if (!MySqlExecute(DBConnection, Qe))
                  {
                     Comment("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",Qe);
                  }
               }
             
             }
         
     }
       MySqlCursorClose(C);      
     }else{
     Print ("#OrdensAbertas - Cursor opening failed. Error: ", MySqlErrorDescription);
    }
   
  
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Modifica stop/take                                               |
//+------------------------------------------------------------------+

int ModificaStop(){
   int tickett=0;
   double stopp=0.0, takee=0.0, vStopLosss=0.0, vTakeProfitt=0.0;
   
   string Queryy;
   int l,Cursorr,Rowss;

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
             
             if((takee != 0 || stopp != 0) && (vStopLosss!=stopp || vTakeProfitt!=takee)){
               
               string Qe;
               Qe = "UPDATE fx SET takeprofit='"+takee+"', stoploss='"+stopp+"' WHERE id='"+tickett+"'";
    
                if (!MySqlExecute(DBConnection, Qe))
                   {
                     Comment("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",Qe);
                   }else{
                          Alert("Stop/Take modificado #"+Symbol());
                   }
             
             }
            }
        } 

       MySqlCursorClose(Cursorr);    
     }else
    {
     Print ("Cursor opening failed. Error: ", MySqlErrorDescription);
    }
   }
  }
    

  return(0);
}  