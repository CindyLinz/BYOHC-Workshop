# 本次目標

  * 主線目標:

      + 將 Haskell 基本語法 compile 成自己的 interpreter 可以處理的 lambda 程式

  * 支線目標:

      + 用 Lambda interpreter 寫應用: 在 native 或瀏覽器裡面執行的小遊戲, 小工具, compiler.. 等等

        (在活動記錄首頁記錄一下 link, 講一下這個東西怎麼執行怎麼玩~)

      + 用不同方式實作 Lambda interpreter (或 compiler), 以方便自己或別人嫁接 Haskell 轉換的 Lambda 程式.

        (在活動記錄首頁記錄一下 link, 使用的方法, 執行的平台, 使用/執行的方式, 是 library 函數呼叫或是獨立執行檔等等)

      + 幫忙想一下在 haskell-src-exts 作 desugar 的話可以用怎樣的資料結構, 方便大家分頭實作不同語法的 desugar

      + 讀 type inference 的 Hindley Milner 演算法, 以及想想加上 type class 與 existential type 之後的 bi-directional type 要怎麼寫

        (會有需要碰運氣搜尋的情況, 要想想怎樣的 heuristic 演算法可以盡可能 cover 我們可能會寫出來的程式)

# Haskell 基本語法與 Lambda 程式的對應

  * lambda
    ```haskell
    \a b c -> expr a b c
    ```
    ```
    \a \b \c expr a b c
    ```

    或是可以選擇只實作只有一個參數的 lambda

  * top-level definition
    ```haskell
    f = \a b c -> expr a b c
    ```
    ```
    :let f = \a \b \c expr a b c
    ```
    (用的是 [Chiang, Yi-Yo](https://github.com/silverneko/) 的 :let 語法, 但可能有遞迴..
    也許可用下面 let..in 的方式來實作, 然後再額外加上把 symbol export to external 的功能)

    不用函數有參數的寫法, 而都是寫一個 lambda

  * main 入口
    使用 runIO 意味的東西

  * literal
    (現階段可以先假設數字就是 Int, 字串就是 [Char] 等等.. 或是要求程式碼要標 type signature)

  * GADT
    ```haskell
    data Expr :: * -> * where
      I :: Int -> Expr Int
      B :: Bool -> Expr Bool
      Add :: Expr Int -> Expr Int -> Expr Int
      Eq  :: Expr Int -> Expr Int -> Expr Bool
    ```
    ```
    :let I = \*1 \is-I \is-B \is-Add \is-Eq is-I *1
    :let B = \*1 \is-I \is-B \is-Add \is-Eq is-B *1
    :let Add = \*1 \*2 \is-I \is-B \is-Add \is-Eq is-Add *1 *2
    :let Eq = \*1 \*2 \is-I \is-B \is-Add \is-Eq is-Eq *1 *2
    ```

  * case..of (沒有 guard, 沒有 view pattern, 而且 pattern 都是一層 GADT data constructor 或是 literal)
    ```haskell
    case a of
      I a1 -> exprI a1
      B b1 -> exprB b1
      Add a1 a2 -> exprAdd a1 a2
      Eq e1 e2 -> exprEq e1 e2
    ```
    ```
    a (\a1 exprI a1) (\b1 exprB b1) (\a1 \a2 exprAdd a1 a2) (\e1 \e2 exprEq e1 e2)
    ```

    ```haskell
    case a of
      1 -> expr1
      _ -> expr
    ```
    (需要依不同類型的 literal primitive 以 native 特製)
    ```javascript
    switch(a){
      case 1: ...
      default: ...
    }
    ```

  * let..in (= 左邊一定是變數, 沒有 pattern)
    ```haskell
    let
      even = \n -> case n of
        0 -> True
        _ -> odd (n - 1)
      odd = \n -> case n of
        0 -> False
        _ -> even (n - 1)
    in
      even 5
    ```
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

# 延伸討論

  * 用 syntax desugar 把泛型函數 reduce 為基本語法示意

      + 原始 Haskell 目標程式
        ```haskell
        fff :: Eq a => a -> a -> Bool
        fff a b = not (a == b)

        class Eq a where
          (==) :: a -> a -> Bool
          (/=) :: a -> a -> Bool

        instance Eq Int where
          a == b = ...
          a /= b = ...
        ```

      + 轉換後的基本語法 Haskell (示意, 會有名稱衝突之類的問題請忽略)
        ```haskell
        -- class Eq a 對應的 witness data type
        data EqWitness a = EqWitness
          { (==) :: a -> a -> Bool
          , (/=) :: a -> a -> Bool
          }
        -- or GADT + member helper function 寫法
        data EqWitness :: * -> * where
          EqWitness :: (a -> a -> Bool) -> (a -> a -> Bool) -> EqWitness a
        (==) = \eqWitness -> case eqWitness of
          EqWitness eq ne -> eq
        (/=) = \eqWitness -> case eqWitness of
          EqWitness eq ne -> ne

        -- instance Eq Int 對應的 witness data value
        intEqWitness :: EqWitness Int
        intEqWitness {== 的定義} {/= 的定義}

        -- 函數的定義裡拿 witness 來使用
        fff :: EqWitness a -> a -> a -> Bool
        fff = \eqWitness a b -> not ((==) eqWitness a b)

        -- 呼叫的時候傳 witness
        fff intEqWitness a b
        ```

# 下次聚會時間

2015.11.26 (四)

