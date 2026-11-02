class TEST
feature
    calculate : INTEGER
        do
            Result := 10
        rescue
            Result := 0
            retry
        end
end
