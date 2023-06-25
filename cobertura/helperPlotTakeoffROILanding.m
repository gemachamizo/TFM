function helperPlotTakeoffROILanding(gax,tLat,tLon,lLat,lLon,llapoints)
geoplot(gax,tLat,tLon,LineWidth=2,MarkerSize=25,LineStyle="none",Marker=".")
text(gax,tLat+0.0025,tLon,"Takeoff",HorizontalAlignment="center",FontWeight="bold")
geoplot(gax,llapoints(:,1),llapoints(:,2),MarkerSize=25,Marker=".")
text(gax,mean(llapoints(:,1)),mean(llapoints(:,2))+0.006,"ROI",HorizontalAlignment="center",Color="white",FontWeight="bold")
geoplot(gax,lLat,lLon,LineWidth=2,MarkerSize=25,LineStyle="none",Marker=".")
text(gax,lLat+0.0025,lLon,"Landing",HorizontalAlignment="center",FontWeight="bold")
end