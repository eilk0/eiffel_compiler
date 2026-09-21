class
SORTED_CONTAINER [G -> COMPARABLE create default_create end]

inherit
    ITERABLE [G]
redefine
 new_cursor
end

create
make,
 make_with_capacity

feature    {NONE}

make
do
        create storage.make (10)
        count := 0
    capacity := 10
         is_sorted := True
    ensure
        empty: count = 0
    positive_capacity: capacity > 0
    end

make_with_capacity (a_capacity: INTEGER)
    require
        valid_capacity: a_capacity > 0
    do
        create storage.make (a_capacity)
        count := 0
        capacity := a_capacity
        is_sorted := True
    ensure
        correct_capacity: capacity = a_capacity
        empty: is_empty
    end

feature

item (i: INTEGER): G
    require
        valid_index: valid_index (i)
    do
        Result := storage @ i
    ensure
        result_exists: Result /= Void
    end

first: G
    require
        not_empty: not is_empty
    do
        Result := item (1)
    end

last: G
    require
        not_empty: not is_empty
    do
        Result := item (count)
    end

count: INTEGER
        -- number of elements
    attribute
        Result := internal_count
    end

capacity: INTEGER
    attribute
        Result := internal_capacity
    end

is_empty: BOOLEAN
    do
        Result := count = 0
    end

has (a_value: G): BOOLEAN
    local
        i: INTEGER
    do
        from
            i := 1
        until
            i > count or Result
        loop
            if item (i) ~ a_value then
                Result := True
            end
            i := i + 1
        variant
            count - i + 1
        end
    end

index_of (a_value: G): INTEGER
    local
        i: INTEGER
    do
        Result := 0
        from
            i := 1
        until
            i > count or Result /= 0
        loop
            if item (i) ~ a_value then
                Result := i
            end
            i := i + 1
        end
    ensure
        valid_result: Result >= 0 and Result <= count
    end

feature

extend (a_value: G)
    require
        value_exists: a_value /= Void
    do
        if count = capacity then
            grow
        end

        internal_count := internal_count + 1
        storage.force (a_value, internal_count)
        is_sorted := False
    ensure
        increased: count = old count + 1
        inserted: item (count) ~ a_value
    end

put (a_value: G; i: INTEGER)
    require
        value_exists: a_value /= Void
        valid_index: valid_index (i)
    do
        storage.put (a_value, i)
        is_sorted := False
    ensure
        same_count: count = old count
        inserted: item (i) ~ a_value
    end

remove (i: INTEGER)
    require
        valid_index: valid_index (i)
    local
        j: INTEGER
    do
        from
            j := i
        until
            j >= count
        loop
            storage.put (storage @ (j + 1), j)
            j := j + 1
        end

        internal_count := internal_count - 1
        is_sorted := False
    ensure
        decreased: count = old count - 1
    end

feature

sort
        -- sort elements in ascending order
    local
        i, j: INTEGER
        tmp: G
    do
        from
            i := 1
        until
            i >= count
        loop
            from
                j := i + 1
            until
                j > count
            loop
                if item (j) < item (i) then
                    tmp := item (i)
                    put (item (j), i)
                    put (tmp, j)
                end
                j := j + 1
            end
            i := i + 1
        end

        is_sorted := True
    ensure
        sorted: is_sorted
    end

is_sorted: BOOLEAN
    attribute
        Result := internal_sorted
    end

feature

new_cursor: ITERATION_CURSOR [G]

    do
        create {SORTED_CONTAINER_CURSOR [G]} Result.make (Current)
    end

print_all
    local
        i: INTEGER
    do
        from
            i := 1
        until
            i > count
        loop
            io.put_string ("Item #")
            io.put_integer (i)
            io.put_string (": ")
            io.put_string (item (i).out)
            io.put_new_line
            i := i + 1
        end
    end

feature {SORTED_CONTAINER, SORTED_CONTAINER_CURSOR}

storage: ARRAYED_LIST [G]

internal_count: INTEGER

internal_capacity: INTEGER

internal_sorted: BOOLEAN

grow
    local
        new_capacity: INTEGER
    do
        new_capacity := capacity * 2 + 1
        storage.grow (new_capacity)
        internal_capacity := new_capacity
    ensure
        increased: capacity > old capacity
    end

valid_index (i: INTEGER): BOOLEAN
    do
        Result := i >= 1 and i <= count
    end
```

invariant
non_negative_count: count >= 0
valid_capacity: capacity > 0
count_within_capacity: count <= capacity
empty_definition: is_empty = (count = 0)
sorted_flag_consistent: is_sorted implies internal_sorted

end