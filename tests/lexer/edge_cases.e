class
    EDGE_CASES
feature
    operators
        local
            a, b: INTEGER
        do
            a:=10
            b :=20

            if a = b then
            elseif a /= b then
            elseif a < b then
            elseif a>b then
            elseif a <= b then
            elseif a >=b then
            end

            if + (a + b) * 2 / b > 0 then
                a:=a-1
                b :=b/ 2
            end
        end
    strings
        local
            str : STRING
        do
            str := ""
            str := " "
            str := "    "
            str := "%N"
            str := "Hello world"
            str := "String  with tab"
            str := "123 + 456 = 579"
        end
    numbers
        local
            int: INTEGER
            rl: REAL
        do
            int:=0
            int:=-1
            int:=1
            int:=256
            int:=28914098
            rl:=0.0
            rl:=0.1
            rl:=1.2
            rl:=-1.2
            rl:=2.34439
            rl:=2.34E-10
        end
    
    -- some comment here
    -- and some comment here
end
