# 本次目標

  * 加上內建/預建函數, 使用底層的數字與四則運算作加速
  * 實作 lazy evaluation (已經算過的同一個東西被第二次引用時可以直接取得結果不用重算)
  * 多練習寫寫看 lambda calculus 程式, 設計自己的 import lambda library 的寫法/作法 (純想想)

# 測試資料

  * [LCaml](https://github.com/LCamel/) 提供的一組, 用來測試 lazy evaluation (不重複算) 有沒有奏效的資料

    目前測過速度差異 (同一個人的程式, lazy 與否) 大概在 200x 到 4000x 之間~

    ```
    (\w
      (w (w (w (w (w (w (w (w (\x x)))))))))
    )(\x (x (x (x (x (x (x (x (x (x x))))))))))
    ```

    ```javascript
    ["app",["lam","w",["app",["var","w"],["app",["var","w"],["app",["var","w"],["app",["var","w"],["app",["var","w"],["app",["var","w"],["app",["var","w"],["app",["var","w"],["lam","x",["var","x"]]]]]]]]]]],["lam","x",["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["app",["var","x"],["var","x"]]]]]]]]]]]]
    ```

# 下次聚會時間

2015.10.29 (四)
