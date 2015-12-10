CindyLinz: 剛開始學的時候會卡住，慘的是，連為什麼卡住都不知道。

# 本次目標

  * 寫 desugar: where, if..then..else, [1,3,2,4,5]
  * 繼續自修 type check/inference 的資料

# AlexLu

  * Alex: 這週做了 [FFI](https://github.com/op8867555/BYOHC-transpiler/blob/2136f167aa1a7e5877b29954a27f74525d965c07/src/Trans.hs#L274) 模組， python 寫的 function 會拿到 de Bruijn indexed AST ，傳回 AST 。（待補 `ffi_test.hs`）
  * CindyLinz: Haskell 的 FFI ，在 C 中看到的是 C 的 data type ，在 Haskell 看到的是 Haskell 的 data type 。如果兩邊看到的都是一樣的資料結構，不會有 overhead 。（應補上 Perl 的部分）
  * 本來是想做成像 inline FFI ，現在好像改掉了。（以 [purescript-easy-ffi](https://github.com/pelotom/purescript-easy-ffi) 的版本當範例）
  * CindyLinz: GHC 有規定 FFI 的格式。
  * CindyLinz: 它（purescript）還沒有 Template Haskell 對不對？ Alex: 對。
  * CindyLinz: 字串當成什麼用，是 interperter 決定。
  * Haskell2010 有 [callconv](https://www.haskell.org/onlinereport/haskell2010/haskellch8.html) ，Template Haskell 中也有一個 [Callconv](http://hackage.haskell.org/package/template-haskell-2.10.0.0/docs/Language-Haskell-TH-Syntax.html#t:Callconv) 。
  * Alex: 我的 Prelude 還沒有 show ... 。 CindyLinz: 我們的 Prelude 要有 show 還要一陣子，因為沒有 typeclass ... 。
  * Alex: 現在還在想，模組系統要怎麼做？聽 Cindy 說 GHC 沒有支援遞迴...。
  * CindyLinz 解釋 module system ，表示會用到的應該要做 type check ？如果只有看 type 應該不會太難做？ inline 可能會複雜一些。可以全部放一起，用全名就不會打架。 GHC 可以 import 同名的 module ，前面用雙引號打 package name （extension）。 Haskell standard 有規定要做這個，但是 GHC 沒有做。
  * Alex: 我看[很多人](https://wiki.haskell.org/Mutually_recursive_modules#Compiler_support)都沒有做。
  * CindyLinz 表示想不通複雜在哪邊， Alex 提到分開編譯，覺得好像可以又好像會卡卡的。
  * CindyLinz 描述 GHC 如何做 destructuring ，提到內部以 function pointer 實作，缺點是連 Boolean 都要用整個 64-bit 。也許可以用一個大 switch ，但這樣就要把大家都搜集起來，不能分開 parse code 。都寫在 top level 的話， parse 還是要做，但是 type inference 不用做。 Alex 表示會試試看。

# CindyLinz

  * 加上了 [DeIf.hs](https://github.com/CindyLinz/Haskell.js/blob/a527eef3a54f8f9fab3ec3d4e4a5cb46bdf69cb5/trans/src/DeIf.hs) 和 [DeList.hs](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/src/DeList.hs) 兩個檔。
  * if 有三個 exp ，要轉換後，正確地放在 case 裡面。（現在還得按順序寫）
  * [`desugarModule`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/src/Main.hs#L239) 會把 parse 出來的 Module desugar ， type 都是 `desugarModule :: Module -> Module` （[`deIfModule`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/src/DeIf.hs#L229), [`deListModule`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/src/DeList.hs#L226)）。
  * 重點在 Exp ， 400 多行 code 重點只有 4 行，所以才需要用 `desugar-template` 幫忙產生 code ：

  ```
  -- 上面一百多行
  deIfExp (If exp1 exp2 exp3) = deIfExp $
  Case exp1
    [ Alt (SrcLoc "" 0 0) (PApp (UnQual (Ident "False")) []) (UnGuardedRhs exp3) Nothing
    , Alt (SrcLoc "" 0 0) (PApp (UnQual (Ident "True")) []) (UnGuardedRhs exp2) Nothing
    ]
  deIfExp (MultiIf guardedRhs) = MultiIf (fmap (deIfGuardedRhs) guardedRhs)
  -- 下面兩百多行
  ```

  * 先跑 `cabel install` 再執行，才不會有 cabal 前面那兩行。
  * 可以自己照打一遍，或是複製它（前述的 DeXXXX.hs ）。
  * 解釋 $ 在 Template Haskell 的作用，可以讀到原本 code 中 import 的東西。
  * CindyLinz 表示前面提到的遞迴 import ，是不是因為 TH 害的？
  * 而且 TH 中規定， `$()` 內用到的函數可以是 import 進來的，不可以是該檔案中定義的。
  * 提到 C marco 可以生不完全的程式碼，只要最後湊起來是可以跑的就好。
  * 現在沒法把 TH 放到我們的 interpreter 中。就像在借錢，用到的功能越多，未來要還的越多。
  * [`Monad Q`](https://hackage.haskell.org/package/template-haskell-2.6.0.0/docs/Language-Haskell-TH-Syntax.html#t:Q)
  * `deriveDesugarTemplate` 傳回的是 [`Q [Dec]`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/desugar-template-src/DeriveTemplate.hs#L59) ，所以最後才要補上 [`fmap`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/desugar-template-src/DeriveTemplate.hs#L81) 。
  * Haskell tuple 的寬度不一樣不能簡單的 iterate 過去，就有人用 TH 生處理這狀況的 code 。（來源請求）
  * [`reify`](https://hackage.haskell.org/package/template-haskell-2.7.0.0/docs/Language-Haskell-TH.html#v:reify) 用來讀出 Data 的結構。
  * 因為都是 [Show](https://hackage.haskell.org/package/base-4.5.0.0/docs/Text-Show.html#t:Show) ，可以都 `show` 出來看看，再繼續寫。
  * 本來寫的版本是直接生出字串，但那樣就沒辦法依據 `getArgs` 傳入的 module name 和 prefix 生出不同的 code, 我們需要把靜態字串跟吃進來的名字接起來才行。
  * CindyLinz 以 [`go res seen (nameStr : others)`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/desugar-template-src/DeriveTemplate.hs#L102) 那段來 demo ，可以寫精神上很像 C  的迴圈。沒有撞名不用加數字，有撞名才加數字。臨時用的半成品函數很難取名字，只有在該 context 才看得懂。建議不要用在很長的地方，不然要記住 go1, go2 是什麼，到 go5 就搞不清楚...：

  ```
  dupNames :: S.Set String
  dupNames = go S.empty S.empty rawNames where
    go res seen (nameStr : others) =
      if S.member nameStr seen then
        go (S.insert nameStr res) seen others
      else
        go res (S.insert nameStr seen) others
    go res _ _ = res
  ```

  * 如果用比較 functional 的寫法，就做很多參數，個別取名字。
  * 介紹 [Multi-way If](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#multi-way-if) ， `if` 後面用 `|` ，現在 `|` 要對齊，不然巢狀會不知道 `|` 是誰的，在 `|` 和 `->` 中間放 exp ，如果 `True` 就執行。以前要用 `case of` 加上 guard 寫。
  * 有個 extension 叫 [Pattern guards](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#pattern-guards) ，可以和其他可塞在 guard 中的 extension 混用，連 in 都不用寫。
  * 用 [infix `App`](https://github.com/CindyLinz/Haskell.js/blob/cca5df022a096f1bc0c5bb3cec202821e4d0908d/trans/src/DeList.hs#L135) 讓 code 變得簡潔。但是 infix 就會有左右結合、權重的問題。
  * 提議：大家來做 desugar ，一起提出兩三個。會先解釋該 desugar 成什麼，並介紹覺得實用的 extensions 。和本來大家自己選 desugar 這樣的方向不同。 type inference 則晚一點做，同樣 typeclass 相關的會比較晚做到。
  * 提到 type infernece 如果 desugar 後做，會 user 造成的不便。做 desugar 的這段時間，就是我們猶豫的時間。
  * Alex 提到是不是可以留一些資訊到 desugar 後的程式中。 CindyLinz 以 [SrcLoc](https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-SrcLoc.html#t:SrcLoc) 為例，提到 LCamel 希望 Exp 中都有。（不確定）
  * Alex 提到 [Haskell.Exts.Annotated.Parser](https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Parser.html) 的 Module 會帶 [SrcSpanInfo](https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Parser.html#g:3) 。如果 desugar 後可以帶著走，就能知道錯誤出在哪裡。
  * transpiler 沒做 desugar 一樣可以做，會希望 transpiler 一直都只能用基本語法，所以兩邊不會打架。
  * Alex 提到 [Write You a Haskell](http://dev.stephendiehl.com/fun/) 用的是 HM ，還沒讀到有沒有 typeclass 。
  * Alex 提到手動補 type ，挑 desugar 時可以多點選擇。
  * 介紹 [list comprehension](https://wiki.haskell.org/List_comprehension) ，內含 pattern matching 。
  * silverneko 提到可以轉成 do ，把 pattern matching 留到未來。
  * 如果等不及，可以考慮用現用的 interpreter 寫 Haskell parser 。順便介紹了 Haskell 可以加上 `{}` 和 `;` 而不用縮排。問題就會出在 GHC 語法太多，要寫很多行。
  * Hugs 有定義類似 heredoc 的字串， GHC 沒有，但我們用的 parser 有做。
  * 至少做到：雖然沒寫，但聽得懂別人做了什麼，知道自己有時間也能做出來。
  * 如果寫不出來，那可能是我們進行得太快，可能要踩煞車。

## 下次的 desugar

  * if
  * list: 先做 `[a, b, c]` 這種 list 就好。
  * where: 每個 Clause/Match 可以跟一個 where ，每個 Alt 可以跟一個 where 。 where 可以用到的地方很少。
  * 比較複雜，有 pattern matching 的 case 。（選擇性）

# 下次聚會時間

2015.12.24(四) 2F
