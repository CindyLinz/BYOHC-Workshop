# 本次目標

  * demo 成果 / 半成品

    + Lambda Interpreter

    + pattern matching 半成品

# 雜談

  * CindyLinz 提到今天會有屍體可以 demo 。等等會 push draft 。

# CindyLinz

  * 本來的目標是要作 [case\_reorder.hs][case_reorder] ，發現還沒做字串（[case\_reorder2.hs][case_reorder2]），會沒辦法用，所以做了[簡單版][reorder_string]。

    ```
    -- 以下是在 workshop-2016.1.14.md 中誤記為出自 CollectData.hs 的內容
    _ | False -> putStrLn "Any"


    Just Nothing | False -> putStrLn "Just Nothing False"
    Just (Just (Pair a c)) | a <= 3 -> putStrLn "Just (Just (Pair a c)) | a <= 3"
    Just (Just (Pair b _)) | b <= 3 -> putStrLn "Just (Just (Pair b _)) | b <= 3"
    Just (Just (Pair _ 4)) -> putStrLn "Just (Just (Pair _ 4))"

    Just a | False -> putStrLn "Just a | False"

    Just Nothing | True -> putStrLn "Just Nothing True"

    Nothing -> putStrLn "Nothing"


    a | False -> putStrLn "a all False"
      | True -> putStrLn "a all True"
      | otherwise -> putStrLn "a all otherwise"
    ```

  * otherwise 也還沒做，這邊是先寫 True 。

  * 提了一下之前的目標，也就是上次那個[手工 desugar 的內容][desugar_manually]。

    ```
    let
      fallback- = undefined
      x1- = Just (Just (Pair 3 5))
    in
      let
        fallback+ = fallback-
      in
        let
          fallback- =
            let
              fallback- =
                let
                  fallback- = fallback+
                in
                  let
                    a = x1-
                  in
                    let
                      fallback+ = fallback-
                    in
                      let
                        fallback- =
                          let
                            fallback- =
                              let
                                fallback- = fallback+
                              in
                                putStrLn "a all otherwise"
                          in
                            case True of
                              False -> fallback-
                              True -> putStrLn "a all True"
                      in
                        case False of
                          False -> fallback-
                          True -> putStrLn "a all False"
    -- 後略
    ```

  * 在做 desugar 時無法做 IO ，所以現在要看的話用 error 把他[噴出去][error]。要跑就用下面那個（`c`），要看就用上面那個（`error`） 。

    ```
    in
      error $ "\n\n\n" ++ show (forgetL d) ++ "\n\n\n" ++ show (forgetL c) ++ "\n\n\n" ++ prettyPrint c
      --c
    ```

  * 第一步是把他變成我[自己的資料結構][OrderedCase]，第二步是是把那個資料結構[變成 code ][orderedCaseToExp]。

  * js 有生出來，但是讓 node.js 跑沒有東西出來，很奇怪。顯然是哪個 case 有問題。

  * 錯誤輸出時除了 [Haskell.Src.Exts][haskell_src_exts] 的結構外，也噴了 prettyPrint 版。

  * 「prettyPrint 其實也不是很 pretty 啦。」

  * 有些已知 bug ，但（似乎）不是無法輸出的原因。

  * `Just (Just ...` 好像被拆開了，還在找原因。（幾個小時後 CindyLinz [修正了這個問題][406d3be]）

  * pattern matching 一層層進去時，只有一個 `x` 時沒關係，但是有 `x1`, `x2` 時還是會打架。

  * favonia 聯想到，也許可以看看 SML 是怎麼做的。

  * AlexLu 之前讀 report ，說是一行行做的。

  * [`rhsToExp`][rhsToExp] 那邊是「亂寫」（沒有做自己的資料結構）的 XD

  * 訂資料結構就像是把自己的思緒（整理得）比較清楚一點。

  * 覺得麻煩的還是那個 `l` ，出來的數量不一樣。

  * [`AltPartial`][AltPartial] 現在是錯的，在兩個洞以上會有問題。

  * 在文件查 [`Alt l`][Alt_l] 就可以查到。

  * 講解 [`eatCons`][eatCons] 與下面使用 `AltPartial` 的例子。

  * `Maybe (Binds l)` 就是那個 `where` ，在最內層要生 `rhs` 時可以[一起處理掉][rhs]。

  * 這次的寫法像是在寫 script ，所以想介紹 Debug.Trace 這個 lib ，在 base 中就有。

    + [`traceShowId`][traceShowId]

    + [`traceShow`][traceShow]

    + [`trace`][trace]

  * CindyLinz 之前寫過 [NoTrace][NoTrace] 。

  * 「對從小學 Haskell 的人可能沒有用，但對從小學 Perl 的很有用。」

  * `prettyPrint` 在某種條件上才能印，開發時得加上其他 context ，等開發完還要拿掉。

[case_reorder]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/sample/case_reorder.hs
[case_reorder2]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/sample/case_reorder2.hs
[reorder_string]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/sample/case_reorder2.hs#L14
[desugar_manually]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/sample/case_reorder.hs#L24
[error]: https://github.com/CindyLinz/Haskell.js/blob/0768250077a56ffe572275867283a28ecd1a0627/trans/src/Desugar/CaseReorder.hs#L349
[OrderedCase]: https://github.com/CindyLinz/Haskell.js/blob/0768250077a56ffe572275867283a28ecd1a0627/trans/src/Desugar/CaseReorder.hs#L12
[orderedCaseToExp]: https://github.com/CindyLinz/Haskell.js/blob/0768250077a56ffe572275867283a28ecd1a0627/trans/src/Desugar/CaseReorder.hs#L139
[haskell_src_exts]: https://hackage.haskell.org/package/haskell-src-exts
[NoTrace]: https://github.com/CindyLinz/Haskell-NoTrace
[406d3be]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/src/DeCaseReorder.hs#L107
[rhsToExp]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/src/DeCaseReorder.hs#L165
[AltPartial]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/src/DeCaseReorder.hs#L55
[Alt_l]: https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Syntax.html#t:Alt
[eatCons]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/src/DeCaseReorder.hs#L104
[rhs]: https://github.com/CindyLinz/Haskell.js/blob/406d3be2fbc098a4f63d7b4a421ec30094f0405a/trans/src/DeCaseReorder.hs#L189
[traceShowId]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Debug-Trace.html#v:traceShowId
[traceShow]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Debug-Trace.html#v:traceShow
[trace]: http://hackage.haskell.org/package/base-4.8.2.0/docs/Debug-Trace.html#v:trace

# AlexLu

  * 這次做了 [renamer][Rename.hs] 。

  * 做 AST 轉換時，變數名稱會一直衝到。

  * [`--output-level Desugared`][outputLevel] 參數來輸出 desugar 的結果。

  * （沒寫 `module Main where` 時） top level 的 `T` 變成 `Main.T` ，實際上是要用 module name 。

  * Lambda 產生的變數，則在後面加上遞增的數字，保證不會撞名。

  * 做完這個後就[開始作 case 的 reorder 跟補沒有出現的 case ][1f41cea]。

  * 會去找這個 case 中第一個出現的 WildCard ，當成 fallback 。（**應補上行數**

  * 沒有 WildCard 的話，會用一個內建的（[`defaultFallbackE`][defaultFallbackE]） `strE l "matching failed"` 。

  * 現在還在做把上一層的 nested type 拆開的動作。

  * CindyLinz 問到 primitives 有沒有做 boxed 跟 unboxed ， AlexLu 覺得那做起來相對輕鬆，所以還沒做。

  * CindyLinz 表示想把「是 literal 的」變成一個 group ，「不是的」放另外一個 group 。

  * AlexLu 表示有打算把 primitives 都轉成 `I# 4#` 這種形式。

  * 至少它會動，會動的滿足感真的很大 :D

[Rename.hs]: https://github.com/op8867555/BYOHC-transpiler/blob/441736d27a4e1e3b80afb54f65b485e62cfbd738/src/Desugar/Rename/Rename.hs
[outputLevel]: https://github.com/op8867555/BYOHC-transpiler/blob/2e992b851966f626a94232b528ec2520679ecbec/app/Main.hs#L47
[1f41cea]: https://github.com/op8867555/BYOHC-transpiler/commit/1f41ceabd2d0b454265df2c4dc290f7bc5864824
[defaultFallbackE]: https://github.com/op8867555/BYOHC-transpiler/blob/1f41ceabd2d0b454265df2c4dc290f7bc5864824/src/Desugar/Case/AltCompletion.hs#L482

# a127a127

  * （interpreter）一開始沒有管 normal form ， weak normal form 的問題，結果在 [print][print_ir] 時還要另外處理。

  * 在 [`ast_to_ir`][ast_to_ir] 會先把 Lexical scoping 處理掉，在 environment 中記有哪些 symbol 。

    <img src="https://raw.githubusercontent.com/CindyLinz/BYOHC-Workshop/master/workshop-2016.1.28/IMG_0380.jpg" width="245" height="326" />

  * 從變數直接指到 parse 時看到的 lambda 的 name 。 scope 在第一次 parse 時就好了，沒有撞名的問題。

  * 跟一開始 AlexLu 找到的 de Bruijn Index 是一樣的，只是是 global 的 memory based index ， apply 後變成往上指的不用修，但是裡面的要修。 de Bruijn Index 則是 local 的（ apply 後要改往上指的，裡面的不用修）。

  * 然後 a127a127 跟 CindyLinz 一起解釋了一下 de Bruijn Index 。

  * favonia 表示從 1 開始是不能接受的 XDD

  * CindyLinz 表示學 agda 時，聽到自然數是從 0 開始也很奇怪。

  * favonia 表示這叫 [explicit subtitution][explicit_sub] ， well known ，可以照抄。

  * favonia 表示， debug 時可以把 context 記住（從最上面下來幾層），最後檢查時，加起來看看是不是一樣的數字。

  * 是不是 lazy ，可以[傳一個變數進來][lazy]就好了。

[print_ir]: https://github.com/a127a127/byohc/blob/3e4bee871937d8ac2ca572d89a2e4e38f30091af/main.coffee#L11
[ast_to_ir]: https://github.com/a127a127/byohc/blob/3e4bee871937d8ac2ca572d89a2e4e38f30091af/byohc.coffee#L5
[explicit_sub]: https://en.wikipedia.org/wiki/Explicit_substitution
[lazy]: https://github.com/a127a127/byohc/blob/3e4bee871937d8ac2ca572d89a2e4e38f30091af/byohc.coffee#L43

# favonia

  * favonia 表示可以 demo 大家去哪裡找資料，很多問題大家都討論過，有 working 的 solution :D

  * data constructor 要怎麼解、怎麼去 binding ...。

  * [SMLFamily/The-Definition-of-Standard-ML-Revised][SML] 的 Atomic Patterns 。

  * favonia 開始解釋 judgements 。是一套表示邏輯推論系統的方法。下面是結論，上面是很多前提。

  * 證明就是用這些 rules 組合出來的一棵大樹。

  * favonia 舉了例子。

  * 可以挖洞，讓電腦去跟 rules 比較，一層一層找上去。把規則寫下來，指明那些是 inputs ，哪些是 outputs ，不用說明是加減也沒關係。

    <img src="https://raw.githubusercontent.com/CindyLinz/BYOHC-Workshop/master/workshop-2016.1.28/IMG_0382.jpg" width="245" height="326" />

  * mode, logic programming 的 mode 。然後 favonia 稍微介紹了一下 Prolog 。

  * "total"

  * 有些很無聊但是程式不能不寫的狀況。

  * CindyLinz 問到 SML 和 ocaml 的關係， favonia 表示 ocaml 加了 object 的部分，但在一百公尺外看，他們是一樣的東西，但是魔鬼都在細節裡面。

  * favonia 表示這些 rules 會那麼複雜，是都在處理 module 的關係。

  * CindyLinz 表示 module 可以塞參數，變成類似樣板的東西。

  * CindyLinz 又想起剛剛提過的 prettyPrint 的問題， Annotated 的 l 可能是不能印的，得手動讓它可以印。

    ```
    E, v |- _ => {}
    ^^^^   ^^^  ^^^^
    |      pattern |
    環境(input)    binding(output)
    ```

[SML]: https://github.com/SMLFamily/The-Definition-of-Standard-ML-Revised

# 雜談

  * favonia 表示 type checking 是很崩潰的地方。CindyLinz 表示還沒做到 type checking 。

  * CindyLinz 宣傳了一下 [Funth #35][Funth_35] 。出自 [Purely Functional Data Structures][PFDS] 的 amortized queue 實作。在一般語言中，這種實作速度不穩定，但是平均下來是 O(1) 的。在 functional language 裡面要用些技巧來避免很慢的 case 。是個買保險的概念。

  * CindyLinz 提到 [knockout.js][knockout] 這個 framework 也是 reactive 的。有些可能會變動、或是反應的節點， library 就要設計該怎麼處理。然後介紹 jQuery 的 `begin` 和 `end` 就很好用，但其實語意不是 OOP ，是種 eDSL 。接著重新介紹了一下整個 Workshop 的目標給 ssuio 聽，包含 Workshop 三階段的目的，為什麼要繞這樣的遠路，還有第二階段給自己的限制，不要用到太多 Haskell 。

  * 第三階段的 runtime 雖然還是 interpreter ，但會更貼近目標環境。 AlexLu 說中介語言就變得像 bytecode/IR 。

  * LCamel 想定義一個有標準的中介語言 L ，讓大家可以共用。

  * CindyLinz 表示加了些 native 函數後，大家的 L 就變得不一樣了。

  * AlexLu 表示他的副作用只在 interpreter 中。

  * AlexLu 表示他的 global function 是用 Y 包起來的。

  * LCamel 開始解釋他想怎麼定義共用的 primitives ，提到 ECMAScript 的 spec 會定義一些假想的 function ，寫明操作起來要什麼感覺，但是不講實作。希望可以訂出「看到一個不認識的 variable 時，得知道他是 lambda 或不是 lambda 」，這樣 interpreter 在執行時，就知道該不該特別做什麼處理。

  * 「怎麼會有一個 undefined 在裡面？」CindyLinz 介紹了一種 thunk 算完丟掉比較好（因為記憶體不夠）的例子。

    ```
    a = [1..99999999999]
    do
      let
        len = length a
        s = sum a
        putStr show len
        putStr show s
    ```

[Funth_35]: http://www.meetup.com/Functional-Thursday/events/228168270/
[PFDS]: https://www.cs.cmu.edu/~rwh/theses/okasaki.pdf
[knockout]: http://knockoutjs.com/

# 下次聚會時間

  2016.02.18(四)
