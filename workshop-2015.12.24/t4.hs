main = do
  case undefined of
    --_ | a <- 123, b <- a -> putStrLn $ show a ++ " " ++ show b
    --_ | b <- a, a <- 123 -> putStrLn $ show a ++ " " ++ show b
    _ | let { b = a ; a = 123 } -> putStrLn $ show a ++ " " ++ show b
    --
    --_ | Just x <- let a = 3 in Just a -> putStrLn $ "Good" ++ show x