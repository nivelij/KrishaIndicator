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

extern double     min_pierce_penetration=51.0;
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
   SetIndexLabel(0, "Bearish Reversal");

   SetIndexBuffer(1, up);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexLabel(1, "Bullish Reversal");

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
   int limit = rates_total - prev_calculated;

   // For future candle
   if (limit == 1)
   {
      Logic(1);
   }
   // For previous candle
   else if (limit == rates_total)
   {
      for (int i=1;i < limit - 1;i++)
      {
         Logic(i);
      }
   }
   
   return(rates_total);
}

void Logic(int i)
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

bool IsPriceFlat(double open, double high, double low, double close)
{
   return open == high && open == low && open == close;
}

bool IsBearishReversal(int i)
{
   if (IsPriceFlat(Open[i+1], High[i+1], Low[i+1], Close[i+1]) || IsPriceFlat(Open[i], High[i], Low[i], Close[i]))
      return false;

   double prev_total = High[i+1] - Low[i+1];
   double prev_body = MathAbs(Open[i+1] - Close[i+1]);
   double current_total = High[i] - Low[i];
   double current_body = MathAbs(Open[i] - Close[i]);

   bool openGreaterThenClose = Open[i] > Close[i];
   bool prevCandleBullish = Close[i+1] > Open[i+1];
   bool currOpenIsPrevClose = NormalizeDouble(Open[i], DIGIT - 2) == NormalizeDouble(Close[i+1], DIGIT - 2);
   bool initCriteria = openGreaterThenClose && prevCandleBullish && currOpenIsPrevClose;
   bool bodyMustFit = current_body/current_total >= min_body_size; 

   /**
    * Justification:
    * 1. For piercing pattern, we need to ensure that previous candle has little to non rejection, as it won't burst through
    * 2. For engulfing, as long as current body engulf previous candle high - low.
    **/
   bool isPiercing = initCriteria
                     && Close[i] >= Open[i+1]
                     && current_body/prev_body >= min_pierce_penetration
                     && bodyMustFit
                     && prev_body/prev_total >= min_body_size;

   bool isEngulfing = openGreaterThenClose
                     && prevCandleBullish
                     && (Close[i+1] <= Open[i] || currOpenIsPrevClose)  // To cater for current candle engulf whole previous candle body
                     && Close[i] < Open[i+1]
                     && bodyMustFit;

   bool isPinbar = initCriteria
                   && Close[i] < Close[i+1]
                   && High[i] > High[i+1]
                   && (Open[i] - Low[i])/current_total <= max_pinbar_size
                   && prev_body/prev_total >= min_body_size;

   return isPiercing || isEngulfing || isPinbar;
}

bool IsBullishReversal(int i)
{   
   if (IsPriceFlat(Open[i+1], High[i+1], Low[i+1], Close[i+1]) || IsPriceFlat(Open[i], High[i], Low[i], Close[i]))
      return false;

   double prev_total = High[i+1] - Low[i+1];
   double prev_body = MathAbs(Open[i+1] - Close[i+1]);
   double current_total = High[i] - Low[i];
   double current_body = MathAbs(Open[i] - Close[i]);

   bool closeGreaterThenOpen = Close[i] > Open[i];
   bool prevCandleBearish = Close[i+1] < Open[i+1];
   bool currOpenIsPrevClose = NormalizeDouble(Open[i], DIGIT - 2) == NormalizeDouble(Close[i+1], DIGIT - 2);
   bool initCriteria = closeGreaterThenOpen && prevCandleBearish && currOpenIsPrevClose;
   bool bodyMustFit = current_body/current_total >= min_body_size; 

   /**
    * Justification:
    * 1. For piercing pattern, we need to ensure that previous candle has little to non rejection, as it won't burst through
    * 2. For engulfing, as long as current body engulf previous candle high - low.
    **/
   bool isPiercing = initCriteria
                     && Close[i] <= Open[i+1]
                     && current_body/prev_body >= min_pierce_penetration
                     && bodyMustFit
                     && prev_body/prev_total >= min_body_size;

   bool isEngulfing = closeGreaterThenOpen
                     && prevCandleBearish
                     && (Close[i+1] >= Open[i] || currOpenIsPrevClose)  // To cater for current candle engulf whole previous candle body
                     && Close[i] > Open[i+1]
                     && bodyMustFit;

   bool isPinbar = initCriteria
                   && Close[i] > Close[i+1]
                   && Low[i] > Low[i+1]
                   && (High[i] - Open[i])/current_total <= max_pinbar_size
                   && prev_body/prev_total >= min_body_size;

   return isPiercing || isEngulfing || isPinbar;
}
