-- Guard, PatternGuard, ViewPattern, PatternSynonyms
main = do
  let x = 3 in case Just 5 of
    _ | False -> putStrLn "Any"
      | let {y=z; z=4}, x==y -> putStrLn "Any otherwise"
    Just a | a == 3 -> putStrLn "Just 3"
    Nothing -> putStrLn "Nothing"
    --x | ... ->
    Just a | a == 4 -> putStrLn "Just 4"
           | otherwise -> putStrLn "Just a"

--let a = 3

--case 3 of a ->

--let
--  det = b*b - 4*a*c
--  msg =
--    if det == 0 then
--      "重根"
--    else if det < 0 then
--      "沒有實根"
--    else
--      "二實根"
--
--  msg | det == 0 = "重根"
--      | det < 0 = "沒有實根"
--      | otherwise = "二實根"

--1234, "aoeusoetnuh", 'a'
--Just a, Nothing, Right (Just a)
--abc, _
--
--case abc of
--  Nothing ->
--  Just (Just a) ->
--  --Just b ->
--  xx | 3 == 4 ->
--  Just b -> 
--
--case abc of
--  Nothing ->
--  Just x -> case x of
--    Just a ->
--    xxxx -> f
--
--xx -> f
--
--
--
--
--
--  Just a | a ==3 ->
--         | a ==4 ->
--  Just b ->
--  _ ->
--
--
--
--f 3 = 242343
--f a | Just index <- find = a + 1
--
--g (Just a) = a
--g (Nothing) = 0
--
--where
-- (a,b) = (1,2)
--
--let
-- (a,b) = (1,2)
--in