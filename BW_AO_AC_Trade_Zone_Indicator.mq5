//+------------------------------------------------------------------+
//|                                    AR_BW_AO_AC_Zones_Candles.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGreen,clrIndianRed,clrDarkGray;
#property indicator_width1  3
#property indicator_label1  "Open;High;Low;Close"

double OBuffer[];
double HBuffer[];
double LBuffer[];
double CBuffer[];
double ColorBuffer[];
double AOBuffer[];
double ACBuffer[];

int    ACHandle;
int    AOHandle;

#define DATA_LIMIT 38

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,OBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,ACBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,AOBuffer,INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"AR_BW_AO_AC_Zones_Candles");
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DATA_LIMIT);

   ACHandle=iAC(NULL,0);
   AOHandle=iAO(NULL,0);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| AO AC Zones BW                                                   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i;
   int limit;
   if(rates_total<DATA_LIMIT)
      return(0);

   int calculated=BarsCalculated(ACHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ACHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(AOHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of AOHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }

// AC buffer
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(ACHandle,0,0,to_copy,ACBuffer)<=0)
     {
      Print("Getting iAC failed! Error",GetLastError());
      return(0);
     }
// AO buffer
   if(IsStopped())
      return(0); //Checking for stop flag
   if(CopyBuffer(AOHandle,0,0,to_copy,AOBuffer)<=0)
     {
      Print("Getting iAO failed! Error",GetLastError());
      return(0);
     }
// set first bar for indicator calculation
   if(prev_calculated<DATA_LIMIT)
      limit=DATA_LIMIT;
   else
      limit=prev_calculated-1;

   for(i=limit; i<rates_total && !IsStopped(); i++)
     {
      OBuffer[i]=Open[i];
      HBuffer[i]=High[i];
      LBuffer[i]=Low[i];
      CBuffer[i]=Close[i];

      ColorBuffer[i]=2.0;

      if(ACBuffer[i]>ACBuffer[i-1] && AOBuffer[i]>AOBuffer[i-1])
         ColorBuffer[i]=0.0;

      if(ACBuffer[i]<ACBuffer[i-1] && AOBuffer[i]<AOBuffer[i-1])
         ColorBuffer[i]=1.0;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
