//+------------------------------------------------------------------+
//|                                                         VWAP.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_buffers 1
#property indicator_chart_window
#property indicator_color1 clrRed

input int      Period=14;

double vwap[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, vwap);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexLabel(0, "Volume Weighted Average Price");

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int limit = rates_total - prev_calculated;   

   if (limit == 0)
   {
      limit++;
   }

   for (int i=0;i < limit - Period;i++)
   {
      vwap[i] = CalculateVWAP(Period, i);
   }

   return(rates_total);
}

double CalculateVWAP(int period, int startFrom)
{
   int sumVolume = 0;
   double sumPrice = 0.0;

   for (int i=startFrom;i < startFrom + period;i++)
   {
      sumVolume += Volume[i];
      sumPrice += Close[i] * Volume[i];
   }
   
   return sumPrice/sumVolume;
}