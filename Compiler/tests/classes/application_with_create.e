class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE}

	make
		do
			create student.new_student("John")
			print (student.getName)
		end

end
