// HedgeBot.mq5
// XAUUSD Hedge EA
// Sell 4000 -> Buy Hedge 4005
// Buy 4000  -> Sell Hedge 3995

#include <Trade/Trade.mqh>

CTrade trade;

input double HedgeDistance = 5.00;   // المسافة بالدولار
input double HedgeLot      = 0.01;   // حجم الهيدج
input ulong  MagicNumber   = 505050;

bool hedge_open = false;

int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   string symbol = _Symbol;

   // نبحث عن الصفقة الأصلية
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;

      ulong magic = (ulong)PositionGetInteger(POSITION_MAGIC);

      // نتجاهل صفقات البوت نفسه
      if(magic == MagicNumber)
         continue;

      ENUM_POSITION_TYPE type =
         (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double entry =
         PositionGetDouble(POSITION_PRICE_OPEN);

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

      // Sell من 4000 -> Hedge Buy عند 4005
      if(type == POSITION_TYPE_SELL)
      {
         if(ask >= entry + HedgeDistance)
         {
            OpenBuyHedge(symbol);
         }
      }

      // Buy من 4000 -> Hedge Sell عند 3995
      if(type == POSITION_TYPE_BUY)
      {
         if(bid <= entry - HedgeDistance)
         {
            OpenSellHedge(symbol);
         }
      }

      break;
   }
}

void OpenBuyHedge(string symbol)
{
   trade.Buy(
      HedgeLot,
      symbol,
      0,
      0,
      0,
      "HEDGE BUY"
   );
}

void OpenSellHedge(string symbol)
{
   trade.Sell(
      HedgeLot,
      symbol,
      0,
      0,
      0,
      "HEDGE SELL"
   );
}
