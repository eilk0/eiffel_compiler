note
	description: "Summary description for {STUDENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	student
	inherit
		PERSON
create
	new_student

feature
	new_student(in_name: STRING )
	do
		new(in_name)
	end
end
