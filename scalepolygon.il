;; scalepolygon.il
;;   Create: Jan/20/2017

procedure( scalePolygon( rate )
	foreach( o (geGetSelectedSet)
		o~>points = mapcar( (lambda (x) dbTransformPoint( x list(0:0 "R0" rate))) o~> points)
	); foreach
); procedure
