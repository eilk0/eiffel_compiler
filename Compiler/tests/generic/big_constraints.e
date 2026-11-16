class
    TEST [
        A,

        B -> COMPARABLE,
        C -> {HASHABLE, STRING},

        D -> COMPARABLE rename is_less as compare end,
        E -> {
            HASHABLE,
            COMPARABLE rename is_less as compare end
        },

        F -> COMPARABLE create default_create end,
        G -> {
            HASHABLE,
            COMPARABLE
        } create default_create end,

        H -> {
            COMPARABLE rename is_less as compare, is_less2 as compare2 end,
            HASHABLE
        } create default_create end,

        I -> LIST [INTEGER],
        J -> ARRAY [LIST [INTEGER]],

        K -> {HASHABLE, COMPARABLE} create default_create end
    ]

end
