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

	feature{ANY}
		getName:string
		do
			result:= name
		end
end
