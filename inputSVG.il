;; inputSVG.il
;;   Create: Jan/20/2017

procedure( inputSVG( svgfile )
	sprintf(cmd "svg2polygon.pl %s > pointlist" svgfile)
	proc = ipcBeginProcess(cmd)
	ipcWait(proc)
	polygons = infile("pointlist")
	while(gets(polygon polygons)
;		printf("%s" polygon)
		polygon = car(parseString(polygon "\n"))
		if( polygon then
			points = mapcar( (lambda (x) mapcar( (lambda (y) (atof y))  parseString(x ":")) ) parseString(polygon " "))
			dbCreatePolygon(geGetEditCellView() list("GP" "drawing") points)
		); if
	); while
	close(polygons)
); procedure
