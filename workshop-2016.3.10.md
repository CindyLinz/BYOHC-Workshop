# 本次目標

  * Haskell library 介紹 
  
    + STM (部分)

  * demo 成果 / 半成品   

    + Lambda Interpreter
    
    + pattern matching

# 雜談

  * 下雨，人比較少。

  * CindyLinz 詢問了一下參與者對 Haskell 熟悉的程度。提到除了 lambda 那段，就她所知，大家平常沒在寫 Haskell 。
  
  * ssuio 到了。問了 type 和一般 OOP 語言的 class 有什麼不同？ CindyLinz 表示如果想要類似物件的東西，就是一包資料，跟操作他們的函數。並反問 ssuio 所說的「包」，是不是指封裝？ ssuio 又問， Haskell 的 type ，在 Java 中有沒有什麼東西可以對應？ CindyLinz 表示有，但不是原生的。
  
  * Shuk 到了。
  
  * CindyLinz 舉了一些像 Java 但是不一樣的地方：
  
    ```
    Object f (Object a, Object b)
  
    f :: a -> a -> a
  
    g :: a -> b -> a
    ```
    
  * 傳回值的部分， Java 跟 Haskell 的約定是顛倒的。 Java 的 `Object` 對 `f` 沒有限制，但對呼叫者有限制，因為你不能假設他會傳回什麼東西。呼叫者都要能處理。（註：例如在 Java 中用 `instanceof` 判斷 `Object` 到底是什麼）
  
  * Haskell 則是呼叫者想要什麼他都能給你，而你拿到的就是你想要的。（註：例如 `a -> a` 吃到 `Int` 就變成 `Int -> Int` ，回來的就是個 `Int`）
  
  * Haskell 可以描述參數之間的關係，但 Java （上例的 `a` 和 `b` ）沒有辦法描述這樣的關係。
  
  * CindyLinz 順便介紹了一下 currying 。表示可以把 `f :: a -> a -> a` 看成吃兩個參數的函數，也可以看成 `f :: a -> (a -> a)` ，成了吃一個參數，吐一個「吃一個參數的函數」回來。
  
  * 於是在 Haskell 可以把前半段的參數當成 config ，後面的才是使用時要傳的參數。
  
  * 如果用 design pattern 的角度看，可能像 template pattern 或 strategy pattern 。
  
    ```Haskell
    data Any = forall a. Any a
    ```
  
  * 這裡的 `Any` 就像是 Java 的 `Object` ，對 Haskell 來說， `[Any 3, Any 'c']` 就是同一個 type 。
  
  * 通常會加一些限制：
  
    ```Haskell
    data Any = forall a. Num a => Any a
    ```

  * 這樣就能有 `[Any 3, Any 4.2]` 。但實際上用到的機會不多。
  
  * 「會讓 compiler 看不出來，就表示給人類的資訊很少，要改人家的 code 的時候，會追很久。」
  
  * Java 不能有一個函數屬於兩個 class 。以遊戲為例，裡面有車子，有駕駛員，當車子會折舊時，那開車可能是開車的函數。當駕駛員經驗值會加時，那開車是駕駛員的函數。如果兩者要同時發生，那就要有第三者來處理這些事。如果開不同車又要加不同經驗值，在 Java 就很不好處理。經驗值是用來改變駕駛員的，但是卻得跟車子寫在一起（因為每台車子給的經驗值不一樣）。
  
  * 然後 CindyLinz 提到在 Java 中不同 type 相乘造成的困擾。

# CindyLinz

  * 這次寫的是 PatBind ，[測試][pat_bind.hs]的時候寫得複雜一點。
  
    ```Haskell
    data Triple :: * -> * -> * -> * where
      Triple :: a -> b -> c -> Triple a b c
    
    main =
      let
        Just (Right a) | 1 <= 0 = Just (Right "3")
                       | otherwise = Just (Right "4")
        Triple d (Just e) (Left f)
          | 3 <= 2 = Triple "D" (Just "E") (Left "F")
          | otherwise = Triple "d" (Just "e") (Left "f")
      in
        putStrLn (a ++ " (" ++ d ++ "," ++ e ++ "," ++ f ++ ")")
    ```
  
  * 一樣先心裡想好[展開][expanded]是什麼樣子，手寫一次。
  
    ```Haskell
    Just a | cond1, cond11 = expr1
           | cond2 = expr2
           where
             bind1 = bexpr1
             bind2 = bexpr2
    
    a = case () of
      _ | cond1, cond11 -> case expr1 of
          Just a -> a
        | cond2 -> case expr2 of
          Just a -> a
        where
          bind1 = bexpr1
          bind2 = bexpr2
    ```
  
  * 如果只有一個英文字母的話，拿出來，就會是我們最後要的結果。
  
  * Haskell 的 branch ，下面可以放一個 `where` ，那個 `where` 是這些 branch 共用的。
  
    ```Haskell
    a = case () of
      _ | cond1, cond11 -> case expr1 of
          Just a -> a
        | cond2 -> case expr2 of
          Just a -> a
        where
          bind1 = bexpr1
          bind2 = bexpr2
    ```
  
  * 改進版是把 `Just a` 只寫一遍，方法是外面再加一層 `case .. of` 。
  
    ```Haskell
    a =
      case
        case () of
          _ | cond1, cond11 -> expr1
            | cond2 -> expr2
            where
              bind1 = bexpr1
              bind2 = bexpr2
      of
        Just a -> a
    ```
  
  * 下面是兩個參數的寫法。實際上的程式碼有點偷懶，用不到的就變成 `_` 了。

    ```Haskell
    Pair a b = expr
      where
        bind1 = bexpr1
    
    a-b- =
      case
        let
          bind1 = bexpr1
        in
          expr
      of
        Pair a b -> (a, b)
    a = case a-b- of (a, b) -> a
    b = case a-b- of (a, b) -> b
    
    ---
    
    Pair a b
      | cond1 = expr1
      | cond2 = expr2
      where
        bind1 = bexpr1
    
    a-b- =
      case
        case () of
          _ | cond1 -> expr1
            | cond2 -> expr2
            where
              bind1 = bexpr1
      of
        Pair a b -> (a, b)
    a = case a-b- of (a, _) -> a
    b = case a-b- of (_, b) -> b
    ```
  
  * `case () of` 一定會 match 進去。

    ```Haskell
    case () of
      | cond1 -> expr1
      | cond2 -> expr2
      where
        bind1 = bexpr1
    ```
  
  * CindyLinz 提到以前沒有 [Multi-way if][multi-way-if] 時，大家是這樣達成類似的功能的。
  
  * [`patVars`][patVars] 是生出所有的變數。

    ```Haskell
    patVars :: Pat l -> [Name l]
    patVars = go [] where
      infixl 0 `go`
      go acc (PVar _ name) = name : acc
      go acc (PLit _ _ _) = acc
      go acc (PNPlusK _ name _) = name : acc
      go acc (PInfixApp _ p1 _ p2) = acc `go` p1 `go` p2
      go acc (PApp _ _ ps) = foldl go acc ps
      go acc (PTuple _ _ ps) = foldl go acc ps
      go acc (PList _ ps) = foldl go acc ps
      go acc (PParen _ p) = acc `go` p
      go acc (PRec _ _ pfs) = foldl go2 acc pfs where
        go2 acc (PFieldPat _ _ p) = acc `go` p
        go2 acc (PFieldPun _ (UnQual _ name)) = name : acc
        go2 acc (PFieldPun _ (Qual _ _ name)) = name : acc
        go2 acc (PFieldPun _ (Special _ _)) = acc
        go2 acc (PFieldWildcard _) = acc
      go acc (PAsPat _ name p) = (name : acc) `go` p
      go acc (PWildCard _) = acc
      go acc (PIrrPat _ p) = acc `go` p
      go acc (PatTypeSig _ p _) = acc `go` p
      go acc (PViewPat _ _ p) = acc `go` p
      go acc (PRPat _ _) = error "PRPat (regular list pattern) is not supported"
      go acc (PXTag _ _ _ _ _) = error "PXTag (XML element pattern) is not supported"
      go acc (PXETag _ _ _ _) = error "PXETag (XML singleton element pattern) is not supported"
      go acc (PXPcdata _ _) = error "PXPcdata (XML PCDATA pattern) is not supported"
      go acc (PXPatTag _ _) = error "PXPatTag (XML embedded pattern) is not supported"
      go acc (PXRPats _ _) = error "PXRPats (XML regular list pattern) is not supported"
      go acc (PQuasiQuote _ _ _) = error "PQuasiQuote (quasi quote pattern) is not supported"
      go acc (PBangPat _ p) = acc `go` p
    ```
  
  * 有一堆跟 XML 相關， CindyLinz 表示不知道是做什麼的。可以用 XML 寫 Haskell 嗎？
  
  * CindyLinz 發現了 [Regular Pattern][RegularPattern] ，有的 Haskell 有，但是 GHC 沒有。
  
  * 大家討論了一下，提到 Haskell 有 [spec][Haskell2010] 但是沒有誰完全實作。而有些語言像 Ruby, Python 是邊做邊生標準。
  
  * NPlusK pattern 也 deprecated 了，CindyLinz 提到穆老師好像滿喜歡這種寫法的。
  
    ```Haskell
    fact 0 = 1
    fact n = n * (fact (n - 1))
    -- 可以寫成：
    fact (n + 1) = (n + 1) * fact n
    ```
  
  * 據說後來 deprecated 掉，是因為實作效能的關係。
  
    + [What are “n+k patterns” and why are they banned from Haskell 2010?][NPlusKRemoved]
  
  * 記得遇到括號（`PParen`）要丟掉。
  
  * 要處理的都是 `PApp` ，然後 CindyLinz 描述了一下 `PApp` 在程式中的樣子。
  
  * code 不好解釋，因為是先寫單變數的，發現在雙變數的也可以用，就把它抓出去了。
  
    ```Haskell
    process =
      let
        vars = patVars pat
      in case vars of
        [] -> pass
        [onlyName] ->
          -- onlyName = case expr of pattern -> onlyName
          pure $ PatBind l (PVar l onlyName) valueRhs Nothing
        _ ->
          -- a-b-c- = ...
          -- a = ...
          -- b = ...
          -- c = ...
          PatBind l (PVar l listName) valueRhs Nothing : zipWith extractVar vars [0..]
          where
            extractVar var k = PatBind l (PVar l var) (selectRhs k) Nothing
    ```
  
  [pat_bind.hs]: https://github.com/CindyLinz/Haskell.js/blob/76139a0aeebecfa40f890befd9e143217d9f82c9/trans/sample/pat_bind.hs
  [expanded]: https://github.com/CindyLinz/Haskell.js/blob/76139a0aeebecfa40f890befd9e143217d9f82c9/trans/src/Desugar/PatBind.hs#L127
  [multi-way-if]: https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/syntax-extns.html#multi-way-if
  [patVars]: https://github.com/CindyLinz/Haskell.js/blob/76139a0aeebecfa40f890befd9e143217d9f82c9/trans/src/Desugar/PatBind.hs#L8
  [RegularPattern]: https://mail.haskell.org/pipermail/haskell/2004-February/013720.html
  [Haskell2010]: https://www.haskell.org/onlinereport/haskell2010/
  [NPlusKRemoved]: http://stackoverflow.com/questions/3748592/what-are-nk-patterns-and-why-are-they-banned-from-haskell-2010

# 雜談

  * CindyLinz 表示，到第二階段後，沒有什麼人跟上，是不是因為不熟 Haskell 。
  
  * caasih 表示，對剛入門幾個月的人來說，要知道該 desugar 成什麼樣子，設計資料結構把 data constructors 蒐集好，並用 Haskell.Src.Exts 的 Syntax 把心中想的 code 拼出來，是很難的事情。
  
  * CindyLinz 再次提到可以把 `show` 吐出來的 AST 給其他語言處理這件事。（註：這裡提到的是 [Haskell.js][Haskell.js] 中的 `stack exec show` ）
  
  * caasih 岔題問到 Funth #34 的 `moveMoving` 函式，才知道原來 `=` 右邊的是 data 不是 type ，可以用 data 來記狀態。
  
  * CindyLinz 問到「沒有迴圈可用」是否會造成困擾。 ssuio 問到「Haskell 沒有迴圈嗎？」，然後 CindyLinz 解釋了一下。
  
  * CindyLinz 提到當他用到[有 `acc` 當參數的 function ][PatBind-loop]時，就是在做類似迴圈的事情。
  
  * CindyLinz 在 Cat System 講 STM 時用到一張圖，是用程式寫的。（[STM執行時的資料結構][STM-SVG], [struct-view.js][struct-view.js], 都是 SVG ）
  
  * struct-view.js 裡面還有個 [`newLink`][newLink] ，會自動找最短的點連線。
  
    ```JavaScript
    var newLink = function(a, b, opts){
      var dis = 1e9, dis2;
      var i, j;
      var i0, j0;
      for(i=0; i<a.link.length; ++i)
        for(j=0; j<b.link.length; ++j){
          dis2 = Math.sqrt(sqr(a.link[i].x-b.link[j].x) + sqr(a.link[i].y-b.link[j].y)) + a.link[i].d + b.link[j].d;
          if( dis2 < dis ){
            i0 = i;
            j0 = j;
            dis = dis2;
          }
        }
      var dom = newNode('line');
      dom.setAttribute('x1', a.link[i0].x);
      dom.setAttribute('y1', a.link[i0].y);
      dom.setAttribute('x2', b.link[j0].x);
      dom.setAttribute('y2', b.link[j0].y);
      if( !opts )
        opts = {};
      dom.setAttribute('stroke', opts.stroke || '#000');
      dom.setAttribute('stroke-width', opts.strokeWidth || 2);
    
      var box = {};
      box.dom = dom;
    
      svg.appendChild(dom);
    
      return box;
    }
    ```
  
  * struct-view.js 是用 JS 寫的，不開心，如果是用 Haskell 寫的，會開心。也許這個活動可以這樣做？
  
  * caasih 問到是不是用 CindyLinz 現在的 transpiler 做應用？ CindyLinz 本來是想自己寫，怕自己的 transpiler 別人用會有很多洞。 Shuk 表示有人開 issues 應該開心。
  
  * CindyLinz 在 prelude-native.js 中加了 [`tuple_con_gen`][tuple_con_gen] 來生出不特定數量的 `Tuple` 。生出來的是 Scott encoding 的 `Tuple` 。
  
    ```JavaScript
    function tuple_con_gen(n){
      var gen_app = function(i){
        if(i>0){
          return ['app', gen_app(i-1), ['var', 'x'+i]];
        }else{
          return ['var', 'f'];
        }
      };
      var gen_lam = function(i){
        if(i<=n){
          return ['lam', 'x'+i, gen_lam(i+1)];
        }else{
          return ['lam', 'f', gen_app(n)];
        }
      };
      return gen_lam(1);
    }
    ```
  
  * ssuio 提到現在在學 jsp 。 CindyLinz 表示 Java 程式設計師很好找，如果真的只是當工人的話。
  
  * CindyLinz 表示 Java 是 WET principle （跟 "Don't Repeat Yourself" 的 DRY 相對， "We Enjoy Typing"）。連 Ada 都沒有那麼長。
  
  * Ada 要定義整數範圍到哪裡，至少知道寫的東西是有價值的。
  
  * CindyLinz 請大家回去想想可以做什麼 browser 上的應用。而自己要開始傷腦筋 type 了。
  
  * ssuio 提到初學該看什麼？（除了 AlexLu 提到的 Real World Haskell 之外） CindyLinz 提到自己一開始看的是 [YAHT][YATH] 。現在讀到一本還不錯，叫 [Beginning Haskell][BeginningHaskell] 。數學家適合 Haskell Tutorial ，而工程師適合讀 Beginning Haskell ，因為他是從 code 寫下去會有什麼效果開始講。
  
  * [Real World Haskell][RealWorldHaskell] 可以讀，但讀完還是會有距離。還可以讀 [24 Days of GHC Extensions][24Days] 。 CindyLinz 表示自己以前學時沒有這種教材，只好一個一個看，看了很多沒有用的，還給你論文的連結。
  
  * CindyLinz 表示學到覺得自己可以用，大概花了三年。
  
  * ssuio 問到 Haskell 遇到問題會不會比較難 Google ， CindyLinz 表示可能比 C++ 好 Google ，又提到 C++ 功能很多，用法很多，不是每個人都知道所有的用法。然後介紹了一下 C++ 的 value 不像 C 只有 lvalue 跟 rvalue ，還有 prvalue, xvalue, glvalue ... 。
  
  * CindyLinz 表示自家二人麻將的排列組合是用 Haskell 寫的。
  
  * 最後請大家丟一些可以提早在 browser 實作的點子。

  [Haskell.js]: https://github.com/CindyLinz/Haskell.js
  [PatBind-loop]: https://github.com/CindyLinz/Haskell.js/blob/76139a0aeebecfa40f890befd9e143217d9f82c9/trans/src/Desugar/PatBind.hs#L8
  [STM-SVG]: http://cindylinz.github.io/Talk-HaskellSTM/#29
  [struct-view.js]: https://github.com/CindyLinz/Talk-HaskellSTM/blob/4995e239a5128f83418b8c08b56925b3c2a5363c/struct-view.js
  [newLink]: https://github.com/CindyLinz/Talk-HaskellSTM/blob/4995e239a5128f83418b8c08b56925b3c2a5363c/struct-view.js#L108
  [tuple_con_gen]: https://github.com/CindyLinz/Haskell.js/blob/76139a0aeebecfa40f890befd9e143217d9f82c9/trans/res/prelude-native.js#L38
  [YAHT]: http://www.umiacs.umd.edu/~hal/docs/daume02yaht.pdf
  [BeginningHaskell]: http://www.amazon.com/Beginning-Haskell-Alejandro-Serrano-Mena-ebook/dp/B00HG2CQ1Q/
  [RealWorldHaskell]: http://book.realworldhaskell.org/
  [24Days]: https://ocharles.org.uk/blog/posts/2014-12-01-24-days-of-ghc-extensions.html

# 下次聚會時間

  2016.03.31(四)