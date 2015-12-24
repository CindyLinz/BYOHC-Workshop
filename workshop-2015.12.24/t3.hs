{-# LANGUAGE ViewPatterns #-}

main = do
  case (read, "123") of
    (f, (f -> 123)) -> putStrLn "got 123"
    --(f, ((\str -> read str) -> 123)) -> putStrLn "got 123"
    _ -> putStrLn "failed"

--  case bs of
--    (toString bs -> "abc") -> 

--  case ("123", read) of
--    ((f -> 123), f) -> putStrLn "got 123"
--    _ -> putStrLn "failed"

  case (read, "123") of
    (f, v) | 123 <- f v -> putStrLn "got 123"
    _ -> putStrLn "failed"

  case ("123", read) of
    (v, f) | 123 <- f v -> putStrLn "got 123"
    _ -> putStrLn "failed"

--  case abc of
--    .... | Just index <- find aoeuoeau, Just index2 <- find ... -> 