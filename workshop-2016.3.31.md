# 本次目標

  * demo 成果 / 半成品

    + Lambda Interpreter

    + Haskell Web 應用

# [Haskell-HVG][Haskell-HVG]

  * CindyLinz demo 了 Haskell-HVG ，提到初衷來自在 Skymizer 那場 STM 演講中的一張 SVG 圖。

  * 畫的圖是有結構的，希望搬動時，可以保持一些結構，像是連線之類的。

    * caasi 好奇為什麼 JS 版自己做 transformation ？

  * [JavaScript 版][struct-view.js]是用 SVG 做的，在 Haskell 用的是 HTML5 Canvas 。

  * 接著 CindyLinz 介紹了一下 HTML5 Canvas 要怎麼用，簡介了一下像是 `strokeStyle` 之類的基本功能。

  * CindyLinz 介紹了 Haskell-HVG 吐出來的 Canvas code ：

    ```HTML
    <!Doctype html>
    <canvas width=1200 height=800></canvas>
    <script>
    (function(canvas){
      if( !document ) return;
      var canvas = document.querySelector("canvas")
      if( !canvas ) return;
      var ctx = canvas.getContext('2d');
    ctx.strokeStyle = "#000";
    ctx.setTransform(1.0,0.0,0.0,1.0,450.0,10.0);
    ctx.lineWidth = 2.0;
    ctx.lineWidth = 3.0;
    ctx.strokeRect(0.0,0.0,100.0,590.0);
    ctx.setTransform(1.0,0.0,0.0,1.0,450.0,10.0);
    ctx.textBaseline = "middle";
    ctx.textAlign = "center";
    ctx.font = "15px sans-serif";
    ctx.fillStyle = "#000";
    ctx.fillText("world",50.0,15.0);
    ctx.strokeStyle = "#000";
    ctx.setTransform(1.0,0.0,0.0,1.0,460.0,50.0);
    ctx.lineWidth = 2.0;
    ctx.beginPath();
    ctx.moveTo(0.0,30.0);
    // 後略
    ```

  * 接著簡介 Haskell-HVG 中用到的高階結構，怎麼樣把世界座標和相對座標轉換：

    [src/HVG/ContextState.hs][ContextState.hs]

    ```Haskell
    setTransform :: Matrix -> Builder ()
    setTransform val = Builder $ \ctx bld -> BuilderPartDone ctx{ctxTransform = val} bld ()
    getTransform :: Builder Matrix
    getTransform = Builder $ \ctx bld -> BuilderPartDone ctx bld (ctxTransform ctx)
    applyTransform :: Matrix -> Builder ()
    applyTransform val = Builder $ \ctx bld -> BuilderPartDone ctx{ctxTransform = ctxTransform ctx <> val} bld ()
    ```

    [test/Entity.hs][Entity.hs]

    ```Haskell
    box :: Double -> Double -> Double -> Double -> Int -> [Builder ()] -> Builder ()
    box x y w h level bodies = local $ do
      applyTransform (translateMatrix x y)
      setSize (Size w h)
      tran <- getTransform

      addDraw $ do
        strokeStyle "#000"
        transform tran
        -- 後略
    ```

  * livedemo 時是靠一隻 Perl script 在背景自動 exec 並 reload 。

  * `addLink` 的接點是自動算出來的。

  * box 裡面會給一個 list ，還有它被切成幾間房間。

    * 註：指的是 `box x y w h level bodies = local $ do` 中的 level 與 bodies 。或 JS 版中的 `var newBox = function(x, y, w, h, level, p, opts)` 中的 level 。在 JS 版中，不用給出 bodies 或 children ，而是讓 children 知道 parent `p` 。

  * 有加上像是群組的東西：「心中會想著，他們是一組的」，可以整組一起移動。

  * 拉線時是用名字拉的。本來想過留下參考，最後為了方便，是用名字拉線。

    * 註： JS 版中是這樣拉的：

      ```JavaScript
      var box1 = newBox(10, 10, 100, 100, 1, root, {text: ['hello']});
      var box2 = newBox(10, 130, 100, 100, 1, root, {text: ['world']});
      newLink(box1, box2);
      ```

  * （和 JS 版不同）可以拉曲線（來 Link ）。

    ```Haskell
		curveLink :: String -> String -> Builder ()
		curveLink aName bName = fork $ do
			aLink <- queryLink aName
			bLink <- queryLink bName
			let
				bestLinkPair n aLink bLink =
					fst $ foldl
						(\(best, bestDis) (cha, chaDis) ->
							if bestDis <= chaDis then
								(best, bestDis)
							else
								(cha, chaDis))
						((Point 0 0, Point 0 0), 1/0)
						[ ((a, b), aCost + pointDistance a b + bCost)
						| LinkPoint a aCost <- take n aLink
						, LinkPoint b bCost <- take n bLink]

				(aEnd, bEnd) = bestLinkPair 64 aLink bLink

				Point x1 y1 = aEnd
				Point x2 y2 = bEnd


			addDraw $ do
				transform identityMatrix
				strokeStyle "#000"

				lineWidth 1

				beginPath

				moveTo aEnd
				if abs (x1 - x2) < 10 || abs (y1 - y2) < 10 then
					lineTo bEnd
				else if abs (x1 - x2) < abs (y1 - y2) then
					bezierCurveTo
						(Point x1 (y1 + 40 * (y2 - y1) / abs (y2 - y1)))
						(Point x2 (y2 - 40 * (y2 - y1) / abs (y2 - y1)))
						bEnd
				else
					bezierCurveTo
						(Point (x1 + 40 * (x2 - x1) / abs (x2 - x1)) y1)
						(Point (x2 - 40 * (x2 - x1) / abs (x2 - x1)) y2)
						bEnd

				stroke

			addLink [LinkPoint (interpolatePoint aEnd bEnd 0.5) 0]
    ```

  * SVG 會給很多參數，但 CindyLinz 覺得應該專注在自己要處理的問題上，低階的東西寫一遍就好。

  * 介紹了什麼是 [DSL][DSL] ，這些高階結構都是額外在這個世界裡面定義出來的名詞。還不清楚要做什麼，但知道環境長什麼樣子時，就可以定義這樣的語言來解決問題。至於要做得多有彈性，是門藝術。

  * 在 Haskell 中叫做 eDSL ， e 指的是 embedded ，表示是內嵌在 Haskell 中的。

  * 介紹 `drawCanvas` 時，順便介紹了在 Haskell 中對參數的看法。在比較複雜的狀況中，像是開了另外一個子空間（這裡指的是 `Builder ()` ）

  * `addLink`, `addDraw` 時又開了 `Builder ()` 下的另外一個子空間 `Draw` ，其實就是輸出用的 `IO ()` 。

  * 現在環境不是 browser ，所以無法取得正確的字型大小。

  * LCamel 提到是否可以先傳回一個預期的大小， CindyLinz 提到可能加一個 Promise 什麼的，如果 Haskell.js 一直做不出來，希望不在 browser 跑的話，也許會做。

  * LinkPoint 的定義是一個點，然後標上哪一個點最不受歡迎（Cost）。

    ```Haskell
    data LinkPoint = LinkPoint Point Cost deriving Show
    ```

  * JS 版本來遇上幾個點都是一樣距離時，會選到比較不好看的點。後來加上離中心的距離才解決。

    * 註： JS 版選點時不只看點的距離，還看兩點離圖形中心的距離 `link[i].d`  ：

      ```JavaScript
      for(i=0; i<a.link.length; ++i)
        for(j=0; j<b.link.length; ++j){
          dis2 = Math.sqrt(sqr(a.link[i].x-b.link[j].x) + sqr(a.link[i].y-b.link[j].y)) + a.link[i].d + b.link[j].d;
          if( dis2 < dis ){
            i0 = i;
            j0 = j;
            dis = dis2;
          }
        }
      ```

  * Haskell 版不是八個點，可以是無窮多點。把 0~1 切無窮多點，而且前 k 個看起來是均勻的。（註： sepSeries 給 2 的冪次是均勻的）

    ```Haskell
    {- sepSeries
      0
      1/2
      1/4 3/4
      1/8 3/8 5/8 7/8
      1/16 3/16 5/16 7/16 9/16 11/16 13/16 15/16
      ...
    -}
    ```

  * 思路是先取一半，再放其左半和右半，讓它交錯，混著出現。

    ```Haskell
    sepSeries :: [Double]
    sepSeries = 0 : inners where
      inners = 0.5 : mix halfs (map (+ 0.5) halfs)
      halfs = map (/ 2) inners
      mix (a:as) (b:bs) = a : b : mix as bs
    ```

  * 畫圖時用到 64 個點，也可以設成 4 個點。試到 256 發現它有點慢， 64 是個還不錯的數字。

  * 沒有用到 Haskell 很難的 extension ，但是 code 本身還滿難的。發現自己寫出了五六年前讀的 code 中那種很難的 type 。

    * CindyLinz 表示當年看不懂的 package 是 [Conduit][Conduit] ：

      「你看那個 data Pipe, 和這次的 data BuilderPart 有類似的構造.. 不過他的參數多很多」

      「他是 Michael Snoyman a.k.a. snoyberg a.k.a. Yesod 作者 a.k.a. Stack 作者 a.k.a. Conduit 作者」

  * 和靜態結構有關的程式碼（`box`, `ellipse` 下面的），和與靜態結構無關的程式碼（`link` 和 `name`）。

  * 畫 link 時，可能 `name "b"` 還沒出現，要等 `name "b"` 出現才會繼續跑。

  * `curveLink` 變得複雜就是為了達成上述的事情。為了在 browser 跑，並沒有用到 thread 。它會保存一下，準備要執行的程式。（**應補上程式**）

  * 「Monad 是個 programmable 的 ; 」， CindyLinz 表示這是看待 Monad 的一種角度。可以保存下現在執行的狀態，等到繼續跑的時候，用之前存下的畫筆狀態，但是有沒有 `name "a"` 存在，則是用當下的狀態。

  * 接著介紹 `Builder` 。 `Builder` 吃兩個狀態，一個是 `ContextState` ，來自 Canvas 文件中可能會用到的狀態。

  * `ContextState` 的設計邏輯是「狀態都在，要不要用自己決定」。

  * `local` 外面不受影響，但是 `local` 裡面就會改變。

  * `ContextState` 會隨著程式碼的結構做變化。

  * `BuilderState` 則是不會隨著程式碼的結構改變，是隨時間改變的東西。

  * `bldNamedDraw` 與 `bldNamedLink` 的功能。

  * 為了靠 `name "a"` 指定「下一個被畫的東西」，會先保存在隨結構變動的 `ContextState` ，畫完才搬到隨時間變動的 `BuilderState` 。

  * `ContextedWaitDrawBuilder` 與 `ContextedWaitLinkBuilder` 系列...

  * `Builder` 是全新的，會有當下的 state ，但 `ContextedWait` 系列的就不用再拿那些 state 。

  * 畫的順序不見得是程式碼的順序。

  * 必須要有個方法，找不到的時候先停下來：

    ```Haskell
    data BuilderPart a
      = BuilderPartDone ContextState BuilderState a
      | BuilderPartWaitDraw String BuilderState (ContextedWaitDrawBuilder a)
      | BuilderPartWaitLink String BuilderState (ContextedWaitLinkBuilder a)
    ```

  * 跟他說可以繼續畫之後，他會給你下一個。

  * Monad 會使用之前的結果，如果前一行沒有被執行，後面是不會被執行的。

  * 如果執行到某處需要暫停，必須記下要暫停到那邊， `fork` 和 `local` 是用來作這件事的。

  * `fork` 和 `local` 不一樣，差個 `a` ， `fork` 在暫停時沒法生個確定的 `a` ，所以給個 `()` 。

  * `BuilderPart` 用來描述程式碼等待的狀態。

  * `BuilderPart` 分三種 case 。 `BuilderPart` 出現 wait 時，就表示整塊程式碼要變成可以 wait 的東西（塞到 `BuilderPart` ）

    ```Haskell
    mapBuilderPart :: (ContextState -> BuilderState -> a -> BuilderPart b) -> BuilderPart a -> BuilderPart b
    mapBuilderPart f = go
      where
      go = \case
        BuilderPartDone ctx bld a -> f ctx bld a
        BuilderPartWaitDraw drawName bld (ContextedWaitDrawBuilder ctxdAAct) ->
          BuilderPartWaitDraw drawName bld $ ContextedWaitDrawBuilder $ \bld' -> go (ctxdAAct bld')
        BuilderPartWaitLink linkName bld (ContextedWaitLinkBuilder ctxdAAct) ->
          BuilderPartWaitLink linkName bld $ ContextedWaitLinkBuilder $ \link bld' -> go (ctxdAAct link bld')

    forBuilderPart :: BuilderPart a -> (ContextState -> BuilderState -> a -> BuilderPart b) -> BuilderPart b
    forBuilderPart = flip mapBuilderPart

    suspendBuilderPartWait :: BuilderPart () -> BuilderState
    suspendBuilderPartWait = \case
      BuilderPartDone _ bld' _ ->
        bld'
      BuilderPartWaitDraw drawName bld' ctxdBld ->
        addBuilderWaitDraw drawName ctxdBld bld'
      BuilderPartWaitLink linkName bld' ctxdBld ->
        addBuilderWaitLink linkName ctxdBld bld'
    ```

  * 有名字的東西出現時，會去看有沒人在等自己，再看執行完後是不是 Done ，還是有在等別的東西。

  * `fork` 的外面都會拿到 Done ， `fork` 的裡面 `suspendBuilderPartWait` ，如果是 Done 就沒事情，如果是 Wait 就加到 Map 裡面去。

  * 本來 `addBuliderWaitDraw` 沒寫成 function ，是出現很多次才抽出來。

		```Haskell
		addBuilderWaitDraw :: String -> ContextedWaitDrawBuilder () -> BuilderState -> BuilderState
		addBuilderWaitDraw drawName ctxdBld bld = bld
			{ bldWaitDraw = M.insertWith (++) drawName [ctxdBld] (bldWaitDraw bld)
			}
		addBuilderWaitLink :: String -> ContextedWaitLinkBuilder () -> BuilderState -> BuilderState
		addBuilderWaitLink linkName ctxdBld bld = bld
			{ bldWaitLink = M.insertWith (++) linkName [ctxdBld] (bldWaitLink bld)
			}
		```

  * `forBuilderPart` 是倒過來的 `mapBuilderPart` 。

		```Haskell
		forBuilderPart = flip mapBuilderPart
		```

  * CindyLinz 表示寫 `mapBuilderPart` 時，看來很複雜的東西，竟然一次 compile 就會過，會有很振奮的感覺。

		```Haskell
		mapBuilderPart :: (ContextState -> BuilderState -> a -> BuilderPart b) -> BuilderPart a -> BuilderPart b
		mapBuilderPart f = go
			where
			go = \case
				BuilderPartDone ctx bld a -> f ctx bld a
				BuilderPartWaitDraw drawName bld (ContextedWaitDrawBuilder ctxdAAct) ->
					BuilderPartWaitDraw drawName bld $ ContextedWaitDrawBuilder $ \bld' -> go (ctxdAAct bld')
				BuilderPartWaitLink linkName bld (ContextedWaitLinkBuilder ctxdAAct) ->
					BuilderPartWaitLink linkName bld $ ContextedWaitLinkBuilder $ \link bld' -> go (ctxdAAct link bld')
		```

  * `fork` 和 `local` 會把名字都歸零。 CindyLinz 表示是對外面歸零， do 裡面才看得到才能用：

    ```Haskell
    -- 大概是...
    ctx{ctxNextDrawName=Nothing, ctxNextLinkName=Nothing}
    ```

  * 沒有歸零時，名字會被後面的東西沿用，然後 CindyLinz 舉了個名字被 `Link` 搶走，以至於後面的 `Link` 都連到前面的 `Link` 上的故事。是的， `Link` 上面可以有 `LinkPoint` 。

  * 覺得湊 Functor 和 Applicative 好像湊 type 的益智遊戲。

  * CindyLinz 舉了非常抽象與非常具體的概念，說明 Monad 是介在其之間的東西。你沒辦法背一個答案來說他是什麼，但是腦袋了解它了。

  * Cindy 表示那是我們沒有一個語言可以描述它。我們已經脫離（幼年）那種講不清楚但是不害怕的階段了，才會害怕（Monad）。

  * LCamel 提到用 imperative 語言會怎麼實作。假設最後所有東西都是 ready 的。

  * Cindy 表示這邊用的是 Monad 的特性，還沒有用到 thunk 的特性。

  * Monad 可以不是一行行執行（IO Monad），那是實作的人決定的。串完以後該怎麼執行，是看實作 Monad 的人怎麼決定。

  * 用其他的語言實作的話，那不是馬上執行的部分，就會包在函數中，讓 runtime 決定該怎麼執行。

  * 作為一個 Monad 實作者，你可以自由地決定要怎麼做。 Monad 實作者看起來的 code 和用 DSL 的人不一樣。舉了 `setFill` 傳回 `Builder ()` 為例，表示這邊用起來就像普通的 type 而不是 Monad 。

    ```Haskell
    setFill :: Maybe String -> Builder ()
    setFill val = Builder $ \ctx bld -> BuilderPartDone ctx{ctxFill = val} bld ()
    ```

    ```Haskell
    -- 讓外面也拿到 Builder 的方法
    exportCxt :: Builder ContextState
    exportCxt = Builder $ \ctx bld -> BulidPartDone ctx bld ctx
    ```

  * Lens 有 template 函數。

  * 但是現在的 [ContextState.hs][ContextState.hs] 是用 vim 巨集生出來的，隨手錄隨手播。沒有用到 Template Haskell 。

  * CindyLinz 表示 `forBuilderPart` 也是後來才 refactor 出來的。 refactor 出來後的東西常常是數學上有名字東西，只是當下不知道。

  * 重新強調了一次兩大類狀態，一是會隨著程式結構改變的，二是會隨時間改變的。

  * Haskell 的 record 和散著一堆參數是一樣的意思，只是讓人方便。

  * Done 跟 Wait 可以說是 Monad 自己要和自己溝通的機制。

  * 曾有一個版本是整個 `fork` 完成了才畫上去。現在的版本可以前半先出去。

  * `addLink` 的 `Just myName` 下的 `bld'` 是把名字存好， `bld''` 下面是看看有沒有人在等，跑出來結果可能是 Done 或 Wait ，如果是 Done 就沒事，如果是 Wait 就繼續，每個在等的人都要做一次。同樣的東西不會等兩次，因為已經有了。新跑的東西會蒐集起來。

    ```Haskell
    addLink :: Link -> Builder ()
    addLink link = Builder $ \ctx bld ->
      case ctxNextLinkName ctx of
        Nothing ->
          BuilderPartDone ctx bld ()

        Just myName ->
          let
            bld' = bld
              { bldNamedLink = M.insert myName link (bldNamedLink bld)
              , bldWaitLink = M.delete myName (bldWaitLink bld)
              }

            bld'' = case M.lookup myName (bldWaitLink bld) of
              Nothing ->
                bld'
              Just ctxdBlds ->
                go bld' ctxdBlds
                where
                  go bld' (ContextedWaitLinkBuilder continue : otherCtxdBlds) =
                    go (suspendBuilderPartWait (continue link bld')) otherCtxdBlds

                  go bld' _ =
                    bld'

          in
            BuilderPartDone ctx{ctxNextLinkName = Nothing} bld'' ()
    ```

  * `addDraw` 的差別只有上面（`Nothing` 那部份），接起來（`>>`），先畫舊的，再畫新的。

    ```Haskell
    addDraw :: Draw -> Builder ()
    addDraw draw = Builder $ \ctx bld ->
      case ctxNextDrawName ctx of
        Nothing ->
          BuilderPartDone
            ctx
            bld{ bldDraw = bldDraw bld >> draw }
            ()
    ```

  * `'`(prime symbol) 的個數寫錯，就會出現平行宇宙...，身為 Monad 實作者，沒有 Monad 可以保護你。寫到 5~6 個 `'` 就會很難過。用數字也沒有意義。有時候會用前面，有時候用後面。

  * 今天講的和 compiler 並沒有直接關係，但希望之後可以搬到 compiler 上面用。

  * 127 提到 eDSL 的限制， CindyLinz 提到函數都要變成吃 `Promise` （Haskell 的，不是 JS 的）。得把 JavaScript 的函數都變成 thunk 。

  * 127 問到如果在 eDSL 中用到其他 Haskell 的 lib 該怎麼辦？ CindyLinz 表示不確定最後 runtime 串起來，在 JavaScript 中也有個好的順序。並舉例：

    ```
    textWithBorder :: String -> Builder ()
    textWithBorder str = local $ do
      addDraw & do
        width <- measureText str "width"
        strokeRect (Point 0 0) (Size (width + 10) 20)
    ```

  * 如果拿不到 `width` ，那應該是 `putStrLn "ctx.strokeRect(0, 0, width+40, 20);"`

  * 127 表示這邊的 `width` 就不能用到 Haskell 的能力。 CindyLinz 表示這樣不會犧牲掉本來的程式（eDSL），而且 `width` 已經在被 Context 包起來的低階 Canvas 指令中了。

  * 拿出來的 `width` （在 Haskell 內）不會跟真正的數字一樣好用，但是可以拿來畫框框。

  * 127 好奇這邊的 eDSL 有用到多少 Haskell 的 type safe 。 CindyLinz 表示不小心把 IO 的東西寫到 Builder 會被抓到。又說 127 可以想要的是 Box 和 Cycle 不可以 Link 起來之類的。

  * 比較高階的畫筆可以不碰到低階的指令。不限制那些畫筆也是整個 library 的一部分。

  * 表示比較好看的排版，字型不會用到超過五六種。

  * 畫圖的過程就像是一個整理自己思緒的過程。

  [Haskell-HVG]: https://github.com/CindyLinz/Haskell-HVG
  [struct-view.js]: https://github.com/CindyLinz/Talk-HaskellSTM/blob/2afb20d1bc8ee09126f09d143e0ba9ae73b81815/struct-view.js
  [ContextState.hs]: https://github.com/CindyLinz/Haskell-HVG/blob/f6e9401648943e13bcf801c7b5e25400c90606c1/src/HVG/ContextState.hs
  [Entity.hs]: https://github.com/CindyLinz/Haskell-HVG/blob/f6e9401648943e13bcf801c7b5e25400c90606c1/test/Entity.hs
  [DSL]: https://en.wikipedia.org/wiki/Domain-specific_language
  [Conduit]: https://hackage.haskell.org/package/conduit-1.2.6.4/docs/src/Data-Conduit-Internal-Pipe.html#Pipe

# 雜談

  * `<embed src="sth.svg"></embed>` 才能在 SVG 中用 JS ，用 `<img>` 不會執行。

  * JS 中又要用 `xlink` ，前面得 import 其他東西。（註：指的應該是在 `<svg>` 加上 `xmlns:xlink="http://www.w3.org/1999/xlink"` ）

  * 之所以把 JS 搬到 SVG 中，是不希望投影片中 60% 都是程式。

  * 之前用過 Graphviz ， CindyLinz 表示無法掌握其語法，排版很難控制。用控制寬度來控制高度是一件很慘的事情。

  * 也試過 SVG ，但要改就很慘。畫了 N 張圖，都長得很像，不敢動它們。

  * HTML5 Canvas 沒有橢圓形...。一般都建議用四條 Bezier curve 去拉它。網路上可以查到控制點要怎麼拉是最好的。不過寫一次就可以一直用。

  * Canvas 中可以用到漸層，甚至填滿別的圖片，但那樣就要在 eDSL 中想好該怎樣表示 JS 裡的物件。

  * CindyLinz 覺得 Canvas API 設計上有考慮到塞 array 後偷改 array 內容這種事情。但 Gradient 偷改的話，卻又會用當下改過的那個。

  * Java Swing 等環境，都有限制能動畫面的只有一個 thread 。

  * 如果沒有想好一個資料結構是要放在 socket thread 還是 view thread ，共用就得 lock 。

  * LCamel 表示 HVG 像在一直組 function ，操作的不是 code ，而是那一堆...。

  * compiler 部分未來希望先能手動標 type ，做簡單的 type inference 。

  * CindyLinz 表示沒寫過的東西沒法估時間。在公司多半都在做這樣的事情。喜歡這種狀態，拼拼看。

  * 小秘訣：如果還不熟函式的 type ，可以先偷偷 copy 到要用的地方，用完再砍掉。 CindyLinz 表示以前看過學長寫 C ，會把自動把定義開另外一個 split window 。

  * silverneko 介紹了 [ghcmod-vim][ghcmod-vim] 。 CindyLinz 表示需要在 compile error 時可以自動標明行號的功能。

  * LCamel 介紹了 vim 的 [`:cope[n]`][copen] 。還有 `:grep <var_name> %` 和 `:copen` 配合。

  * 127 表示 vim 靠 `!` 執行的結果應該可以丟到某處，讓 `:copen` 可以用才是。

  * [下次][Funth-37] Funth 是 hack Mozilla ，下下次是 Ur/Web （dependent type）。

  [ghcmod-vim]: https://github.com/eagletmt/ghcmod-vim
  [copen]: http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:copen
  [Funth-37]: http://www.meetup.com/Functional-Thursday/events/229864779/

# 下次聚會時間

  2016.04.14(四)
