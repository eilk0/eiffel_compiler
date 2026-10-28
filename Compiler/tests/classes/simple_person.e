class
	person
CREATE
	new
feature
	name: string
	new (in_name : STRING)
		do
			name := in_name
		end

	getName:string
		do
			result:= name
		end
end
