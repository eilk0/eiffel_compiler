note
	description: "project application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		local
			student: student
		do
			create student.new_student("John")
			print (student.getName)
		end

end
