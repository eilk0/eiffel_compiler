class CHILD
inherit
    PARENT
        redefine
            calculate
        end
feature
    calculate
        do
            Precursor
        end
end
