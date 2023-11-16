//+------------------------------------------------------------------+
//|                                                   Connors EA.mq4 |
//|                                    Copyright 2023, Novemind inc. |
//|                                         https://www.novemind.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Novemind inc."
#property link      "https://www.novemind.com"
#property version   "1.00"
#property strict

#resource "\\Indicators\\connors-rsi-indicator.ex4"

input string str1             = "..... Indicator settings ...."; //_
input bool   checkOnClose     = true;                            // Check Close Bar (For Close Only)
input int    sell_Level       = 90;                              // Sell Level
input int    buy_Level        = 10;                              // Buy Level
input int    closeLevel       = 50;                              // Close Level
input double lot_size         = 0.1;                             // Lot Size
input int    magic_number     = 7476;                            // Magic Number

input string str2             = "..... RSI settings ....";       //_
input int    rsiPeriod        = 3;                               // RSI Period
input int    upDownPeriod     = 2;                               // Up Down Period
input int    rocPeriod        = 100;                             // ROC Period
input int    price            = 0;                               // Price

string indiName = "::Indicators\\connors-rsi-indicator.ex4";

datetime expiry=D'2023.12.30 12:00:00';
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(TimeCurrent()>expiry)
     {
      Print("Error: 318");
      ExpertRemove();
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!checkOnClose)
     {
      double rsiPrice = iCustom(Symbol(),PERIOD_CURRENT,indiName,rsiPeriod,upDownPeriod,rocPeriod,price,0,0);
      if(rsiPrice >= closeLevel && orderCount(OP_BUY) > 0)
        {
         Print("Closing Buy Price : ",rsiPrice," >= Close Level:  ",closeLevel);
         closeTrades(OP_BUY);
        }
      else
         if(rsiPrice <= closeLevel && orderCount(OP_SELL) > 0)
           {
            Print("Closing Sell Price : ",rsiPrice," <= Close Level:  ",closeLevel);
            closeTrades(OP_SELL);
           }
     }

   if(newBar())
     {
      double rsiPrice = iCustom(Symbol(),PERIOD_CURRENT,indiName,rsiPeriod,upDownPeriod,rocPeriod,price,0,1);
      Print("RSI Price: ",rsiPrice);

      if(checkOnClose)
        {
         if(rsiPrice >= closeLevel && orderCount(OP_BUY) > 0)
           {
            Print("Closing Buy Price : ",rsiPrice," >= Close Level:  ",closeLevel);
            closeTrades(OP_BUY);
           }
         else
            if(rsiPrice <= closeLevel && orderCount(OP_SELL) > 0)
              {
               Print("Closing Sell Price : ",rsiPrice," <= Close Level:  ",closeLevel);
               closeTrades(OP_SELL);
              }
        }

      if(rsiPrice >= sell_Level)
        {
         placeSellTrades();
        }
      else
         if(rsiPrice <= buy_Level)
           {
            placeBuyTrades();
           }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {
   static datetime lastbar;
   datetime curbar = iTime(Symbol(),PERIOD_CURRENT,0);
   if(lastbar!=curbar)
     {
      lastbar=curbar;
      Print(".... NewBar .... ",curbar);
      return (true);
     }
   else
     {
      return (false);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void placeBuyTrades()
  {
   double buy_sl = 0,buy_tp =0;
   int ticket = OrderSend(Symbol(),OP_BUY,lot_size,Ask,5,buy_sl,buy_tp,"Buy Trade Placed",magic_number,0,clrBlue);
   if(ticket < 0)
     {
      Print("Buy Order Failed ",GetLastError());
     }
   else
     {
      Print("Buy Order Placed Successfully");
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void placeSellTrades()
  {
   double sell_sl = 0,sell_tp=0;
   int ticket = OrderSend(Symbol(),OP_SELL,lot_size,Bid,5,sell_sl,sell_tp,"Sell Trade Placed",magic_number,0,clrRed);
   if(ticket < 0)
     {
      Print("Sell Order Failed ",GetLastError());
     }
   else
     {
      Print("Sell Order Placed Successfully");
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int orderCount(ENUM_ORDER_TYPE type)
  {
   int count=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==magic_number && OrderSymbol()==Symbol())
           {
            if(OrderType()== type)
              {
               count++;
              }
           }
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Function used to close all trades                                 |
//+------------------------------------------------------------------+
void closeTrades(ENUM_ORDER_TYPE type)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic_number && OrderType()==type)
           {
            if((OrderType()==OP_BUY || OrderType()==OP_SELL))
              {
               if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,clrAntiqueWhite))
                 {
                  Print("Problem in closing Order", GetLastError());
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
