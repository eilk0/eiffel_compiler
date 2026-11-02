class CHILD
inherit
    PARENT_A
        redefine
            calculate
        end
    PARENT_B
        redefine
            calculate
        end
feature
    calculate
        do
            Precursor {PARENT_A}
        end
end
