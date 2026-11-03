class LOOPTEST

feature 
    loop_f
        do 
        from i:= 1
        until i>5
            loop 
                print(i.out)
                i:= i+1
         
            end   
        
        end

end
