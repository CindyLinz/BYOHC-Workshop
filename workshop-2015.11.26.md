# BYOHC 2015-11-26

這次只有 [CindyLinz](https://github.com/CindyLinz/Haskell.js/tree/master/trans) 跟 [AlexLu](https://github.com/op8867555/BYOHC-transpiler) 做了 transpiler 。  

大家分別講解各自的實作。

## CindyLinz

CindyLinz 講解自己的 [trans](https://github.com/CindyLinz/Haskell.js/tree/master/trans) ，先看 tranpile 出來的 code 。提到未來可能會移除 async ，畢竟在 browser 中，沒有 getChar 。

### JS 部分

* 全域的 env ，大家註冊自己（[prelude-lambda.js](https://github.com/CindyLinz/Haskell.js/blob/master/trans/res/prelude-lambda.js), [prelude-native.js](https://github.com/CindyLinz/Haskell.js/blob/master/trans/res/prelude-native.js)），用 JS 寫的函數也能註冊到 global
* 會有 main
* env 定義完，就執行，就是之前的 [`weak_normal_form`](https://github.com/CindyLinz/Haskell.js/blob/master/trans/res/init.js#L19)
* 加上了 [`'dat'`](https://github.com/CindyLinz/Haskell.js/blob/master/trans/res/init.js#L24) 表示 native data

### Haskell 部分

* Prelude 混用 Haskell 和 native ，生 code 的能力比較完整後，越來越多東西可以用 Haskell 寫
* `transModule` 吃一個 [Module](https://hackage.haskell.org/package/haskell-src-exts-1.17.0/docs/Language-Haskell-Exts-Syntax.html#t:Module) ，吐出 JS
* [RuntimeSource.hs](https://github.com/CindyLinz/Haskell.js/blob/master/trans/src/RuntimeSource.hs) 是由 [res2src.pl](https://github.com/CindyLinz/Haskell.js/blob/master/trans/res2src.pl) 生出來的
* 有參數是 FuncBind ，沒參數是 PatBind
* 本來規劃的「支援 desugar, type inference 之後的程式碼」和「作出上列基本語法範圍內的 type inference / type check (之一)」實際上會混在一起做
* GADTs...（待補）
* 要考慮 case 遇到 native （`I# 0#` 和 `0#`）時怎麼作
* user 寫的 case 順序可能和 GADTs 不同，得幫他補，並調順序
* `_` 不是變數，是 WildCard ， `[]` 是 PList 不是 List
* 都是執行才爆炸
* 希望將來可以直接使用 GHC 的 Prelude
* 早點做 import 比較好
* 在 GHC type 錯了會爆炸，在 ulc 裡卻不會

## AlexLu

* 用了 State Monad
* 用 [Aeson](https://github.com/op8867555/BYOHC-transpiler/blob/master/src/Trans.hs#L110) 生 code 似乎比較清楚
* 用的是舊版 `haskell-src-exts`
* 用許多 `mapM` 串起來
* 做了一些 [helper](https://github.com/op8867555/BYOHC-transpiler/blob/master/src/Trans.hs#L145) 來幫忙生 code

> 漏記一段

* 沒有用到 cabal ，用了 stack ， stack 預設就用 cabal sandbox
* 苦主每次更新 Arch ，就得把 cabal 裡所有的 modules 都重裝一次 QAQ
* CindyLinz 提到未來也要想想怎麼做 Workshop 自己的 package manager
* 有關 Applicative...（待補）
* 全部用 do
* CindyLinz 第二次提到想名字是件麻煩的事情
* 已經做了吐出 JSON 的 console interperter: `stack exec transpiler-exe`
* 存在 [Language.Haskell.Exts.Pretty](https://hackage.haskell.org/package/haskell-src-exts-1.17.0/docs/Language-Haskell-Exts-Pretty.html) 可以用
* [Language.Haskell.Exts.SrcLoc](https://hackage.haskell.org/package/haskell-src-exts-1.17.0/docs/Language-Haskell-Exts-SrcLoc.html)?
* [這段](https://github.com/op8867555/BYOHC-transpiler/blob/master/src/Trans.hs#L102)被 CindyLinz 說很像 Core ，只是沒有 type

CindyLinz 建議這次結束可以先讀 Hindley-Milner type inference 演算法。不用實作，先讀懂就好。

## LCamel

* 開始用 Java 實作
* 使用 [De Bruijn Index](https://github.com/LCamel/BuildYourOwnHaskellCompiler/tree/master/src/main/java) ， 見 `Db*.js`
* 正在講 internal function 的參數該怎麼化簡，明知 AST 一定有 normal form ，不能以任意順序 evaluate 的話不開心

CindyLinz 表示 LCamel 又提出了自己沒想到的問題 (Y)

* subs 參數會被 evaluate 兩遍的問題， LCamel 表示還不清楚，哪時 subgraph 可以被安心的重用
* CindyLinz 表示參數一樣就可以用，要是遇到 World ，則要假設都不一樣
* evaluate 好幾遍這件事情，是在實作 read 時發現的
* 現在的實作，吃滿了會把 index 歸零

## 然後

* AlexLu 好像找到了 Java 寫的 Haskell parser ？
* CindyLinz 提到可以寫： `class F (A a b c)` ，但是不能寫： `class F (A a) (B b)` ，語法不會多很多。但是 `for all` 就會多很多。
* CindyLinz 再次強調大家都用 Haskell 寫 desugar 的話，可以互相重用。
* LCamel 考慮在 Java 中跑 JavaScript engine ！
* CindyLinz：「自己先作過才會發現，欸呀，進度訂太快 ^^|」
* 下次沒訂新進度，先跟上或插進來，之前的就用別人的是可以的。沒時間寫也可以抽時間想，這樣討論的時候不會無聊。

## 自由分享

* LCamel 希望 IDE 可以直接告訴自己現在的 syntax 跟定義。 code 的形狀可能無法 Google ，但是 parser 知道（那個形狀）是什麼東西。
* FT 來的新朋友 [Tyler](http://www.meetup.com/Functional-Thursday/members/142073172/) 還有另外兩位是？
* 要操作 DOM 怎麼辦？需要 native/foreign library
* 只求可以運作的話，希望 foreign library 能越少越好

下次是 2015-12-15 。
