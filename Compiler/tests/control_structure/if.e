class IFTEST

feature 

    if_f (a : INTEGER)
    do 
        if a > 1 then a := 0 end 
        
    end

    ifelse_f (a : INTEGER)
    do 
        if a > 1 then a := 0
        elseif a > 3 then a := 0
        else a := 0 
        end
        
    end

end
