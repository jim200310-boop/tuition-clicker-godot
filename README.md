# 打工魂：學費大作戰

以 Godot 4 製作的繁體中文放置點擊小遊戲。玩家扮演大學生 Jim，透過手動打工、休息，以及投資自動工作站存下 100,000 元學費。

## 遊玩方式

- 點「開始打工」賺取 $500，並消耗 8 點體力。
- 點「休息充電」恢復 25 點體力。
- 聘用便利商店夥伴、課後家教、城市外送員，取得每秒被動收入。
- 存款達 $100,000 過關；體力歸零時挑戰結束。
- 支援滑鼠和觸控，網頁畫面會隨視窗縮放。

## 執行與匯出

使用 Godot 4.6 或更新的 Godot 4 開啟 `project.godot`。Web 匯出預設為 `Web`，目標是 `docs/index.html`，且已關閉 Thread Support。算繪器使用 Compatibility。

在 Godot 編輯器選擇 **Project > Export > Web > Export Project**，匯出至 `docs/index.html`。遊戲的 Web 匯出會同時產生 `.wasm`、`.pck`、JavaScript 和音訊工作檔，這些檔案都要一併部署。

## 授權與署名

中文字型使用 [Noto Sans TC](https://fonts.google.com/noto/specimen/Noto+Sans+TC)，依 SIL Open Font License 授權。遊戲署名：**資通四勤 121271101 許濬鵬**。
