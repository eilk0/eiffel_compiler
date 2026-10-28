make
	do
		print (getMessage(5, 6))
	end

buffer: string

getMessage(a: integer; b: integer) : string
	do
		buffer := "HELLO WORLD! " + a.out
		result := buffer
	end