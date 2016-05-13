# 本次目標

  * transpiler bonus
  
    + 擴充 `import` ，支援壓縮起來的 package

# Bonus

  * GHC 可以用 `import "abc" Data.Int` 這樣的語法指定 packgae name `"abc"`
  
  * 可以對應一個 tar 檔或 zip 檔
  
  * 預計寫這樣的東西，可以學到寫些比較應用的東西，而不是 Haskell 的數學遊戲
  
  * 提到了 Windows 不分大小寫的問題
  
  * 可能會用到的 packages
  
    + `System.Environment`: 裡面有個 `getArgs :: IO [String]`
    
    + `System.Console.GetOpt`: `getOpt` ，第一次會覺得奇怪是它放值的地方放的是函數

  * `flip $` 和 `flip id` 是一樣的， ekmett 會把它定義成 `(&) = flip id`
  
  * 「以前有個軟體開發的書的作者認為程式要寫三遍」
  
  * `ghc-pkg` 與 package hiding ，這也是 GHC 自己搞的
  
  * GHC 編出來的 `.o` 也可以 inline
  
  * [`INLINABLE pragma`][INLINABLE]
  
  * hoogle 可以 local 裝，會找 local 有裝的 lib ，但是 CindyLinz 表示沒有配合 stack 一起用過
  
  * [`stack hoogle` command][stack-hoogle] 這個 issue 還是開著的
  
  * petercommand 問到該用什麼處理 exception ， silverneko 表示 可以試試 [`System.IO.Error`][System.IO.Error]
  
  * 解壓縮 libs ：
  
    + [zlib][zlib]
    
    + [zip-archive][zip-archive]

    + [tar][tar]

  [INLINABLE]: https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/pragmas.html#inlinable-pragma
  [stack-hoogle]: https://github.com/commercialhaskell/stack/issues/55
  [System.IO.Error]: http://hackage.haskell.org/package/base-4.8.2.0/docs/System-IO-Error.html
  [zlib]: http://hackage.haskell.org/package/zlib
  [zip-archive]: https://hackage.haskell.org/package/zip-archive
  [tar]: https://hackage.haskell.org/package/tar

# 未來進度

  * 寫個程式走訪 syntax tree ，但是不做別的事情，之後再把 desugar 的 code 塞進去

  * 再來先處理 infix operator 還有 operator 的 fixity
  
    + 會後 CindyLinz 補充了 [applyFixities][applyFixties] 的用法：
  
  * 於是 CindyLinz 建議在做「走訪」的時候，做成 Monad ，幫 synbol table 找個位子，放在 Monad 裡帶著走
  
  * 「compile 還是會過，只是你挖錯東西了」，然後 petercommand 說：「都是 fmap ，沒有可讀性」
  
  * 「寫 script 的人會想這樣用」，在這個進到 `Map` 裡面挖掉 `SrcSpanInfo` 的 case 下，三個 `fmap` 的 type 都不一樣，所以無法放到 `fold' (.) [fmap, fmap, fmap]` 裡面。 CindyLinz 表示本來想寫 `take 3 (repeat J)` 這樣的 code ， 3 可以改成 30 之類的。
  
  * 會後 CindyLinz 補充了 [`applyFixities`][applyFixities] 的用法：
  
    > 太佛心了... haskell-src-exts 裡面有 `class AppFixity` 只要我們把收集好的 `Fixity` 丟給 `applyFixities` 函數, 它就會幫我們把 syntax tree 作一個 fixity 的轉換...  
    > 如果用它... 似乎就不需要在我們的 monad 裡面帶著 fixity 的資訊, 在讀到 local fixity decl 的時候直接把會影響到的整個子樹轉換掉就好了
    > 而 top-level 的 fixity decl 會影響別的, 有 import 它的 module, 所以需要 export 出去, 但是就不需要丟在 monad 裡面纏繞了

  [applyFixities]: https://hackage.haskell.org/package/haskell-src-exts-1.17.1/docs/Language-Haskell-Exts-Annotated-Fixity.html#g:3

# 雜談

  * petercommand compile 時遇到了 `w_` 問說： "rigid type 就是 any ？"

  * 「C 的 marco 就缺了 `#push` 和 `#pop`」
  
  * petercommand：「把整個 macro system 換掉」
  
  * dryman 提到想用 [m4][m4] ，說它很 LISP
  
  * dryman 長輩宣傳了下週（5/12）的 [Functional Programming in C][Funth-39] ，可能同場加映的 persistent data type ，能查找過去的資料。還有 splay tree 。
  
  * GHC 有機率兩個 threads 都在算同一個 thunk ，但是打架也沒關係，都一樣。頂多浪費時間。
  
  [m4]: http://www.gnu.org/software/m4/
  [Funth-39]: http://www.meetup.com/Functional-Thursday/events/230711029/

# 下次聚會時間

 2016.05.26(四)