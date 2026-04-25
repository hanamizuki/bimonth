# Bimonth

macOS 桌面雙月月曆 widget。並排顯示兩個月，依目前日期動態切換顯示範圍，讓你同時看到「最近的過去」與「即將到來的未來」。

詳細規格見 `docs/spec.md`。

## 顯示範圍切換

| 條件 | 左側月份 | 右側月份 |
|------|---------|---------|
| 1–6 號 | 上個月 | 本月 |
| 7–31 號 | 本月 | 下個月 |

## 開發環境

- macOS 14（Sonoma）以上
- Xcode 15 以上
- [xcodegen](https://github.com/yonaskolb/XcodeGen)（`brew install xcodegen`）

## 第一次設定

```bash
cd ~/Agents/nana/repos/bimonth
xcodegen generate
open Bimonth.xcodeproj
```

第一次開啟時 Xcode 會要求選擇 Development Team（用 Apple ID 個人開發者帳號即可），兩個 target（`Bimonth` 和 `BimonthWidget`）都要選。

## 跑 widget

1. 在 Xcode 選 `Bimonth` scheme，Build & Run（會啟動 container app）
2. 桌面右鍵 → Edit Widgets → 找到 `Bimonth` → 拖到桌面或通知中心

## 跑單元測試

```bash
xcodebuild test -project Bimonth.xcodeproj -scheme Bimonth -destination 'platform=macOS'
```

或在 Xcode 按 ⌘U。

## 專案結構

```
bimonth/
├── project.yml                     # xcodegen 設定，.xcodeproj 由此生成
├── Bimonth/                        # Container app（最小化，僅為了承載 widget extension）
│   ├── BimonthApp.swift
│   ├── ContentView.swift
│   ├── Bimonth.entitlements
│   └── Assets.xcassets/
├── BimonthWidget/                  # Widget extension（widget 本體）
│   ├── BimonthWidgetBundle.swift   # @main WidgetBundle
│   ├── BimonthWidget.swift         # Widget configuration
│   ├── Provider.swift              # TimelineProvider
│   ├── CalendarEntry.swift         # TimelineEntry model
│   ├── Info.plist
│   ├── BimonthWidget.entitlements
│   ├── Logic/
│   │   └── MonthResolver.swift     # 決定顯示哪兩個月的純函式
│   ├── Views/
│   │   ├── CalendarWidgetView.swift
│   │   ├── MonthView.swift
│   │   └── DayCell.swift
│   └── Assets.xcassets/
└── BimonthTests/
    └── MonthResolverTests.swift    # MonthResolver 邊界情境測試
```
