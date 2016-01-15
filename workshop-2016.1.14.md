# 本次目標

  * demo 成果 / 半成品
  
    + pattern matching[預計下次進度]

  * 補充上次漏講的 pattern matching 語法

  * 聊聊 symbol table 的實作

# CindyLinz

  * CindyLinz 先談談 symbol table 的問題（WIP 的 CollectData.hs），像上次講到的一樣，希望可以有 local 的 symbol table 。會想知道 desugar 到一半，就知道那時有哪些 symbol 可以用，而不用整個檔案走完才知道。從 scope 出來後可以把裡面的 symbol table 丟掉。**現在每一行都會呼叫 collectData （不確定）**，希望有沒有什麼 Monad transformer 可以幫忙完成這件事情。

    ```
    SymbolTable m => CollectDataResult -> BangType l -> (BangType l)
    ```

  * 接著以 CollectData.hs 的 code 為例，一開始只有 `main` ，走到 `Just (Just a)` 時才看得到 `a` 。
  * 如果寫一個好的 symbol table lib ，那在 desugar 時可以用，在 type check 時也可以用。
  * CindyLinz 接著提到， pattern matching 現在寫到一半，還不能用。覺得寫的很痛苦的原因是，用 Perl （script language）的思維寫 Haskell ，但是實際的 case 太多，會忍不住想做完整。現在只好先寫一段具體的 code ，再寫一段翻譯完（手動 desugar）的 code ，而不是一次處理所有 case 。現在想先處理的是比較複雜、順序不定的 patterns 。
  * 現在 CollectData.hs 中分成三組，Primitive 跟 Constructor 不會同時出現，但有可能跟 wildcard 或變數同時出現。把連續的 Constructor 算成一組、變數跟 wildcard 算成一組。Constructor 裡面再遞迴做下去。

    ```
    -- 節錄自未 commit 的 CollectData.hs
    _ | ... -- wildcard
  
    Just Nothing  -- constructor
    Just (Just a) -- constructor
    Just a        -- var
    Just Nothing
    Nothing
  
    a | ...
      | ...
      | ...
    ```
  
  * 過程中會生出新的變數，又不希望撞名，現在的做法是靠著我們的 lambda calculus 可以吃的字元集合比 Haskell 大，用 Haskell 中不合法的變數名稱，來避免撞名。
  * `fallback+` 是大撤退， `fallback-` 是小撤退。（註：更深層的 `fallback-` 會蓋掉上一層的，所以才得把最後的撤退先用 `fallback+` 記起來。**之後應補上程式碼**。）
  * 第一組的 `fallback-` 對應的 `in` （在最下面）是最上面的 `_ | ...` 失敗時會跑的 code 。
  * `fallback- = undefined` 是最後沒得撤退（爆炸）時的小撤退。
  * `x1-` 的 `-` 也是 Haskell 內不會有的 symbol 。
  * 有 `otherwise` 就用，沒有就 `fallback` 。（**應補上手動 desugar 的 code 與原本的 code 逐行比較的對應表**）
  * 遇到 guard `|` 的時候就會用到 `case` ， `case` 比較基本。（註：應該是指 Core 裡有 case 可以用）
  * 抓到東西時，一樣要把最後的撤退 `fallback+` 先存起來。（註：這邊的 `fallback+` 會 shadow 之前的吧？）
  * 現在先假設不同層可以用一樣的 `x1-` ，沒有證明過其正確性。
  * 原本有別的寫法，沒有用上 `fallback-` ，是把中間整段 code 都貼到用到同一個 `fallback-` 之處，但造成在試 `b` 的時候，會看到同一層的 `a` ，但是 Haskell 的設計是就算看到 `a` ，也是看到外面的 `a` 。（註：後來 AlexLu 講解時，又提了一次。）

    ```
    case e of
      a | a < 3 -> ...
      b | b > 3 -> ...
    ```

  * 現在講解的例子，也還沒有把 Primitive 的部分寫出來。應該會有 default ，現在沒有 default ，會比較浪費。（註：不確定比較浪費是不是指還得靠 `fallback+` 回到上一層這件事。）
  * 現在的寫法，先判斷了是不是 Just 後，失敗，再重試時得再判斷一次，有點浪費。（具體的例子是，先發現 Just Nothing ，失敗後，遇到 Just a ，又遇到 Just Nothing ，就不該再判斷一次。**應補上程式碼**）
  * LCamel 問到為什麼需要分類，是 programmer 自己不會分類嗎？ CindyLinz 表示 programmer 在 Haskell 中可以亂寫，我們要幫他分類，但是嘗試不同 patterns 的順序，要按照 programmer 寫的。
  * 「我現在很討厭新的 symbol 」， CindyLinz 表示像 view pattern 那種 extension 會生出新的 symbol 很麻煩。
  * CindyLinz 又表示之前寫 Perl 有用過現在這種（一層一層 shadow 的） `fallback` ，喜歡用哪種寫法，完全是看個性。很 script 思維。
  * AlexLu 表示他現在一個一個試，還沒有想過分組這樣的寫法。

# AlexLu

  * 很多例子來自 WIP 的 `Case.hs` 。（**commit 後應補上程式碼**）
  * 先把連續的 match 換成巢狀的。
  * 在 desugar 的過程中， AST 需要保持都是合法的 Haskell 程式嗎？ CindyLinz 表示他沒有那樣的潔癖，反正自己已經帶頭破壞了...。
  
  ```
  -- 從這樣
  case e of
    p1 -> m1
    p2 -> m2
    ...
  
  -- 變成這樣
  case e of
    p1 -> m1
    _  -> case e of
            p2 -> m2
            _  -> error "matching failed"
  ```
  
  * CindyLinz 表示我們的簡單版 Haskell 不能寫 wildcard ，但是 AlexLu 表示他有做。
  * Alex 提到他想像中的不合法 Haskell ，是指漏掉 case 時會用 `_` 當成漏掉的部分去塞，而這邊的 `_` 跟 Haskell 裡的意義不一樣。
  * 遞迴那邊還沒有想好，現在只做了一層。這邊的遞迴不是指比較深的 patterns ...（**不懂**，然後就接到下面的 ABC case 討論...）
  * （**繼續不懂**，ABC 那部份，沒做過完全跟不上...XDD）
  * 於是都還沒做 guard ，之後再生新的 case ，並複製貼上。 CindyLinz 表示複製貼上， symbol 會黏到。（註：前面講到看到 `a` 應該是外面的 `a` ，不是同一層的 `a` 那段。）
  
    ```
    case e of
      a | a < 3 -> ...
      b | b > 3 -> ...
    ```
    
  * 如果 local symbol table 做完，就可以 rename ，不用擔心這個問題。
  * AlexLu 的 desugar 是個 Monad ，有 global state 可以用。花了很多時間在研究 TH 要怎麼改。（**之後應補上 AlexLu 的程式碼**，並取一段明顯的例子出來。）
  * CindyLinz 表示 compile 最慢的一段是把變數名稱跟字串串起來哪段，本來用 `++` 很慢，改用 `<>` 有快一點點。
  * AlexLu 最後是重寫，把 AST 拿出來[變成 String ](https://github.com/op8867555/BYOHC-transpiler/blob/1a5b5e7e6da30825ccd757370297f3c5e321d41e/utils/gen-template/Lib.hs#L36)。

    ```
    stringE . HSE.prettyPrint $
        hModule emptySrcLoc "Desugar.Pass" imports decls
    ```

  * Just 又 Just 的狀況應該還是拆成多層的，或者把 `Just (Just a)` 變成 `Just al@(Just a)` 。
  * 「才兩個人就已經接不起來了」， CindyLinz 表示大家的程式沒辦法混用，而且每個人的資料結構還會一直改...。如果混用的價值不大，那可以用其他語言寫 desugar 也沒關係。
  * LCamel 表示需要 parse 過的 AST ， CindyLinz 表示可以用 [src-exts](https://hackage.haskell.org/package/haskell-src-exts) `show` 出來的字串，給 C 啊 Python parse 。
  * 「有點想妥協了」， CindyLinz 表示可能得先手動寫一次，才能明白怎麼收斂。

## Pattern Matching

### @

  ```
  case Just (Just 3) of
    Just (b @ (Just a)) -> ...
  ```

  * `b` 就是 `Just a` 的別名，不影響 match 看的順序。可以避免把東西解開再建回來。

### ! (bang pattern)

  ```
  -- 有效率版，吃一個就加一個，使用 constant 記憶體
  sum ls = go 0 where
    go acc [] = acc
    go !acc (a:as) = go (acc + a) as
    
  -- 一般版，在記憶體中會展開剩下的 sum as
  sum [] = 0
  sum (a:as) = a + sum as
  
  -- 另外一種用法，和上面不同。表示在做到 in 的時候，就算裡面沒有用到 a ，也要把 a evaluate 出來。
  let
    !a = f 123
  in
    ...
  ```

  * 要 match 這個 pattern 時，如果遇到變數前面有個 `!` ，就表示這個變數也要先 evaluate 到 WHNF ，好減少 thunk 數量，增加效率。
  * GHC 中 Primitive 都要求要加 `!` ， Primitive 沒有 thunk ，不加會給 compile error 。

### ~ (irrefutable pattern)

  ```
  g ~(Just a) = ...
  ```

  * 正常 g 被呼叫時，會去看裡面是不是 Just ，用 `~` 則表示要 GHC 相信你，這邊就是 Just ，現在不用看。要是進去發現不是 Just 就會爆炸。
  * 常見於 [`mfix`](https://wiki.haskell.org/MonadFix) ，會把 return 的東西再餵給你。
  
  ```
  mfix $ \~(a, b) -> do
    (a', b') <- (b, a)
    return (a', b')
  ```
  
  * 或者遇到要看狀況從 Array 拿出不定數量的東西時可以用上：
  
  ```
  let
    x1 : ~(x2 : ~(x3 : x4 : x5 : [])) = [...]
  ```
  
  * 「不見得是好的 coding style 」

# 雜談：大家卡在麼地方？

  * CindyLinz 表示像 AST 有很多 Constructors 就是一種障礙。
  * 如果沒有時間的話，可以一週安排一小段時間，例如三個小時之類的。看是連續的三小時或是分開的都好，較建議連續的，不然時間都花在暖機。
  * LCamel 表示很久沒有想，像是 WHNF ，雖然寫出來可以跑，但不知道為什麼。CindyLinz 表示需要一個巨大的暖機 XD
  * LCamel 提到現在停在 checkout Haskell.js 到 show 可以跑。
  * LCamel 表示不明白 desugar 後， JS 的成分有多少？ CindyLinz 表示 roadmap 第三段（註：讓 Lambda Calculus 在你的世界裡飛 -- 實作 compiler），就會直接生出很多 JS ，那時會像 petercommand 講的那樣（STG）。現在 interpreter 就會是 lambda 加上一點點的 JS 。 AlexLu 的實作的話， lambda 裡面沒有 python （沒用到 switch ，而是生一段用到 `==` 的 Haskell `if ... else ...`），但 CindyLinz 的 lambda 裡面會有些 JS 。
  * CindyLinz 展示了她的 trans 後的結果給大家看。 Primitive 裡面是塞 JS 進去。（註：不確定是不是指 `['dat', String.fromCharCode(44)]` 。）
  * AlexLu 表示 Haskell report 有規定 semantic ，但是沒有規定要怎麼實作。
  * caasi 表示 SPJ 寫的 [The Implementation of Functional Programming Languages](https://news.ycombinator.com/item?id=10609960) 有提到 STG machine 的前身， G-machine 的由來和初衷。（十三章介紹 supercombinator ，十七章介紹 GC ， 十八章開始的 Part III 則講 G-machine ） 
  * STG 這名字超爛的， S 跟 T 是沒有 S （Spineless）跟沒有 T （Tagless）...。
  * CindyLinz 繼續解釋他的 env 的用途。如果整個 top level 的定義都在 Y combinator 裡面的話，寫 primitive functions 會用不到，但在 env 裡面就可以隨便用。
  * Shuk 提到沒有時間看資料，不懂又要找影片或資料繼續看，很吃力 QQ
  * Gitter 太冷清是因為大家 IM 太多了，不一定有開。
  * CindyLinz 表示實作基本語法後，「彷彿」就可以實作 Haskell 了。甚至連 `data` 跟 `case` 都可以先不做 。當它的執行結果跟 runghc 的結果一樣，感覺很棒。可是得想像程式在跑的時候會有怎樣的結構，還有結構之間怎麼互動。
  * caasih 表示把 CindyLinz 的 code 看完後會看 AlexLu 的，但同時會開始看 SPJ 的書，從 G-machine 開始做，不再死死追 code 。
  * Shuk 表示 Linux 的 FHS 就已經多到看不完了。
  * a127a127 表示自己的進度還停在第二次，等公司搬完家，繼續追進度。
  * 安安（嘉敏）表示他直接做 typed lambda calculus ，再來是 System F ，然後 System Fω 。
  * 安安開了[程式語言與函數式編程](https://www.facebook.com/groups/1678688139051215/)社團。
  * LCamel 在 1/16 會在 TWJUG 講 [(How to Write a (Lisp) Interpreter (in Java))](http://twjug.kktix.cc/events/twjug201601) 。 
  * LCamel 和 CindyLinz 又以春夏秋冬為例，解釋了一遍 Scott encoding 。 Haskell 裡面的 `data` 都可以這樣做。
  * LCamel 講到 Natural number 在 lambda 中因為沒有 type ，就沒有看到明顯的 pair 。
  
  ```
  -- 沒有洞（slot）
  \is-z \is-s is-z
  
  -- 有洞
  \n \is-z \is-s is-z n
  ```
  
# 下次聚會時間

2016.01.28(四)
