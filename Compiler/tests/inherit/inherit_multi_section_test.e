class CHILD
inherit
    PARENT_A
        redefine
            calculate
        end

    PARENT_B
        rename
            calculate as calculate_b
        end

    PARENT_C
        undefine
            execute
        end

    PARENT_D
        export
            {ANY} read, write
        end

    PARENT_E
        select
            calculate
        end
end