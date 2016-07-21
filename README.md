# BYOHC workshop 活動記錄

[draft schedule](https://gist.github.com/CindyLinz/975dce9755ebeec6e4a5) by CindyLinz

## 自造同學

| 自造者                              | 開發平台                       | 期待用途                                                                                 | Repository                                         |
| ------                              | --------                       | --------                                                                                 | ----------                                         |
| [Cindy][CindyLinz]                  | Javascript (browser)           | 寫一個像 [Scratch](https://scratch.mit.edu/) 的, 在 browser 裡玩的 Haskell 拼圖          | [github](https://github.com/CindyLinz/Haskell.js/) |
| [Yun-Yan Chi][jaiyalas]             | Haskell (native)               | 可以對 Haskell 隨意加功能                                                                | [github](https://github.com/jaiyalas/ParametricLambda)[![Build Status](https://api.travis-ci.org/jaiyalas/ParametricLambda.png?branch=stable)](http://travis-ci.org/jaiyalas/ParametricLambda)        |
| [Chia-Chi Tsai][rueshyna]           | (native)                       | 還在想                                                                                   |                                                    |
| [Chiang, Yi-Yo][silverneko]         | (native)                       | 可以對 Haskell 隨意改語法                                                                | [github](https://github.com/silverneko/Lambda-calculus-interpreter) |
| [Shuk][BizShuk]                     | Javascript (node.js)           | 寫 web 程式 & 想把開發過程記錄下來                                                       | [github](https://github.com/BizShuk/Haskell_compiler)               |
| [Lex][LexSong]                      | Python                         | 使用 Python library, 但可以寫 Haskell 不用寫 Python                                      |                                                    |
| [AlvinChiang][absolutelyNoWarranty] | Python                         | 用 Haskell 寫一個 compiler 把自訂語言生成 latex                                          |                                                    |
| [Pomin Wu][pm5]                     | Go                             | 還在想                                                                                   | [github](https://github.com/pm5/byohc-workshop)    |
| [YunLiaw][YunLiaw]                  |                                | 還在想                                                                                   |                                                    |
| [Kelly/Kai][rasca0027]              |                                | 還在想                                                                                   |                                                    |
| [AlexLu][op8867555]                 | Python                         | 用 Python 執行的一個用 Haskell 寫的 Haskell compiler                                     | [lambda interpreter](https://github.com/op8867555/BYOHC), [transpiler](https://github.com/op8867555/BYOHC-transpiler)      |
| [卡西][caasi]                       | WASM or Javascript             | 做個 lambda-wasm-prototype 之類的工具                                                    | [ulc.ls](https://github.com/caasi/ulc.ls), [playground](https://github.com/caasi/ulc-playground), [trans](https://github.com/caasi/trans)      |
| [GeorgeLi][Georgefs]                | Python                         | 理解 Haskell                                                                             | [github](https://github.com/georgefs/BYOHC-Workshop)                                                  |
| [Summit][suensummit]                | Python                         | 還在想                                                                                   |                                                    |
| [Carl][Carl-Lin]                    | Javascript (node.js + browser) | 在公司 production 環境用                                                                 |                                                    |
| [GeorgeChao][whizzalan]             | Python                         | 資料處理                                                                                 |                                                    |
| [LCamel][LCamel]                    | JVM or WASM (browser)          | 還在想                                                                                   | [github](https://github.com/LCamel/BuildYourOwnHaskellCompiler) |
| [瑋隆][weilongain]                  | Javascript (browser)           | 寫一個瀏覽器小遊戲                                                                       |                                                    |
| [Eric][ericpony]                    | Scala                          | 讓已用 Agda 證明正確性的 Haskell 程式可以直接在 JVM 執行, 而不用手動翻譯成 Scala 或 Java |                                                    |
| [127][a127a127]                     | coffeescript or LLVM           | 還在想                                                                                   | [github](https://github.com/a127a127/byohc) |
| [Chia-Chi Chang][c3h3]              | Javascript or Python           | 還在想                                                                                   |                                                    |
| [Kevin][ucfan]              | Javascript Scheme          | 還在想                                                                                   |                                                    |
| [Kazami][Knight-X]              | C++           | 還在想                                                                                   |                                                    |


[CindyLinz]: https://github.com/CindyLinz/
[jaiyalas]: https://github.com/jaiyalas/
[rueshyna]: https://github.com/rueshyna/
[silverneko]: https://github.com/silverneko/
[BizShuk]: https://github.com/BizShuk/
[LexSong]: https://github.com/LexSong/
[absolutelyNoWarranty]: https://github.com/absolutelyNoWarranty/
[pm5]: https://github.com/pm5/
[YunLiaw]: https://github.com/YunLiaw/
[rasca0027]: https://github.com/rasca0027/
[op8867555]: https://github.com/op8867555/
[caasi]: https://github.com/caasi/
[Georgefs]: https://github.com/Georgefs/
[suensummit]: https://github.com/suensummit/
[Carl-Lin]: https://github.com/Carl-Lin/
[whizzalan]: https://github.com/whizzalan/
[LCamel]: https://github.com/LCamel/
[weilongain]: https://github.com/weilongain/
[ericpony]: https://github.com/ericpony/
[a127a127]: https://github.com/a127a127/
[c3h3]: https://github.com/c3h3/
[ucfan]: https://github.com/ucfan/
[Knight-X]: https://github.com/Knight-X/

## 活動記錄

  * [2015.9.24 #1: 實作 Lambda Calculus interpreter](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.9.24.md)
  * [2015.10.15 #2: 加上 primitive, lazy evaluation](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.10.15.md)
  * [2015.10.29 #3: 加上 IO FFI](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.10.29.md)

  * [2015.11.12 #4: 將 Haskell 基本語法 compile 成自己的 lambda 程式](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.11.12.md)
  * [2015.11.26 #5: 分享 transpiler 實作](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.11.26.md)
  * [2015.12.10 #6: 寫 desugar 、自修 type check/inference](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.10.md)
  * [2015.12.24 #7: pattern matching 相關的 extensions](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2015.12.24.md)
  * [2016.1.14 #8: 補充上次漏講的 pattern matching 語法，聊聊 symbol table 的實作](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.1.14.md)
  * [2016.1.28 #9: pattern matching 半成品與 a127 的 lambda interpreter](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.1.28.md)
  * [2016.2.18 #10: import / export 語法與語意，還有 pattern matching 的重大進展](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.2.18.md)
  * [2016.3.10 #11: STM (部分)與 pattern binding](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.3.10.md)
  * [2016.3.31 #12: Haskell Web 應用](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.3.31.md)
  * [2016.4.14 #13: 討論確認之後活動進行的方式](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.4.14.md)
  * 2016.4.28 #14: 用 stack 建立專案，大家一起讀 modules 然後 pretty print
  * [2016.5.12 #15: 上週進度加上兩個 bonus 支線任務](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.5.12.md)
  * 2016.5.26 #16: 實作 desugar 骨幹
  * 2016.6.9 #17: 實作 desugar 骨幹
  * 2016.6.30 #18: 實作 desugar 骨幹
  * [2016.7.21 #19: 實作 desugar 骨幹](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/workshop-2016.7.21.md)

## 輔助工具

  * lambda playground

      + [Lambda Calculus playground (卡西)](https://caasi.github.io/ulc-playground/)

        有 IO

      + [Lambda Calculus playground (CindyLinz)](https://cindylinz.github.io/Haskell.js/lambda-calculus.html)

        純 lambda

      + [Lambda parser (CindyLinz)](https://cindylinz.github.io/Haskell.js/lambda-parser.html)

        Lambda to JSON

      + [Lambda pretty printer (CindyLinz)](https://cindylinz.github.io/Haskell.js/lambda-pretty-printer.html)

        JSON to Lambda

  * desugar

      + [配合 haskell-src-exts syntax tree 長相生成對應的處理函數](https://github.com/CindyLinz/Haskell.js/tree/master/trans)

        ```shell
        $ cabal run desugar-template [module name] [function name prefix] [mode: 0.normal / 1.annotated] [# of additional arguments] > [module name .hs]
        ```

## 參考資料

  * [REFERENCES.md](https://github.com/CindyLinz/BYOHC-Workshop/blob/master/REFERENCES.md)

## 心得筆記

  * [卡西][caasi] [Build Your Own Haskell Compiler 系列心得](http://caasih.logdown.com/tags/BYOHC)
