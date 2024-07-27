## twgeojson

### 簡介

這個套件提供了台灣行政區劃的 GeoJSON 檔案。資料經過 d3.simplify 函式簡化，適合用於地理可視化。縣市資料檔案大小約為 64KB。

若需要原始資料或不同簡化程度的資料，請參閱 Makefile 了解生成規則。

### 安裝

使用 npm 安裝所有需要的模組，包括 d3：

```
npm install
```

若要建構台灣地理 JSON 檔案，您需要以下工具：

* unrar - 可使用「brew install unrar」或您熟悉的軟體包管理器安裝。

接著，使用 make 指令建構 JSON 檔案：

```
make twVote1982.topo.json
make twVillage1982.topo.json
make twTown1982.topo.json
make twCounty2010.topo.json
```

### 待辦事項

* 合併 2010 年縣市合併中被併入的其他行政區
* 針對 2010 年縣市合併的鄉鎮市區名稱轉換
* 提供鄉鎮市的郵遞區號作為圖層屬性
* 修復 vote/errant.json
* 修復 XXX-1 改為 XXX-0

### 注意

* 我們原本使用 d3-plugins/simplify 簡化輸出的 JSON 檔案，但此函式已標記為過期，已被 TopoJSON 取代並從 GitHub 移除。因此，我們做了一些修改以採用 TopoJSON 格式。請盡量在未來使用 TopoJSON 格式取代 GeoJSON。

### 參考資源

* 內政部營建署全球資訊網：[http://www.iot.gov.tw/ct.asp?xItem=154948&ctNode=1091](http://www.iot.gov.tw/ct.asp?xItem=154948&ctNode=1091)
* d3.js 擴充套件 - simplify：[https://github.com/d3/d3-plugins/tree/master/simplify](https://github.com/d3/d3-plugins/tree/master/simplify)

### 授權

基於法律許可的範圍下，高嘉良已放棄 twgeojson 的所有著作權以及相關或鄰近權利。

本著作發表於台灣。

* 公共領域奉獻宣言 1.0 通用版 (CC0 1.0 Universal)：[http://creativecommons.org/publicdomain/zero/1.0](http://creativecommons.org/publicdomain/zero/1.0)
