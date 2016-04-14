# 本次目標

  * demo 成果 / 半成品

  * 討論確認之後活動進行的方式~

# 雜談

  * CindyLinz 介紹了一下，下次活動的進行方式。大意是：寫 transpiler ，會規定進度，大家在活動時間實作。回家可以偷跑，但不強制。

  * 第一次的目標應該是把 Haskell 的環境，還有那個 parser 弄起來。 CindyLinz 會以 [stack][haskell-stack] 為主，當然大家要使用 cabal 或 Haskell platform 也可以。 stack 的好處大概是有 sandbox ，雖然 cabel-sandbox 也可以這樣用，但是每個 project 都要裝一遍該 package 。 stack 的好處是，他看到你這個是公用的，就會幫你管理。 stack 還能幫你管理不同版本的 GHC ，像 base 這個 package 就和 ghc 的版本綁在一起。

  * 也提到 xmonad 與 stack 一起用時，得靠 stack 來啟動。

  * 插座比較少，大家得輪著用。在老房子用延長線不是好主意。

  [haskell-stack]: http://haskellstack.org/

# Haskell.js - CindyLinz

  * CindyLinz 正在 refactor transpiler 。

  * 之前的 desugar 們，都是用程式貼出來的。 type 不變，只有些微的內容改變。但這樣有些功能沒法用：

    ```
    let
      a
      b
      c
    in
     let
       d
       e
       f
       -- 略
    ```

  * 希望在不同層，會先有 a, b, c 可以用，然後有 d, e, f 可以用。離開最裡面那層， d, e, f 就不能用了。現在 desugar 的結構不好做這件事。

  * 好像上次 HVG 的 Monad 那樣，像 AlexLu 後來寫的（Desugar）版本那樣，用 Monad 來做。

  * 有些 desugar 很單純（像是 List ），不會產生出新的東西。但像 CaseReorder 會用到新的 desugar 的東西，沒法很清楚什麼時候是最後一站。本來 desugar 像個 filter 那樣一路走下去，但 CaseReorder 到下一站後還可能會到前一站。

  * 於是 CindyLinz 就打算寫個巨大的骨幹（Monad Desugar）。等等會介紹為什麼裡面有 Desugarable ，和多形無關。

  * 之後 Desugar 只要寫需要的部分，不用像之前那樣全部寫。

  * CindyLinz 介紹了 vim 巨集幫忙改 code 的作法。靠 `q` 錄，靠 `@` 播放。 vim 那些跳字的指令（f, e, b）很好用。

  * silverneko 問到能不能給 default 的行為， CindyLinz 表示 `delfExp` 在做的就是這樣的事情。骨幹會找出所有要改變的地方。並以 desugar `Rhs` 為例。

  * 用 Desugarable ，是因為 GHC 不能互相 import 。 Desugar 要用到 If, List 等等，但如果 If 它們也要用到 Desugar ，就得互相 import 。於是就做了個 DesugarClass.hs ，用途就像 C 中的 .h 檔。使用的時候，只要 `import DesugarClass` ，不用互相 import 。用的時候：

    ```
    deX :: (Monad Desugar, Desugarable Desugar (Exp l)) => ...
    ```

  * 介紹了一下，之前規定的基本 Haskell 的 where 前面不能是 Tuple ，寫了個東西把它們拆成 case 。

  * 本來 desugar 都是靠 `.` 串在一起。但最後的 LetBind 會用到前面的東西， CaseReorder 會多跑不知道幾遍。未來希望可以只看一小部分就能處理。而不用看整顆樹。

  * CindyLinz 認為做 type 時可能會用到局部的（變數），才覺得有做成 Monad 的必要。今天要介紹的就是，自己怎麼定義這個 Monad 。

  * 這次從比較抽象的角度來看。

  * Monad 有很多「可以這樣做」的特色，但那是不同 Monad 的部分，不是 Monad 本身的功能。「有那個功能的東西，剛好是個 Monad」，今天要看的是，最原始的 Monad 。

    ```
    (>>=) :: m a -> (a -> m b) -> m b
    return :: a -> m a
    ```

  * CindyLinz 表示要學一件事情，要從兩個角度，例如「大膽假設，小心求證」。做 type 像是「小心求證」這部份，而「大膽假設」，則是遇到一個問題，有覺得這可能是個 Monad 這樣的直覺。可能會猜錯，但要有這種感覺。

  * Monad 會有像是可以串成一條線的感覺，雖然它不見得是從頭到尾執行。 Cindy 以 HVG 為例，表示其 Monad 是用某種方式把 HVG 中定義的 eDSL 接起來。至於怎麼接，是 Monad 作者決定的。

  * 現在希望 symbol 可以在一半決定要新增什麼東西，然後走到後面要把那些東西收回來。 Monad 裡面要藏 symbol ，這樣使用 Monad 的那些 desugar 們，就能取得這些資訊。

  * 唸數學的人可能會對 Monad 的 left identity, right identity, associativity （Monad laws）很興奮。

  * 介紹了一下 Monoid 。

  * Haskell 的 type system 無法保證一個 Monad 符合 Monad laws 。湊 type 時可能 type 湊對了，但是可能會出現無限迴圈。（Haskell 不會去檢查 totality（**？**）） Agda 可以證，不合的話 compile 不會過。 silverneko 表示是 type system 表達力不同造成的。

  * 現在 Haskell 裡面的 Monad 也是 Functor 也是 Applicative 。

  * LCamel 問到 Monoid 和 Monad 的關係。 CindyLinz 提到：「[A monad is just a monoid in the category of endofunctors, what's the issue?][monad-monoid-endofunctors]」這句話 XD

  * Monad 只在 `(a -> m a)` 時是 Monoid 。這時就能把 `(>>=)` 看成 Monoid 的 `(<>)` 。 endofunctor 就是吃一樣的東西。

    ```
    class Functor m where
      fmap :: (a -> b) -> m a -> m b

    class Functor m => Applicative m where
      pure :: a -> m a
      <*> :: m (a -> b) -> m a -> m b

    class Applicative m => Monad m where
      return :: a -> m a
      (>>=) :: m a -> (a -> m b) -> m b
    ```

  * 現在（社群）正在吵要不要把 `return` 去掉。畢竟 `return` 就是 `pure` 。

  * CindyLinz 表示騙人的 Functor ，就好像 0 歐姆的電阻，要塞 Functor 的地方可以用。

  * `Functor ((->) r)` 是個吃到 `r` 就會吐 `a` 的東西。 `fmap` 可以變成 `r -> b` 的函數。

  * 「`(a -> b) -> m a -> m b` 拿真正的函數，裝模作樣一番。 `m (a -> b) -> m a -> m b` 拿裝模作樣的函數，裝模作樣一番。」

  * 提到其他語言中的 Optional 。也提到 PostgreSQL 中的四則運算只要沾到 NULL 也有類似的作用。

  * 「（除了 Monad laws ）額外的功能才是重點。」

  * 會看到 `f <$> a <*> b <*> c` 這樣的用法，其中 `f :: a -> (b -> c)` ， `a :: m a` ， `b :: m b` 。

  * 也有可能寫成 `f' <*> a <*> b` ，或 `pure f <*> a <*> b` 。 CindyLinz 表示在寫骨頭時有用到。

  * 最後要的是 Monad ，他必需是個 Applicative 也是個 Functor 。除了一路寫上來外，也可以一開始就寫 Monad ， Applicative 和 Functor 去用到 Monad 裡的函數。

    ```
    data Desugar a = Desugar a

    instance Functor Desugar where
      fmap :: (a -> b) -> m a -> m b -- 得開 extension 才能在 instance 裡寫 type
      fmap f (Desugar a) = Desugar (f a)
    ```

  * 此時可以不用想自己的 type 的特殊功能，湊 type 即可。

    ```
    instance Applicative Desugar where
      pure a = Desugar a
      Desugar f <*> Desugar a = Desugar (f a)

    instance Monad Desugar where
      -- return 不用寫，會用 Applicative 裡的 pure
      (>>=) :: m a -> (a -> m b) -> m b
      Desugar a >>= f = f a
    ```

  * 湊 type 的時候，小心不要拆開來什麼都沒做又包回去，結果當掉。（但一時想不起當時怎麼弄當的）

    ```
    data Desugar a = Desugar (DesugarState -> (DesugarState, a))
    unDesugar :: Desugar a -> (DesugarState -> (DesugarState, a))
    -- 和下面這樣是一樣的
    data Desugar a = Desugar {unDesugar :: DesugarState -> (DesugarState, a)}
    ```

  * silverneko 想到 GADTs ， CindyLinz 表示講 GADTs 的好像不會講到 records 。

    ```
    -- CindyLinz 表示不知道 GADTs 怎麼縮排比較好看
    data Desugar :: * -> * where
      Desugar ::
        { unDesugar :: DesugarState -> (DesugarState, a)
        , xxx :: Int
        } -> Char -> Desugar a
    ```

  * Cindy 表示不解，為何 GHC 已經可以先寫後寫都沒差了，為什麼還不能數個檔案彼此 import ？

  * desugar 們必須要從 Monad 中拿到資訊，也許不會直接拿到 `DesugarState` ，但會透過其他函數還取得這些資訊。並以 HVG 中的 `queryLink` 為例。現在還沒決定要放什麼，所以才用用一個 type 來放它。

  * 能夠放在 `(DesugarState, a)` 裡的東西， Monad user 可以呼叫一個函數來新增。但數行號這種不需要 user 來告訴你的，就不用，反之則需要。HVG 裡面分兩個參數，是因為有兩種 states ，這不常見，只是 CindyLinz 覺得方便。要達到一樣的效果，可能不用這樣拆，可以用 Tuple 。

  * 數學家可能會覺得 `(a, b) -> c` 和 `a -> b -> c` 是一樣的，同構就很開心。

  * 當決定就是要寫 Monad 時， Functor 跟 Applicative 裡面可以用 Monad （的方式）去做：

    ```
    -- 從 Monad寫上去
    instance Functor Desugar where
      fmap :: (a -> b) -> m a -> m b
      fmap f a = do
        a' <- a
        return (f a')
      -- silverneko 會這樣寫
      -- fmap f a = a >>= return . f

    insntace Applicative Desugar where
      pure = return
      <*> :: m (a -> b) -> m a -> m b
      f <*> a = do
        f' <- f
        a' <- a
        return (f' a')

    instance Monad Desugar where
      return :: Desugar a
      -- return a = pure a -- 這樣 compile 會過，但是會無窮迴圈
      return a = Desuagr $ \state -> (state, a)

      (>>=) :: Desugar a -> (a -> Desugar b) -> Desugar b
      (>>=) (Desugar f) g = Desugar $ \state ->
        let
          (state', a) = f state
          Desugar g' = g a
          (state'', b) = g' state'
        in
          -- 這時要小心，吃哪一個 state （原始的， ' 的， '' 的）， compile 都會過，但是效果不一樣。
          -- do notation 裡面前面做了的事情，後面該不該看到。
          -- CindyLinz 猜給舊的， Monad laws 不會過。
          (state'', b)
        -- YaHT 中會這樣寫， CindyLinz 表示這樣新手根本看不懂，很崩潰：
        -- let
        --   (state', a) = f state
        -- in
        --   unDesugar (g a) state'
    ```

  * 「看 type 說故事」，通常都可以寫得出來。

  * 有時候會倒著寫，但也會從頭寫，好從不同角度看自己的 Monad ，從 Functor 跟 Applicative 的角度來看，可能會發現別的有意思的性質。好比獎盃是個杯子，本來是可以裝水的，但現在很多獎盃（不是杯子），不能裝水。

    ```
    -- 從 Functor 開始寫下來，不用 Monad 提供的 fmap
    instance Functor Desugar where
      fmap :: (a -> b) -> Desugar a -> Desugar b
      fmap f (Desugar g) = Desugar $ \state ->
        let
          (state', a) = g state
          b = f a
        in
          (state', b)

    instace Applicative Desugar where
      <*> :: Desugar (a -> b) -> Desugar a -> Desugar b
      Desugar f <*> Desugar a = Desugar $ \state ->
        let
          (state', f') = f state
          (state'', a') = a state' -- 要給哪個 state ，要看左邊做完會不會影響右邊
                                   -- 通常左邊會影響右邊，到 Simon Marlow 在 facebook 為了平行處理，就寫了左邊不影響右邊的 fmap 。
        in
          (state'', f' a')
    ```

  * CindyLinz 表示有些 Monad 長得很詭異，像 [`ContT`][ContT] 的 `runContT :: (a -> m r) -> m r` 中的 a 就不是放在後面，而是在前面的函數拿到 `a` 。 `ContT` 可以做到 `long jmp` 或是 `coroutine` 的效果。

  * [`sequence :: Monad m => t (m a) -> m (t a)`][sequence] 可以用來把 List 和 Monad 交換。

  * Traversable 是 Functor 也是 Foldable ，大部分的 container 都有這樣的特性。

  * 數學上很難定義個看來自然的 Foldable ，好像怎樣做都可以。

  * silverneko 覺得 `sequence` 像在 Monad 裡面的 `seq` ，把 `[m a, m a, m a] -> m [a, a, a]` 。

  * 在 Hoogle 跟 Hayoo! 都可以用 type 查。 CindyLinz 表示 Hayoo! 查 hackage 比較方便， Hoogle 分析 type 、查 base 很厲害。

  * LCamel 表示把 `t (m a)` 換成 `a (b c)` 查起來也一樣。

  * CindyLinz 表示查不到某種 type 時，可以用 pointless 去湊，但無法給人類讀，也無法維護：

    ```
    \(a, b) -> a >>= \a' -> return (a', b)
    -- 變成
    uncurry (flip (fmap . flip (,)))
    ```

  [monad-monoid-endofunctors]: http://stackoverflow.com/questions/3870088/a-monad-is-just-a-monoid-in-the-category-of-endofunctors-whats-the-issue
  [ContT]: https://hackage.haskell.org/package/mtl-2.2.1/docs/Control-Monad-Cont.html#g:2
  [sequence]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Data-Traversable.html#v:sequence

# 下次聚會時間

  2016.04.28(四)
