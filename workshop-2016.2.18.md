# 本次目標

  * Haskell 部分語法介紹
  
    + import / export 語法與語意

  * demo 成果 / 半成品
  
    + Lambda Interpreter

    + pattern matching

# 雜談

  * AlexLu, LCamel 一行人不知為何被卡在門外...。
  
  * 今天人超多。
  
# CindyLinz

  * CaseReorder 的排序 bug 已經除掉了。
  
  * 學 AlexLu 加參數看要不要噴出 debug 訊息。
  
  * 現在也可以 match String 。也能用 String 了。（[String.hs][String.hs]）
  
  * Tuple 類似，塞法不一樣。（[Tuple.hs][Tuple.hs]）
  
  * 做了 [SymbolTable][SymbolTable.hs] 。
  
  * 很多地方用到 QName ，其中 [Special][Special] 收了一堆...（可以配著 Haskell.Src.Exts 的 [SpecialCon][SpecialCon] 一起看），在 SymbolTable 做手腳。做了可以 query （`queryDataCon`）的一種作法。
  
    ```Haskell
    Special _ spc -> case spc of
      UnitCon _ -> Just
        ( 0
        , DataShape
          { dataLoc = dummySrcSpanInfo
          , dataName = Special () (UnitCon ())
          , dataCons = [(Special () (UnitCon ()), 0, M.empty)]
          }
        )
      ListCon _ -> Just
        ( 0
        , listShape
        )
      FunCon _ -> Nothing
      TupleCon _ boxed size -> Just
        ( 0
        , DataShape
          { dataLoc = dummySrcSpanInfo
          , dataName = Special () (TupleCon () boxed size)
          , dataCons = [(Special () (TupleCon () boxed size), size, M.empty)]
          }
        )
      Cons _ -> Just
        ( 1
        , listShape
        )
      UnboxedSingleCon _ -> Just
        ( 0
        , DataShape
          { dataLoc = dummySrcSpanInfo
          , dataName = Special () (UnboxedSingleCon ())
          , dataCons = [(Special () (UnboxedSingleCon ()), 1, M.empty)]
          }
        )
    ```
  
  * import 和 export 也做了一次。
  
    ```Haskell
    import Lib -- 可以用
    import Lib as X -- 全部拉進來，又多個 X
    import qualified Lib -- 不能直接寫
    import qualified Lib as X -- 不能直接寫，有 X
    ```
  
  * reexport 沒有做。

  * collectData 會把 top level 的都讀進來， export 函數才挑出要 export 的。

  * [`queryDataCon`][queryDataCon] 收了別人 export 的還有自己的。

  * 還沒有用 AlexLu 那個 Monad 的作法。

  * 上次遇到的 [bug][reorder-case-bug] 出在生 code 的地方，做 case 的時候遇到...，本來是不能吃有 prefix 的。

  * 接下來想做的是 let bindings ，現在有做，但等號左邊都是變數，不能有 pattern 。

  * AlexLu 表示把 pattern guard 什麼都寫了。

  * 覺得把 pattern 都搞定後，就能作一些小的，小東西做起來很有成就感。

  [String.hs]: https://github.com/CindyLinz/Haskell.js/blob/237c780351740c06b99a62f90d7b5e752e15c855/trans/src/Desugar/String.hs
  [Tuple.hs]: https://github.com/CindyLinz/Haskell.js/blob/237c780351740c06b99a62f90d7b5e752e15c855/trans/src/Desugar/Tuple.hs
  [SymbolTable.hs]: https://github.com/CindyLinz/Haskell.js/blob/237c780351740c06b99a62f90d7b5e752e15c855/trans/src/SymbolTable.hs
  [Special]: https://github.com/CindyLinz/Haskell.js/blob/237c780351740c06b99a62f90d7b5e752e15c855/trans/src/SymbolTable.hs#L86
  [SpecialCon]: https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Syntax.html#t:SpecialCon
  [queryDataCon]: https://github.com/CindyLinz/Haskell.js/blob/237c780351740c06b99a62f90d7b5e752e15c855/trans/src/SymbolTable.hs#L42
  [reorder-case-bug]: https://github.com/CindyLinz/Haskell.js/commit/cf3158f45fb6d6f633f3ef5bafafeeecd13d339e#diff-0210021cf846d427b82f56fc5ecbbe2dR241

# AlexLu

  * ExpandPattern.hs 會把 nested 的 patterns [展開][expand]。
  
  ```Haskell
  Just (Just a) _ -- 這種
  ```
  
  * 把每一次的 match 都取新名字，放 let 裡面。

  * 還是有遇到沒有 type 就沒辦法判定，現在 pattern 一定要有 constructor 。遇到就會去查表。

  * 每次都拆成有 match 到和沒有 match 到，沒有就回傳一個 fallback 回來。現在想要理解他的時候，已經不知道要怎麼處理了。（[`expandRhs`][expandRhs]）

  * 後來發現 pattern guard 在 2015 年已經是標準了。

  * 解釋 543 行附近是怎麼[展開成 lambda 的][expand-lambda]。

  * 遇到 constructor 時，裡面會有小的，再一一展開。

  * pattern guard 和 pattern matching 很像。
  
  * CindyLinz 問道有 pattern 的，複數個 let ，實作沒有順序，要怎麼辦？
  
  * 「AST 碰久了，就會（把 let ）變大寫。」
  
    ```Haskell
    let
      (a, b) = (1, 2)
      (c, d) = undefined
    ```
  
  * CindyLinz 表示沒有用到 c, d 的話不會壞掉。
  
  * CindyLinz 現在的想法是：
  
    ```
    let
      Just (a , Just b) = Just (1, Just 2)
  
    -- 會變成
  
    a-b- =
      case Just (1, Just 2) of
        Just (a, Just b) -> (a, b)
        
    a = (\(a, b) -> a) a-b-
    b = (\(a, b) -> b) a-b-
    ```
  
  * CindyLinz 表示還是會浪費一個解 Tuple ， Alex 質疑。結論是那是價值觀問題 XD
  
  * 現在 let 是直接傳給下一家，沒有解決任何問題。
  
  * [Generator][Generator]

    * CindyLinz 補充說明： generator 是 Guard 語法裡面的 `Just abc <- xxdd` 這樣的東東，可能會寫成 `let a | 2 < 3, Just abc <- Just 456 = abc` 這樣，然後會得到 `a = 456` 。
  
  * 也是倒著來，最後一個寫在最前面。（**應補上部分從 [example/PatternGuard.hs][PatternGuard.hs] 生出的結果**）

  * 會避開已經用的變數，如果已經有加底線，會再加底線。

  * unqualified 會變成 qualified 的，會很危險。

  * 會[加上][transQName] `.` 變得很長一串。

  * 怕已經過了 desugar 的 case 了，上面的作法是為了避免這個問題。（**註：讀完 code 應補上說明**）
  
  * CindyLinz 表示 reexport 沒做，是因為得一路往上反查 module name 。
  
  * CindyLinz 表示我們 data 都會變函數。
  
  * AlexLu 看了 GHC 怎麼做 [FFI][FFI] 。
  
  * 現在的實作還沒做出 type 。還在想 interface 要不要包含 type 資訊。
  
    ```Haskell
    data F :: * -> * where
      A :: b -> F a
    ```
  
  * AlexLu 表示還不知道怎麼處理上面那種程式碼。
  
  * 先 desugar 再 type check 再 desugar ，或者比較傳統，先做 type check 。（註：這裡的傳統大概是指 GHC ）
  
  * 現在 CindyLinz 是先把所有檔案中的 top level 都找一次。使用到那個 symbol 時才去找。從不同 module import 不同的東西，但沒用到就沒關係。或者可以重複就刪掉。
  
  * CindyLinz 對 pattern matching 會動，而且是巢狀的感到開心。
  
  * AlexLu 可能會把 String 從 List 換成 built-in 的吧。
  
  * 可以 match String 。把 String 換成 List ，再把 List 換名字（[Lit.hs][Lit.hs]）。
  
  * CindyLinz 好奇 [PrimString][PrimString] 是什麼東西？不知道什麼時候會用到。

  * 最近都在跟 module 奮戰，現在的想法是給 search path 還有 main 在哪裡。沒有 GHC 那麼聰明，用到才爬。希望未來可以用 lazy 幹掉，有問題就再看看。
  
  * 把每一個有匯出的 data constructor 跟 function 都蒐集起來。都搜刮完才知道要怎麼生 code ，這時候應該任意生都可以。
  
  * 又改回以前 import 的辦法，放棄了之前處理遞迴 import 的做法，在 interpreter 那邊處理。
  
  * CindyLinz 表示 GHC 還[有 module 同名但是 package 不一樣][package-imports]。 AlexLu 表示（還好）現在沒有 package 。
  
    ```Haskell
    import "network" Network.Socket
    ```
  
  [expand]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Case/ExpandPattern.hs#L527
  [expandRhs]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Case/ExpandPattern.hs#L478
  [expand-lambda]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Case/ExpandPattern.hs#L543
  [Generator]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Case/ExpandPattern.hs#L511
  [PatternGuard.hs]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/example/PatternGuard.hs
  [transQName]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Rename/Rename.hs#L1167
  [FFI]: https://wiki.haskell.org/Foreign_Function_Interface
  [Lit.hs]: https://github.com/op8867555/BYOHC-transpiler/blob/dc6e07dd4c914ac7d0886d13b78e91cf0216f58b/src/Desugar/Lit.hs
  [PrimString]: https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Syntax.html#t:Literal
  [package-imports]: https://downloads.haskell.org/~ghc/7.2.2/docs/html/users_guide/syntax-extns.html#package-imports

# 雜談

  * CindyLinz 表示不知道 type 的話無法做 [`!`][bang] 。
  
  * Core 的 case 是 strict 的，不知道 type 不行， Haskell 的不知道 type 沒關係。
  
  * pattern matching 裡的 guard 會帶來很多麻煩。

    ```Haskell
    let
      Just (a , Just b) = Just (1, Just 2)
                  | ... = ...
                  | ... = ...
    ```
  
  * BGM: Moon River
  
  * apua 第一次來，主要寫 python 。
  
  * apua 現在只看了 LYaH 。好奇是用什麼去執行這些語言（指 untyped lambda calculus）？
  
  * apua 好奇從那邊查 Haskell 的語法， CindyLinz 表示用了 [Haskell.Src.Exts][haskell-src-exts] 這個 parser 。

  * CindyLinz 表示縮排讓...無法處理 context free grammar 。只要最後我們的程式可以吃 Haskell.Src.Exts 自己的程式碼，就能用（bootstrap）。
  
  * 如果想了解 Core 可以配[投影片][funth-34-pdf]聽 petercommand 的[演講][funth-34]。（影片的螢幕一片白 XD）
  
  * CindyLinz 介紹了 Core 中的 case 是 strict 的。 case 裡面有 pattern 的話，是不能有兩層以上的。會常講到 Core 是因為 GHC 是個確定能用的 Haskell （註： Core 是 GHC 裡的東西 ）。
  
  * 討論了 GHCJS 生出來 js 和本來 Haskell 長得像不像。

  * CindyLinz 表示很多 Haskell 很炫的東西，沒有 lazy 寫不出來。
  
  * 像是 [Löb and möb: strange loops in Haskell][lob-and-mob] 神奇地處理了會互相連動的東西。順著他的文章看不會很難 ☆ 至於他為什麼會想到這個，就不知道了。
  
  * apua 表示 readable 不見了 XD
  
  * CindyLinz 又解釋了一下此 Workshop 的初衷，表示對 GHC 有些不滿意。再舉了 Bool （在 64-bit 機器）要 8-byte 這例子。
  
  * 繼續解釋 lambda calculus 。並提到我們自己用的最簡單的 Haskell 長得跟 Core 很像。
  
  * m157q 也是第一次來，跟大家說叫自己 Q 就可以了。現在在台北工作 :D
  
  * CindyLinz 表示 lambda 那段還是可以講，不然差距很大很無聊， LCamel 表示可以分兩班 :D
  
  * LCamel 說明自己重新思考了 lambda 怎麼 apply ，希望把 algorithm 分離出來。會先問是不是一個 apply （application） ，再問下面是不是一個 lambda 。
  
  * LCamel 表示還不知道 怎麼做 recursive let ， Cindy 舉了 [2015.11.12][workshop-2015.11.12.md] 的筆記當例子。在筆記中取的名字叫 gen(generator) 。（註：和 Haskell.Src.Exts 中的 Generator 應該是完全不同的東西？）

    ```
    (Y \gen \tuple
      (\even \odd tuple
        (\n native-int-switch[0 => True, _ => odd (- n 1)])
        (\n native-int-switch[0 => False, _ => even (- n 1)])
      )
        (gen \even \odd even)
        (gen \even \odd odd)
    )(\even \odd
      even 5
    )
    ```

  * LCamel 繼續討論中介語言的範圍。
  
  * LCamel 討論 recursive let 能不能不用 Y combinator 做？ CindyLinz 表示現在還是用 Y 做，要先數好有幾個。
  
  * CindyLinz 表示用 symbol table 抓起來比較好用，不然外面看不到 Y 裡面的東西。譬如 native 的東西要共用而不是人工 inline 的話。
  
  * AlexLu 表示只有 top level 可以不用到 Y 。裡面還是要用到。
  
  * CindyLinz 問到接下來怎麼樣好？要不要先讀一些東西來分享？像是 type checking 之類的。現在還不知道那篇最好讀，但知道有哪些可以讀。
  
  * AlexLu 表示想把之前找到的 [Typing Haskell in Haskell][typing-haskell-in-haskell] 直接翻成 AST ，但他做的範圍很小，是一個變數的。「感覺起來很精簡，但是很難懂。」
  
    * 聚會結束後並補充：看它在 hackage 上的[實作][thih]其實有提供 Multiparameter Type Classes 。
  
  * CindyLinz 提到上次 [favonia][favonia] 建議讀 ML 的文件，但是 ML 沒有 type class 。我們還是要做 type class 。
  
  * LCamel 好奇能不能轉成不用 runtime 的 lazy 語言。 CindyLinz 表示得讓 function 有 cache 的功能，還要知道那時沒有人用，得 expire 。
  
  * AlexLu 提到 function 一層層執行進去，外面的都要用到，還是不知道那時該丟掉。
  
  * 再討論後，發現 LCamel 想要的可能還是個翻譯完能跟 Haskell 一一對應的東西。
  
  * Noah 也是第一次來。自學了一些 Java 。對 Functional Programming 有興趣。
  
  * a127 表示把要用的 environment 傳給 Y 就好了， CindyLinz 表示會變成 dynamic scoping ，很危險。
  
  * AlexLu 表示 [purescript][FFI-tips] 中，如果 FFI 需要的話，把要用的名字都傳給它。要 Maybe 的話，會建議你傳 Just 跟 Nothing 過去，這樣不知道裡面的實作也沒關係。
  
  * 「去糖的 Haskell 就當成標準？」
  
  * 需要 `Y*` 嗎？ AlexLu 查到 [现代魔法构成论：多变量不动点组合子][Y-star] 。
  
  * petercommand 之前在 IRC 提過： [Many faces of the fixed-point combinator][many-faces] 。
  
  [bang]: https://github.com/CindyLinz/BYOHC-Workshop/blob/b842a53deff9ed30c4778beaf4cd1dd11cbfd091/workshop-2016.1.14.md#-bang-pattern
  [haskell-src-exts]: https://hackage.haskell.org/package/haskell-src-exts
  [funth-34]: https://www.youtube.com/watch?v=OUEWSkUStDc
  [funth-34-pdf]: https://github.com/petercommand/Funtional-Thursday-Talk-Haskell-Core-Stg/blob/master/haskell-core-stg.pdf
  [lob-and-mob]: https://github.com/quchen/articles/blob/master/loeb-moeb.md
  [workshop-2015.11.12.md]: https://github.com/CindyLinz/BYOHC-Workshop/blob/a0ce2a2b344af38e7db0b7ad289dcb1232145780/workshop-2015.11.12.md#haskell-基本語法與-lambda-程式的對應
  [typing-haskell-in-haskell]: https://gist.github.com/chrisdone/0075a16b32bfd4f62b7b
  [thih]: https://hackage.haskell.org/package/thih
  [favonia]: https://github.com/CindyLinz/BYOHC-Workshop/blob/e4058da0dc5cbf43d21a49f17e890160765017fa/workshop-2016.1.28.md#favonia
  [FFI-tips]: https://github.com/purescript/purescript/wiki/FFI-tips
  [Y-star]: http://typeof.net/2014/m/formation-of-modern-magic--poly-variadic-fixed-point-combinator.html
  [many-faces]: http://okmij.org/ftp/Computation/fixed-point-combinators.html

# 下次聚會時間

  2016.03.10(四)