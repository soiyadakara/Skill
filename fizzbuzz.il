procedure( fizzbuzz( n )
	(if  (n > 1) (fizzbuzz (n-1)))

	(cond
		((and (eq (mod n 3) 0) (eq (mod n 5) 0)) (printf "FizzBuzz," n))
		((eq (mod n 3) 0) (printf "Fizz," n))
		((eq (mod n 5) 0) (printf "Buzz," n))
		(t (printf "%d," n))
	); cond
); procedure
