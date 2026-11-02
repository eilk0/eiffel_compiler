class CHILD
inherit
    PARENT
        redefine
            calculate
        end
feature
    calculate (x: INTEGER)
        do
            Precursor (x)
        end
end
