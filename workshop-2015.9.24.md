## 本次目標

實作 subs 與 env 版本的 Lambda Calculus interpreter

以共通的 JSON 格式來表示 expression, 輸入與輸出方式自訂 (直接把 input 程式寫死在變數裡也可以...)

然後程式願意給大家看的, 麻煩把你的程式網址放在 README.md 的表格裡面, 並且選一下授權,
懶得管的就選 MIT 吧 ^^

## 下次聚會時間

2015.10.15 (四)

## lambda calculus expression 實作資料結構

  + define lambda

    定義一個單參數 lambda 函數

    ```javascript
    ["lam", "參數名稱", 函數body]
    ```

  + apply lambda

    呼叫一個 lambda 函數

    ```javascript
    ["app", 函數(lambda 或是預期能夠 eval 成 lambda 的 expression), 參數]
    ```

  + variable

    一個等待被 expression 取代的變數名 (subs 實作法), 或 link 一個環境裡的變數 (env 實作法)

    ```javascript
    ["var", "變數名稱"]
    ```

## subs 實作法

  * weak normal form transition rule (算到出現 lam 為止, 或是目前確定無法成為 lam 為止)

    ```
    weak_normal_form(var a) → var a
    ```

    ```
    weak_normal_form(lam x y) → lam x y
    ```

    ```
    weak_normal_form(app f a) →
      若 lam x y = weak_normal_form(f) 則
        weak_normal_form(subs(y [a/x]))
        where
          sub(y [a/x]): 見下面 sub 定義
      否則
        app f a
    ```

  * normal form transition rule

    ```
    normal_form(var a) → var a
    ```

    ```
    normal_form(lam x y) → lam x normal_form(y)
    ```

    ```
    normal_form(app f a) →
      若 lam x y = weak_normal_form(f) 則
        normal_form(subs(y [a/x]))
        where
          sub(y [a/x]): 見下面 sub 定義
      否則
        app normal_form(f) normal_form(a)
    ```

  * sub(y [a/x]) 的定義

    把 y 裡面出現的 x 變數都換成 a expression.
    要注意只能換有被最外面的 x 參數管到的 x 變數.
    還要注意在層層取代的過程中, 如果發現了某個 lam k m 的這個參數 k 有出現在 a 裡的 [自由變數][],
    那要把 k 與 m 裡面的 [自由變數][] k 都換一個名字迴避一下, 以免名字沾到

    依 y 的長相來分類處理

    ```
    sub(var x [a/x]) → a (變數名剛好是 x)
    ```

    ```
    sub(var other [a/x]) → var other (變數名不是 x)
    ```

    ```
    sub(lam x body [a/x]) → lam x body
      (參數名剛好是 x, 那麼 body 裡面所有的 x 都歸這 lam 自己管)
    ```

    ```
    sub(lam k body [a/x]) → lam k sub(body [a/x])
      (參數名 k 不是 x, a 的自由變數沒有 k)
    ```

    ```
    sub(lam k body [a/x]) → sub(lam m1 sub(body [m1/k]) [a/x])
      或
    sub(lam k body [a/x]) → lam m1 sub(sub(body [m1/k]) [a/x])
      (參數名 k 不是 x, a 的 free variable 有 k, 所以先幫 k 取一個迴避用的沒被用過的新名字 m1)
    ```

    ```
    sub(app f r [a/x]) → app sub(f [a/x]) sub(r [a/x])
    ```

## env 實作法

相對於 subs 法, env 法除了 expression 之外, 要額外準備 env, 用來存放這個 expression 的 [自由變數][] 的內容 (內容為一個 expression 與配給的 env).
我稱這個內容為 closure
運算過程中出現的每一個 expression 都需要有一個自己的 env, 不過這一大堆 env 之間會有大量共同內容,
在程式裡要用什麼資料結構來表示這些 env, 需要構思一下.

正確的整個expression 應該是沒有 [自由變數][] 的, 所以整個程式的執行就是在求 `normal\_form(整個expression, 空的env)`

  * weak normal form transition rule (算到出現 lam 為止, 或是目前確定無法成為 lam 為止)

    ```
    weak_normal_form(var x, env) → weak_normal_form(env[x]) 如果 x 有出現在 env 裡面
    ```

    ```
    weak_normal_form(var x, env) → (var x, env) 如果 x 沒有出現在 env 裡面
      或
    weak_normal_form(var x, env) → (var x, {}) 如果 x 沒有出現在 env 裡面.. 反正這個 env 也沒什麼用了..
    ```

    ```
    weak_normal_form(lam x y, env) → (lam x y, env)
    ```

    ```
    weak_normal_form(app f a, env) →
      若 (lam x y, env2) = weak_normal_form(f) 則
        weak_normal_form(y, env3)
        where
          env3 所有內容與 env2 一樣, 但是加上 (如果原本有 x 的話就是蓋掉) x: (a, env)
          舊的 env2 有可能需要留著, 因為有可能有別的 expression 仍需使用 env2
      否則
        (app expr2 expr3, env)
        where
          (expr2, env2) = weak_normal_form(f)
          (expr3, env3) = normal_form(a, env)
    ```

  + normal form transition rule

    ```
    normal_form(var x, env) → normal_form(env[x]) 如果 x 有出現在 env 裡面
    ```

    ```
    normal_form(var x, env) → (var x, env) 如果 x 沒有出現在 env 裡面
      或
    normal_form(var x, env) → (var x, {}) 如果 x 沒有出現在 env 裡面.. 反正這個 env 也沒什麼用了..
    ```

    ```
    normal_form(lam x y, env) →  (lam x expr3, env)
    where
      (expr3, env3) = normal_form(y, env2)
      env2 所有內容與 env 一樣, 但是要把 x 去掉 (如果有的話),
        為要讓 y 裡面所有出現的 x 都保留著變數 x 的形式而不會換成值
        因為 x 是這個 lam 的參數, 要繼續等待被賦值
    ```

    ```
    normal_form(app f a, env) →
      若 (lam x y, env2) = weak_normal_form(f) 則
        normal_form(y, env3)
        where
          env3 所有內容與 env2 一樣, 但是加上 (如果原本有 x 的話就是蓋掉) x: (a, env)
          舊的 env2 有可能需要留著, 因為有可能有別的 expression 仍需使用 env2
      否則
        (app expr2 expr3, env)
        where
          (expr2, env2) = weak_normal_form(f)
          (expr3, env3) = normal_form(a, env)
    ```

## Scott encoding

放在這邊當參考, 不過最好不要記住.. 自己想一遍比較有趣 (即使自己想出來的沒有長得完全一樣)

  + Boolean & if-branch

    ```
    if: \cond \then \else cond then else
    true: \good \bad good
    false: \good \bad bad
    ```

  + Number (Scott encoding)

    ```
    0: \s \z z
    +1: \n \s \z s n
    1: +1 0 = \s \z s \s \z z
    2: +1 1 = \s \z s \s \z s \s \z z
    3: +1 1 = \s \z s \s \z s \s \z s \s \z z
    ...
    -1: \n n (\n- n-) X
    ```

  + Recursion (Y-combinator)

    ```
    Y: \f (\x f (x x)) (\x f (x x))
    ```

[自由變數]: https://en.wikipedia.org/wiki/Free_variables_and_bound_variables
