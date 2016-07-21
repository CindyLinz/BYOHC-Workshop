# 本次目標

  * 實作 desugar 的骨幹, 走訪整個 syntax tree  
    (可以定義一個 class, 然後把所有的 syntax node type 加進 instance;  
    或是為每一個 syntax node type 定義一個不一樣的函數名的作法也可以;  
    也可以兩種都有...)

  * 定義自己的 monad 來攜帶未來要加的資料結構, 讓這個骨幹的運行是在這個 monad 裡  
    (使用 mtl 的 Control.Monad.State 也可以)

  * [預計在這之後的下一步]  
    實作 global/local fixity decl, 把 infix 語法都轉換為 prefix 語法 (依正確的 fixity 作結合)

  * [Bonus]  
    擴充 import ，支援壓縮起來的 package

# 雜談

  * LCamel 想找方法知道 data 裡的 value contructors 。 petercommand 表示之前用 GHC generics 做到過。 LCamel 自己查到的方式是 `Data.Data` 和 `Data.Typeable` 做到。詳見 [reflection.md][reflection.md] 。

    ```
    > data A = B Int | C deriving (Typeable, Data)

    > typeOf (B 10)
    A
    > dataTypeOf (B 10)
    DataType {tycon = "A", datarep = AlgRep [B, C]}
    ```

  * CindyLinz 提到 `let a = a in a` 是土砲的 `undefined` 。

  * 假設知道自己在幹嘛，可以用 [`Data.Data.Internal`][Data.Data.Internal] 來得到沒有 export 出來的東西。

  * Cindy 表示做 `(>>=)` 跟用 `(>>=)` 好像國營機構和民營化，設計上得有取捨。

  * `undefined :: SomeType` 和 `Proxy :: Proxy SomeType` 的風格差異。

  * LCamel 好奇 GHC 有沒有什麼工具可以自己做 deriving 。 petercommand 說明怎麼用 [GHC.Generics][GHC.Generics] 套用自己的實作。

  * LCamel 繼續研究 Aeson 的 toJSON 是[怎麼做][Text.Aeson.Generic]的。

  * Cindy 發現 `Data.Data` 裡面有 [`constrFields`][constrFields] 等函數，也許可以幫得上忙。

  * petercommand, Options 取代 Maybe

  * Alex 找到 Haskell Report 中建議的 Prelude 包含了一些建議的 class 和 lib 。 Cindy 表示 GHC 沒有照它做，甚至有少。

  * petercommand 以為開了 `NoExplicitPrelude` 還是有 `IO` 可以用， LCamel 一試發現什麼都沒有 XDDD

    ```
    stack ghci --ghci-options "-XNoImplicitPrelude"
    ```

  * `import System.IO` 後有 `hPutStrLn` 跟 `stdout` 可以用 XD

  [reflection.md]: https://github.com/LCamel/BuildYourOwnHaskellCompiler/blob/6839f28c57d5ae7fb50d737407866a3ad271ac98/doc/reflection.md
  [Data.Data.Internal]: https://hackage.haskell.org/package/base-4.9.0.0/docs/Data-Typeable-Internal.html
  [GHC.Generics]: https://github.com/AndyShiue/ende/blob/e8a08b5520bf67508d78c6c3332cf8f54afa63be/frontend/src/Ast.hs
  [Text.Aeson.Generic]: https://hackage.haskell.org/package/aeson-0.6.1.0/docs/src/Data-Aeson-Generic.html
  [constrFields]: https://hackage.haskell.org/package/base-4.9.0.0/docs/Data-Data.html#v:constrFields

# 下次聚會時間

  2016.08.11(四)
