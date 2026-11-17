note
	description: "project_2 application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature obj: A

feature make
		local
		    matrix: ARRAY [ARRAY [INTEGER_32]]
		do
			create obj.make(5)
		    matrix := <<
		        << 1, 2, 3 >>,
		        << 4, obj.v, 6, 7 >>,
		        << 7, 8, 9 >>
		    >>

		    matrix[1] := <<3, 2, 1>>
			print ("Hello Eiffel World!%N")
		end

end
