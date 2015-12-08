<?php   
 /* CAT:Stacked chart */

 /* pChart library inclusions */
 include_once("../class/pData.class.php");
 include_once("../class/pDraw.class.php");
 include_once("../class/pImage.class.php");

 /* Create and populate the pData object */
 $file = 'foundit.csv';
 $handler = fopen($file,r);
 $string = fgets($handler);
 $myArray = explode(',', $string);
 $i = 0;
 
 while($string =fgets($handler))
 {
	$myArray = explode(',', $string);
	$components[$i] = $myArray[0];
	++$i;
 }

 
 $MyData = new pData();  
 $MyData->importFromCSV("foundit.csv",array("GotHeader"=>TRUE,"SkipColumns"=>array(0)));
 $MyData->setAxisName(0,"Bug Count");
 $MyData->setAxisName(1,"Components");
 $MyData->addPoints($components,"Components");
 $MyData->setAbscissa("Components");
 //$MyData->setSerieOnAxis("Component",1);
//$MyData->setAxisXY(1,AXIS_X);

/* Create the pChart object */
 $myPicture = new pImage(3000,700,$MyData);
 $myPicture->drawGradientArea(0,0,3000,700,DIRECTION_VERTICAL,array("StartR"=>240,"StartG"=>240,"StartB"=>240,"EndR"=>180,"EndG"=>180,"EndB"=>180,"Alpha"=>100));
 $myPicture->drawGradientArea(0,0,3000,700,DIRECTION_HORIZONTAL,array("StartR"=>240,"StartG"=>240,"StartB"=>240,"EndR"=>180,"EndG"=>180,"EndB"=>180,"Alpha"=>20));

 /* Set the default font properties */
 $myPicture->setFontProperties(array("FontName"=>"../fonts/pf_arma_five.ttf","FontSize"=>6));

 /* Draw the scale and the chart */
 $myPicture->setGraphArea(60,20,3000,680);
 $myPicture->drawScale(array("DrawSubTicks"=>TRUE,"Mode"=>SCALE_MODE_ADDALL_START0));
 $myPicture->setShadow(FALSE);
 $myPicture->drawStackedBarChart(array("Interleave"=>.5,"Surrounding"=>-15,"InnerSurrounding"=>15));



 /* Write the chart legend */
$myPicture->drawLegend(800,10,array("Style"=>LEGEND_NOBORDER,"Mode"=>LEGEND_HORIZONTAL));
 /* Render the picture (choose the best way) */
 $myPicture->Render("foundit.png");
?>