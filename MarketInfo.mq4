//+------------------------------------------------------------------+
//|                                                   MarketInfo.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

input color       MARKET_INFO_COLOR = clrBlack;
const int         FONT_SIZE = 8;
const string      FONT = "Verdana";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   ObjectCreate("MarketInfoBasic", OBJ_LABEL, 0, 0, 0);
   ObjectSet("MarketInfoBasic", OBJPROP_CORNER, 0);
   ObjectSet("MarketInfoBasic", OBJPROP_XDISTANCE, 350);
   ObjectSet("MarketInfoBasic", OBJPROP_YDISTANCE, 2);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   ObjectDelete("MarketInfoBasic");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   
   
   string marketInfo = "";
   marketInfo += "[Spread: " + string(MarketInfo(Symbol(), MODE_SPREAD));
   marketInfo += "  Tick Size: " + string(MarketInfo(Symbol(), MODE_TICKSIZE));
   marketInfo += "  Tick Value: " + AccountCurrency() + string(NormalizeDouble(MarketInfo(Symbol(), MODE_TICKVALUE),2));
   marketInfo += "]";

   
   ObjectSetText("MarketInfoBasic", marketInfo, FONT_SIZE, FONT, MARKET_INFO_COLOR);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
