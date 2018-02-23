;; roundpolygon.il
;;   Create: Jan/20/2017

procedure( roundPolygon( grid )
	foreach( o (geGetSelectedSet)
		o~>points = mapcar( (lambda (x) mapcar( (lambda (y) grid*floor(y/grid)) x )) o~> points)
	); foreach
); procedure
