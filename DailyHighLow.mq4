//+------------------------------------------------------------------+
//|                                                 DailyHighLow.mq4 |
//|                                                   Hans Kristanto |
//|                         https://www.tradingview.com/u/nivelij01/ |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.tradingview.com/u/nivelij01/"
#property version   "1.00"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

const sinput color   ALTER_COLOR_1 = C'40,20,156';   // Custom Alternate Color #1
const sinput color   ALTER_COLOR_2 = C'20,148,132';  // Custom Alternate Color #2

const string         RECT_CHART_TEMPLATE = "cRectDailySR_";
const long           CHART_ID = ChartID();

double               highOfTheDay;
double               lowOfTheDay;
int                  currentIteratedDay = -1;
int                  lastIndex = 0;
int                  rectIndex = 0;
color                alternatingColor[];

void ResetHighLowOfTheDay()
{
   highOfTheDay = 0;
   lowOfTheDay = 1.7976931348623158 * MathPow(10,308);
}

void CheckHighLowOfTheDay(double high, double low)
{
   if (high > highOfTheDay)
   {
      highOfTheDay = high;
   }

   if (low < lowOfTheDay)
   {
      lowOfTheDay = low;
   }
}

int OnInit()
  {
      ResetHighLowOfTheDay();
      ArrayResize(alternatingColor, 2);
      alternatingColor[0] = ALTER_COLOR_1;
      alternatingColor[1] = ALTER_COLOR_2;

      return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
{
   // Cleanup the chart from boxes
   for (int i=0;i < rectIndex;i++)
   {
      ObjectDelete(CHART_ID, GetRectObjectName(i));
   }
}

string GetRectObjectName(int index)
{
   return StringConcatenate(RECT_CHART_TEMPLATE, index);
}

void DrawRectangle(string objectName, datetime entryDt, double entryPrice, datetime exitDt, double exitPrice, color rectColor)
{
   ObjectCreate(CHART_ID, objectName, OBJ_RECTANGLE, 0, entryDt, entryPrice, exitDt, exitPrice);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_COLOR, rectColor);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_BACK, True);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_SELECTED, False);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_SELECTABLE, False);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_HIDDEN, False);
   ObjectSetInteger(CHART_ID, objectName, OBJPROP_ZORDER, 1);
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
      if (Period() <= PERIOD_H1)
      {
         int limit = rates_total - prev_calculated;
         if (limit == 0)
         {
            limit++;
         }
         
         for (int i=0;i < limit;i++)
         {
            int innerDay = TimeDay(time[i]);

            if (currentIteratedDay == -1)
            {
               currentIteratedDay = innerDay;
            }
            else
            {
               if (currentIteratedDay != innerDay)
               {
                  DrawRectangle(GetRectObjectName(rectIndex), time[i], highOfTheDay, time[lastIndex], lowOfTheDay, alternatingColor[rectIndex % 2]);

                  currentIteratedDay = innerDay;
                  lastIndex = i;
                  ResetHighLowOfTheDay();
                  rectIndex += 1;
               }
            }

            CheckHighLowOfTheDay(high[i], low[i]);
         }
         
         return(rates_total);
      }
      else
      {
         return(0);
      }
  }
//+------------------------------------------------------------------+
