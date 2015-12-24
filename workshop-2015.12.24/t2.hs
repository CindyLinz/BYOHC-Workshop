{-# LANGUAGE PatternSynonyms, ViewPatterns #-}
data Celcius = Celcius Double
pattern Fahrenheit f <- Celcius ((\c -> c * 9 / 5 + 32) -> f) where
  Fahrenheit f2 = Celcius $ (f2 - 32) * 5 / 9

main = do
  let temp = Fahrenheit 33
  --let temp = Fahrenheit 31
  --let temp = Celcius 1
  --let temp = Celcius (-1)
  case temp of
    Fahrenheit x | x < 32 -> putStrLn "iced"
                 | otherwise -> putStrLn "not iced"