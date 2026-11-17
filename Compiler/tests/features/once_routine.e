class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature test (conc: INTEGER_32) : INTEGER_32
	once
		RESULT := conc
	end

feature make
		do
			print ("Hello Eiffel World! " + test(10).out + "%N") -- 10
			print ("Hello Eiffel World! " + test(4).out + "%N") -- 10
		end
end
