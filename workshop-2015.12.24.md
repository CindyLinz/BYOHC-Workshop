# 本次目標

  * 介紹各種 Language Extensions

# 雜談

  * silverneko 之後想接 LLVM IR 。
  * CindyLinz 談了談 GHC 的 GC 與其優缺點。
  * CindyLinz 提到，通過 [strictness analysis](https://en.wikipedia.org/wiki/Strictness_analysis) 的部分，可以直接用 stack 而不是用 heap 做。
  * 再次提到 GHC 的 8 bytes alignment 。
  * CindyLinz 解釋 [ForgetL](https://github.com/CindyLinz/Haskell.js/blob/d950c5ed4693e4423c655f33766c1c141b74c8f3/trans/src/ForgetL.hs) 的用途， alex\_lu 提到也許沒必要這樣做？因為 [Annotated](https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Syntax.html#t:Annotated) 都是 Functor 。有 `amap` 和 `fmap` 可以幫我們修改裡面的 annotation 。
  * 這次做的 where 是沒有 guard 的。

# AlexLu

  * 也是改了以後才發現 Annotated.Syntax 和本來的 Syntax 完全不一樣。
  * CindyLinz 表示根本像是不同人寫的。
  * silverneko 提到 Cofree Comanad 可以在 type 上加東西。
  * CindyLinz 表示也許 desugar 後發現有些 syntax 不會出現，我們就不用做。
  * Annotated 版本沒寫就給我們 Nothing 。
  * 又討論到 Annotated 是 Functor ， AST 全部都是 Annotated ，可以用 `fmap` 跟 `amap` 改變 annotation 。
  * 討論 parseWithMode 跟 parseModuleWithMode 是否有差別？
  * 表示沒有改到很多，所有 XXXName 改成 XXXHead 。
  * 可以把 id 都拿掉嗎？CindyLinz 表示 "patches welcome" 。
  * 有 [Language.Haskell.Exts.Annotated.Build](https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Build.html) 可以用。
  * 把 where 改成 let 。

    ```
    -- DeWhere.hs 中有三段，都是把 where 變成 let
    deWhereAlt (Alt l1 pat (UnGuardedRhs l2 exp) (Just binds)) =
      deWhereAlt (Alt l1 pat (UnGuardedRhs l2 (Let l2 binds exp)) Nothing)
    deWhereDecl (PatBind l1 pat (UnGuardedRhs l2 exp) (Just binds)) =
      deWhereDecl (PatBind l1 pat (UnGuardedRhs l2 (Let l2 binds exp)) Nothing)
    deWhereMatch (Match l1 name pat (UnGuardedRhs l2 exp) (Just binds)) =
      deWhereMatch (Match l1 name pat (UnGuardedRhs l2 (Let l2 binds exp)) Nothing)
    ```

  * CindyLinz 表示之後要做 reorder 。
  * CindyLinz 表示在沒有 slot 時，把空的跟 Nothing 放在一樣的位置是有好處的。
  * transExp 與 qualification 。

    ```
    data MyList a = Nil | Cons a (MyList a)
    xs = [1, 2, 3] -- 需要分清楚 Cons 是指 built-in 的，而非其他模組定義的
    ```

  * CindyLinz 表示，體會到為什麼 `data` 只能用在 top level ，有時候會寫到很大的函數，那裡面就像個子空間一樣，會希望能在裡面用。

# CindyLinz

  * 講了 [DeWhere](https://github.com/CindyLinz/Haskell.js/blob/d950c5ed4693e4423c655f33766c1c141b74c8f3/trans/src/DeWhere.hs) 。
  * CollectData.hs 把程式中所有用到 `data` 的地方都蒐集（[DataShape](https://github.com/CindyLinz/Haskell.js/blob/d950c5ed4693e4423c655f33766c1c141b74c8f3/trans/src/CollectData.hs#L14)）起來，找出順序。
  * 洞的數量也很重要。
  * 用名字的方式描述洞。（**待問**
  * type name 到長相、 data constructor 到長相。（**待問**
  * 現在用的 name 不是 qualified ，會打架。
  * top level 的好處，是大家的名字都不一樣，如果在 function 裡面可以寫 `data` ，那要處理撞名。
  * 曾到 #haskell 抱怨，希望能有上述的功能。只有少數人也希望有這個功能。
  * 只有裡面看得到，也不能 return 到外面。
  * 名字打架很麻煩 >\_<
  * 提到像 [`collectFieldsIndices`](https://github.com/CindyLinz/Haskell.js/blob/d950c5ed4693e4423c655f33766c1c141b74c8f3/trans/src/CollectData.hs#L92) 太長而無法維護的問題。
  * 接下來提到的 extensions 一點一點做，比花一個半月一次全部做完更容易繼續下去。

## Extensions

### PatternGuards

[GHC](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#pattern-guards)

  * pattern 很多行，但不是每行都會用到很細的 type ，所以 pattern 要能比大小。
  * 出現在：
    * 函數的參數是 pattern ，有 branch 。
    * case of 是 pattern ，有 branch 。
    * where 裡的 pattern ，沒有 branch 。
    * let 裡的 pattern ，沒有 branch 。
  * 可以有：
    * 常數， desugar 時最簡單的。
    * 一個變數，或是「我不管」（`_`）的變數，也是好寫的。
    * 開頭是 data constructor 的。
  * Haskell 會一個一個試一下，形狀對了就進去，不對就繼續。
  * `_ ->` 之後的，應該是沒有意義的。
  * `Just a | a ==3 ->` 在 pattern 後面可以有 guard 。
  * 在沒有 guard 時，我們會把春夏秋冬的函數都塞給他，讓他呼叫對的函數。
  * `Just (Just a)` 和 `Just d` ，先都當成 `Just x` ，然後再往下（`case x of`）繼續做 pattern matching 。
  * 但這樣做的話， fallback 時要撤退回上一層（CindyLinz 決定把後面的 pattern 也複製到在內層的 fallback ）。
  * 上述的狀況在有 guards 時會變得很複雜。

    [hlint](https://hackage.haskell.org/package/hlint) 會抱怨以下的程式：

    ```
    let
      det = b*b - 4*a*c
      msg =
        if det == 0 then
          "重根"
        else if det < 0 then
          "沒有重根"
        else
          "二重根"
    ```

    並建議改成：

    ```
    msg | det == 0 = "重根"
        | det < 0 = "沒有實跟"
        | otherwise = "二重根"
    ```

  * MultiWayIf 在有 side-effect 時的好處。覺得在 do-notation 裡面才會想到要用它，如果在 let 或 where 定義東西, 用 guard 就好了。
  * PatternGuards 可以在寫 guard 的地方做 pattern matching ，似乎是預設的了。可以寫好幾個。

    ```
    case abc of
      ... | Just index < - find something, Just index2 <- find ... ->
    ```

  * 好處是 pattern matching 完還有變數可以用。
  * 用 `->` 還是 `=` 就看本來怎麼用。
  * 設計之初是希望 lib user 拿到你的 data type 但是不知道你的 data 長相。他不知道你的 data type 長怎樣，但是可以用你提供的 function 拿出他要用的知道。
  * 或者是 phantom field 。例如內部存攝氏，但提供華氏介面。
  * 或者是圓形，定義圓形的方式有很多種。
  * 反正就是內部資料用一種方式存，但提供很多不同的形狀給外面用。
  * 用多程式會變噁心，但建議可以先濫用再收斂。
  * 不知道 PatternGuard 中用 let 的 extension 的名字。 `let {y=z; z=4}, x==y ->`
  * PatternGuard 中用 `,` 隔開各項，每個都成功才進去。產生的新變數，在（這個 `,` ）右邊就可以用了，包含完全成功的部分。
  * silverneko 問到 `Just x <- let a = 3 in Just a -> putStrLn $ "Good" ++ show x` 能不能用，結果可以。
  * 可以做出去求值就爆炸的東西。
  * `,` 有順序問題， `let` 沒有順序問題。

### ViewPatterns

[GHC](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#view-patterns)/[24 Days](https://ocharles.org.uk/blog/posts/2014-12-02-view-patterns.html)

    ```
    main = do
      case (undefined, "123") of
        (f, (\str -> read str -> 123)) -> putStrLn "got 123"
        _ -> putStrLn "failed"
    ```

  * 把右邊的東西丟進去算一下看等不等於 `->` 右邊的東西。
  * 可以用任意 expression ，只有左邊已經抓到的東西可以用，跟 PatternGuard 全部抓到的都能用不同。
  * 以上面的華氏攝氏為例，可以用來在省變數。
  * list of polymorphism 的東西，一個欄位是資料，另外一個是用來開箱的東西。
  * 先寫資料，後寫函數，想用後面的函數來執行，就失敗。（但後面又可以？
  * 名字打架時，誰會遮誰的問題。
  * 可能會做得跟 GHC 不一樣，做出來會特別註明。反正 ViewPattern 不會用得很兇。用太兇會變得很難讀。
  * 臨時想到要用時加一下[很方便](https://github.com/CindyLinz/Haskell.js/blob/d950c5ed4693e4423c655f33766c1c141b74c8f3/trans/src/CollectData.hs#L46)。

    ```
    collectDataDecl (DataDecl loc dn cxt (forgetLName . declHeadName -> name) cons derivings) = CollectDataResult typeShapes conShapes errs
      where
        -- ...
    ```

### PatternSynonyms

[GHC](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#pattern-synonyms)/[24 Days](https://ocharles.org.uk/blog/posts/2014-12-03-pattern-synonyms.html)

  * 7.8 才有，有些 7.10 才能用。
  * CindyLinz 表示她的 vim 很舊，沒法 highlight 那麼新的語法。
  * 24 Days of GHC Extensions 講得沒有 GHC 自己清楚。

    ```
    -- GHC 的例子
    pattern Arrow t1 t2 = App "->"    [t1, t2]
    pattern Int         = App "Int"   []
    pattern Maybe t     = App "Maybe" [t]
    ```

  * 左邊出現的東西要跟右邊的一樣多，不可以有缺項。
  * 用 `=` 的是雙向的，用 `<-` 是單向的。
  * 7.10 後，單向的也能當 constructor 用。

    ```
    pattern Head x <- x :xs where
      Head x = [x]
    ```

  * 很喜歡這個 extension ，可以不用像 PatternGuard 跟 ViewPattern 那樣寫，用起來像原生的。

    ```
    data Celclus = Celclus Double
    pattern Falrenheit f <- Celclus ((\c -> c * 9 / 5 + 32) -> f) where
      Falrenheit f = Celclus $ (f - 32) * 5 / 9 -- 這邊的 f 不是上一行的 f
    ```

  * 加了 `where` 的這種在 7.10 才能用。
  * `=` 那種不能用 ViewPattern ， `<-` 可以。 Haskell 看不出來 `=` 中的反函數。
  * 但 CindyLinz 表示自己很少定義那麼漂亮的資料結構。
  * 應該怎麼做才是對的？可能可以用取代的？

# 雜談

  * 反正現在寫 Haskell 的程式都沒有傷害性，先狂用、濫用，再收斂即可。
  * 這些簡單的 extension 可以湊出很複雜的功能。
  * silverneko 最近在上 compiler 課，猶豫要先做 transpiler 還是 codegen 。現在 codegen 還沒有做 IR 。 ASM 還要做一些資源的管理， IR 不用。
  * CindyLinz 問到有沒有試過 IR 中的最大整數？有 (2^24) bits 大小的整數可以試試。可以說是組語內建大數運算！第一個 bit 放 0 ，後面都放 1 ，自己加自己，看能不能做。

# 聚會中用到的 Pattern 相關 extensions sample code

  都可以用 `runghc` 直接執行。

  * [t1.hs](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.24/t1.hs)
    ```haskell
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
    ```

  * [t2.hs](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.24/t2.hs)
    ```haskell
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
    ```

  * [t3.hs](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.24/t3.hs)
    ```haskell
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
    ```

  * [t4.hs](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.24/t4.hs)
    ```haskell
    main = do
      case undefined of
        --_ | a <- 123, b <- a -> putStrLn $ show a ++ " " ++ show b
        --_ | b <- a, a <- 123 -> putStrLn $ show a ++ " " ++ show b
        _ | let { b = a ; a = 123 } -> putStrLn $ show a ++ " " ++ show b
        --
        --_ | Just x <- let a = 3 in Just a -> putStrLn $ "Good" ++ show x
    ```

# 下次聚會時間

2016.01.14(四)

# 廣告

2016.01.07(四)， petercommand 會以[「Compiling Programs in GHC: The Core and STG」](http://www.meetup.com/Functional-Thursday/events/227245474/)為題，介紹 GHC 的實作。

但看了以後可能會限制想像力，就像被雷的感覺。
