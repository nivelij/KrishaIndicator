//+------------------------------------------------------------------+
//|                                              PierceIndicator.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_width1 2
#property indicator_width2 2

extern double     min_pierce_penetration=40.0;
extern double     min_body_size=60.0;
extern double     max_pinbar_size=25.0;

const int      DIGIT = int(MarketInfo(Symbol(), MODE_DIGITS));

double down[];
double up[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, down);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 234);

   SetIndexBuffer(1, up);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);

   min_body_size = min_body_size / 100;
   min_pierce_penetration = min_pierce_penetration / 100;
   max_pinbar_size = max_pinbar_size / 100;

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
   int limit = MathMax(rates_total - prev_calculated, 2);

   for (int i=1;i < limit;i++)
   {
      double prev_total = High[i+1] - Low[i+1];
      double prev_body = MathAbs(Open[i+1] - Close[i+1]);
      double current_total = High[i] - Low[i];
      double current_body = MathAbs(Open[i] - Close[i]);

      if (prev_body/prev_total >= min_body_size && current_body/current_total >= min_body_size)
      {
         if (IsBearishReversal(i))
         {
            down[i] = High[i];
         }
         else if (IsBullishReversal(i))
         {
            up[i] = Low[i];
         }
      }
   }
   
   return(rates_total);
}

bool IsBearishReversal(int i)
{
   double prev_body = MathAbs(Open[i+1] - Close[i+1]);
   double current_body = MathAbs(Open[i] - Close[i]);

   bool openGreaterThenClose = Open[i] > Close[i];
   bool prevCandleBullish = Close[i+1] > Open[i+1];
   bool currOpenIsPrevClose = NormalizeDouble(Open[i], DIGIT - 1) == NormalizeDouble(Close[i+1], DIGIT - 1);
   bool initCriteria = openGreaterThenClose && prevCandleBullish && currOpenIsPrevClose;

   bool isPiercing = initCriteria && 
                     Close[i] >= Open[i+1] &&
                     current_body/prev_body >= min_pierce_penetration;

   bool isEngulfing = initCriteria && Close[i] <= Open[i+1];

   return isPiercing || isEngulfing;
}

bool IsBullishReversal(int i)
{   
   double prev_body = MathAbs(Open[i+1] - Close[i+1]);
   double current_body = MathAbs(Open[i] - Close[i]);

   bool closeGreaterThenOpen = Close[i] > Open[i];
   bool prevCandleBearish = Close[i+1] < Open[i+1];
   bool currOpenIsPrevClose = NormalizeDouble(Open[i], DIGIT - 1) == NormalizeDouble(Close[i+1], DIGIT - 1);
   bool initCriteria = closeGreaterThenOpen && prevCandleBearish && currOpenIsPrevClose;

   bool isPiercing = initCriteria &&
                     Close[i] <= Open[i+1] &&
                     current_body/prev_body >= min_pierce_penetration;
   
   bool isEngulfing = initCriteria && Close[i] >= Open[i+1];
   
   return isPiercing || isEngulfing;
}