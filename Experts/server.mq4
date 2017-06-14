//+------------------------------------------------------------------+
//|                                                       server.mq4 |
//|                                                        Jam S�vio |
//|                               https://www.facebook.com/jaamsavio |
//+------------------------------------------------------------------+
#property copyright "Replicar Sinais - Created by Jam S�vio - Server"
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
double   Lote;
int      TipOP; 
int      IdOrdem;
string   Simbolo; 
int      Numero;
int      Saldo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  //--- create timer
  EventSetTimer(1);
  //---

  DBConnection = MySqlConnect("52.89.190.145", "jam", "311072", "forex", 3306, "", 0);
  if (DBConnection==-1) {
    Print("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription);
    return (1);
  }
      
  Simbolo=Symbol();           
  TicketAfter=0;
  TicketBefore=1;
  StopLoss=0.0;
  TakeProfit=0.0;
  TipOP=0;
  IdOrdem=0;
  //---
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  //---                    
  ModificaStop();
  VerificaDados();
  OrdensAbertas();                             
}   

//+------------------------------------------------------------------+
//| Verifica Ordens e envia                                          |
//+------------------------------------------------------------------+
int VerificaDados() {

  for (int i=0; i<=OrdersTotal(); i++) {
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
      TicketAfter=OrderTicket();
    }
  }
     
  if (TicketAfter!=TicketBefore) {
    if (OrderSelect(TicketAfter,SELECT_BY_TICKET,MODE_TRADES)) {
      IdOrdem=OrderTicket();
      TicketBefore=TicketAfter;
      Preco=OrderOpenPrice();
      StopLoss=OrderStopLoss();
      TakeProfit=OrderTakeProfit();
      TipOP=OrderType();
      Simbolo=OrderSymbol();
      Saldo=AccountBalance();
      Lote=OrderLots();
      
      ////////////// ordem da opera��o
      if (OrdersTotal()>0) {
        Numero=OrdersTotal();
      } else {
        Numero=1;
      }
      //////////////
          
      string Q;
      int C,R;

      Q = "SELECT id FROM fx WHERE id='"+IdOrdem+"'";
      C = MySqlCursorOpen(DBConnection, Q);

      if (C >= 0) {
        R = MySqlCursorRows(C);
        if (R==0) {
          EnviarDados(); 
        }   
        MySqlCursorClose(R);    
      } else {
        Print ("#VerificaDados - Cursor opening failed. Error: ", MySqlErrorDescription);
      }
    }   
  }
  return(0);
}

//+------------------------------------------------------------------+
//| Enviar dados da opera��o
//+------------------------------------------------------------------+
int EnviarDados() {
  string query;
      
  query = "INSERT INTO fx (id, preco, stoploss, takeprofit, ordem, simbolo, numero, lote, saldo_master) VALUES ('" + IdOrdem + "', '" + Preco + "', '" + StopLoss + "', '" + TakeProfit + "', '" +  TipOP + "', '" + Simbolo + "', '" + Numero + "', '" + Lote + "', '" + Saldo + "')";
    
  if (!MySqlExecute(DBConnection, query)) {
    Alert("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",query);
  } else {
    Print("Sinal enviado! #"+Simbolo);
  }

  return(0);
}

//+------------------------------------------------------------------+
//| Verifica se as ordens est�o abertas                              |
//+------------------------------------------------------------------+
int OrdensAbertas(){
   
  string Q;
  int v,C,R,vID,count=0;  

  Q = "SELECT id FROM fx";
  C = MySqlCursorOpen(DBConnection, Q);
 
  if (C >= 0) {
    R = MySqlCursorRows(C);
    for (v=0; v<R; v++) {
      if (MySqlCursorFetchRow(C)) {
        vID = MySqlGetFieldAsInt(C, 0); 

        if (OrdersTotal()>0) {
          for (int c=0; c<=OrdersTotal(); c++) {
            if (OrderSelect(c,SELECT_BY_POS,MODE_TRADES)) {
              if (OrderTicket()==vID) {
                count++;
              }
            }
          }
        } else {
          count=0;
        }
                             
        if (count == 0) {
          string Qe;
          Qe = "DELETE FROM fx WHERE id='"+vID+"'";
               
          if (!MySqlExecute(DBConnection, Qe)) {
            Comment("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",Qe);
          }
        }
      }   
    }
    
    MySqlCursorClose(R);       
  } else {
    Print ("#OrdensAbertas - Cursor opening failed. Error: ", MySqlErrorDescription);
  }
   
  return(0);
}

//+------------------------------------------------------------------+
//| Modifica stop/take                                               |
//+------------------------------------------------------------------+

int ModificaStop() {
  int tickett=0;
  double stopp=0.0, takee=0.0, vStopLosss=0.0, vTakeProfitt=0.0;
   
  string Queryy;
  int l,Cursorr,Rowss;

  for (int i=0; i<=OrdersTotal(); i++) {
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
      tickett = OrderTicket(); 
      takee = OrderTakeProfit();
      stopp = OrderStopLoss();

      Queryy = "SELECT stoploss, takeprofit FROM `fx` WHERE id="+tickett+"";
      Cursorr = MySqlCursorOpen(DBConnection, Queryy);
 
      if (Cursorr >= 0) {
        Rowss = MySqlCursorRows(Cursorr);
       
        for (l=0; l<Rowss; l++) {
          if (MySqlCursorFetchRow(Cursorr)) {
            vStopLosss = MySqlGetFieldAsDouble(Cursorr, 0); 
            vTakeProfitt = MySqlGetFieldAsDouble(Cursorr, 1); 
             
            if ((takee != 0 || stopp != 0) && (vStopLosss!=stopp || vTakeProfitt!=takee)) {
              string Qe;
              Qe = "UPDATE fx SET takeprofit='"+takee+"', stoploss='"+stopp+"' WHERE id='"+tickett+"'";
    
              if (!MySqlExecute(DBConnection, Qe)) {
                Comment("Error #", MySqlErrorNumber, ": ", MySqlErrorDescription, "\nProblem with query: ",Qe);
              } else {
                Print("Stop/Take modificado #"+Symbol());
              }
            }
          }
        } 

        MySqlCursorClose(Rowss);    
      } else {
        Print ("Cursor opening failed. Error: ", MySqlErrorDescription);
      }
    }
  }

  return(0);
}  