class CHILD
inherit
    PARENT
        redefine
            calculate
        end
feature
    calculate
        do
            Result := Precursor
        end
end
