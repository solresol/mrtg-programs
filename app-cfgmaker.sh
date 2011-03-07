#!/bin/sh
# $Id: app-cfgmaker.sh 357 2009-11-17 06:40:18Z bakerg $

TARGET_HOST=$1
shift

# Remaining args are the applications

cat <<EOF
HtmlDir: /aon/mrtg/html
ImageDir: /aon/mrtg/html/images
LogDir: /aon/mrtg/logs
EnableIPv6: no


EOF

for app in $*
do
  echo "# $app"
  echo "Target[${TARGET_HOST}_${app}_cpu]: \`cat /aon/mrtg/appdata/${TARGET_HOST}/${app}-cpu.mrtg\`"
  echo "MaxBytes[${TARGET_HOST}_${app}_cpu]: 10000"
  echo "Title[${TARGET_HOST}_${app}_cpu]: CPU usage for ${app} on ${TARGET_HOST}"
  echo "PNGTitle[${TARGET_HOST}_${app}_cpu]: CPU usage for ${app} on ${TARGET_HOST}"
  echo "PageTop[${TARGET_HOST}_${app}_cpu]: <h1>CPU usage for ${app} on ${TARGET_HOST}</h1>"
  echo "Options[${TARGET_HOST}_${app}_cpu]: growright,gauge,pngdate,printrouter,nopercent,dorelpercent,noo"
  echo "YLegend[${TARGET_HOST}_${app}_cpu]: CPU Usage"
  echo "Legend1[${TARGET_HOST}_${app}_cpu]: ${app}"
  echo "Legend2[${TARGET_HOST}_${app}_cpu]: All on ${TARGET_HOST}"
  echo "Legend3[${TARGET_HOST}_${app}_cpu]: Peak"
  echo "Legend4[${TARGET_HOST}_${app}_cpu]: Peak for all on ${TARGET_HOST}"
  echo "ShortLegend[${TARGET_HOST}_${app}_cpu]: %"
  echo "LegendI[${TARGET_HOST}_${app}_cpu]: ${app}:"
  echo "LegendO[${TARGET_HOST}_${app}_cpu]: All:"
  echo "WithPeak[${TARGET_HOST}_${app}_cpu]: wmy"


  echo "Target[${TARGET_HOST}_${app}_mem]: \`cat /aon/mrtg/appdata/${TARGET_HOST}/${app}-mem.mrtg\`"
  echo "MaxBytes[${TARGET_HOST}_${app}_mem]: 1000000000000"
  echo "Title[${TARGET_HOST}_${app}_mem]: Memory usage for ${app} on ${TARGET_HOST}"
  echo "PNGTitle[${TARGET_HOST}_${app}_mem]: Memory usage for ${app} on ${TARGET_HOST}"
  echo "PageTop[${TARGET_HOST}_${app}_mem]: <h1>Memory usage for ${app} on ${TARGET_HOST}</h1>"
  echo "Options[${TARGET_HOST}_${app}_mem]: growright,gauge,pngdate,printrouter,nopercent,dorelpercent,noo"
  echo "YLegend[${TARGET_HOST}_${app}_mem]: Memory Usage"
  echo "Legend1[${TARGET_HOST}_${app}_mem]: ${app}"
  echo "Legend2[${TARGET_HOST}_${app}_mem]: All on ${TARGET_HOST}"
  echo "Legend3[${TARGET_HOST}_${app}_mem]: Peak"
  echo "Legend4[${TARGET_HOST}_${app}_mem]: Peak for all on ${TARGET_HOST}"
  echo "ShortLegend[${TARGET_HOST}_${app}_mem]: B"
  echo "LegendI[${TARGET_HOST}_${app}_mem]: ${app}:"
  echo "LegendO[${TARGET_HOST}_${app}_mem]: All:"
  echo "WithPeak[${TARGET_HOST}_${app}_mem]: wmy"

done

echo ""
echo "# OTHER"
echo "Target[${TARGET_HOST}_OTHER_cpu]: \`cat /aon/mrtg/appdata/${TARGET_HOST}/OTHER-cpu.mrtg\`"
echo "MaxBytes[${TARGET_HOST}_OTHER_cpu]: 10000"
echo "Title[${TARGET_HOST}_OTHER_cpu]: CPU usage for OTHER on ${TARGET_HOST}"
echo "PNGTitle[${TARGET_HOST}_OTHER_cpu]: CPU usage for OTHER on ${TARGET_HOST}"
echo "PageTop[${TARGET_HOST}_OTHER_cpu]: <h1>CPU usage for OTHER on ${TARGET_HOST}</h1>"
echo "Options[${TARGET_HOST}_OTHER_cpu]: growright,gauge,pngdate,printrouter,nopercent,dorelpercent"
echo "YLegend[${TARGET_HOST}_OTHER_cpu]: CPU Usage"
echo "Legend1[${TARGET_HOST}_OTHER_cpu]: OTHER"
echo "Legend2[${TARGET_HOST}_OTHER_cpu]: All on ${TARGET_HOST}"
echo "Legend3[${TARGET_HOST}_OTHER_cpu]: Peak"
echo "Legend4[${TARGET_HOST}_OTHER_cpu]: Peak for all on ${TARGET_HOST}"
echo "ShortLegend[${TARGET_HOST}_OTHER_cpu]: %"
echo "LegendI[${TARGET_HOST}_OTHER_cpu]: OTHER:"
echo "LegendO[${TARGET_HOST}_OTHER_cpu]: All:"
echo "WithPeak[${TARGET_HOST}_OTHER_cpu]: wmy"
echo ""
echo "Target[${TARGET_HOST}_OTHER_mem]: \`cat /aon/mrtg/appdata/${TARGET_HOST}/OTHER-mem.mrtg\`"
echo "MaxBytes[${TARGET_HOST}_OTHER_mem]: 1000000000000"
echo "Title[${TARGET_HOST}_OTHER_mem]: Memory usage for OTHER on ${TARGET_HOST}"
echo "PNGTitle[${TARGET_HOST}_OTHER_mem]: Memory usage for OTHER on ${TARGET_HOST}"
echo "PageTop[${TARGET_HOST}_OTHER_mem]: <h1>Memory usage for OTHER on ${TARGET_HOST}</h1>"
echo "Options[${TARGET_HOST}_OTHER_mem]: growright,gauge,pngdate,printrouter,nopercent,dorelpercent"
echo "YLegend[${TARGET_HOST}_OTHER_mem]: Memory Usage"
echo "Legend1[${TARGET_HOST}_OTHER_mem]: OTHER"
echo "Legend2[${TARGET_HOST}_OTHER_mem]: All on ${TARGET_HOST}"
echo "Legend3[${TARGET_HOST}_OTHER_mem]: Peak"
echo "Legend4[${TARGET_HOST}_OTHER_mem]: Peak for all on ${TARGET_HOST}"
echo "ShortLegend[${TARGET_HOST}_OTHER_mem]: B"
echo "LegendI[${TARGET_HOST}_OTHER_mem]: OTHER:"
echo "LegendO[${TARGET_HOST}_OTHER_mem]: All:"
echo "WithPeak[${TARGET_HOST}_OTHER_mem]: wmy"
echo ""
