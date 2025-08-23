; ===========================================================
; 【キーボード入力レイヤー整理】
;
; 1. Scan Code (SC: スキャンコード)
;    - キーボードハードウェアが出す「物理キー位置」の番号。
;    - PC/AT互換規格 (Scan Code Set 2) でほぼ固定されている。
;    - 例: 数字段「2」→ SC003, Esc下「`」→ SC029。
;    - 機種依存性は少なく、レイアウト(JIS/US)に左右されない。
;
; 2. Virtual-Key Code (VK: 仮想キーコード)
;    - Windows が SC を受け取り、論理的に割り当てた番号。
;    - OSのキーボードレイアウトDLL (kbd106.dll, kbdus.dll 等) に依存する。
;    - 例: SC003 → VK32 (数字2のキー)。ただしShift時の出力はレイアウトで変化。
;
; 3. 出力文字
;    - 最終的にどんな文字が出るかは「VK → 文字」変換で決まる。
;    - これは OS に設定されたキーボードレイアウト (JIS/US) によって異なる。
;    - 例: Shift+2 → JIS = "、US = @。
;
; ■本スクリプトの方針
; - OS設定は常に JIS 固定とする。
; - その上で AutoHotkey で「US配列の見かけ」をエミュレーション。
; - 差分が出るキーのみ VK/SC を捕まえて文字を上書き送信。
; - 環境によって VKだけでは効かない場合 (# や \ 等) があるので、
;   必要なキーは SC も併記して堅牢にする。
; ===========================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

global usMode := false

^!u:: {
    global usMode
    usMode := !usMode
    TrayTip "US配列エミュレーション → " (usMode ? "ON" : "OFF")
}

; --- US配列エミュ（ON時だけ有効）---

#HotIf usMode

; --- 数字 Shift 記号 を変換(VK + SC )
; shift 2　⇒ @
+vk32:: SendText("@")
+sc003:: SendText("@")

+vk36:: SendText("^")
+sc007:: SendText("^")  ; 6

+vk37:: SendText("&")
+sc008:: SendText("&")  ; 7
+vk38:: SendText("*")
+sc009:: SendText("*")  ; 8

+vk39:: SendText("(")
+sc00A:: SendText("(")  ; 9

+vk30:: SendText(")")
+sc00B:: SendText(")")  ; 0

; --- 記号キー群（必要分のみ抜粋。こちらも SendText 推奨）---
; ; :
vkBA:: SendText(";")
+vkBA:: SendText(":")
sc027:: SendText(";")
+sc027:: SendText(":")

; / ?
vkBF:: SendText("/")
+vkBF:: SendText("?")
sc035:: SendText("/")
+sc035:: SendText("?")

; - _
vkBD:: SendText("-")
+vkBD:: SendText("_")
sc00C:: SendText("-")
+sc00C:: SendText("_")

; [ {
vkDB:: SendText("[")
+vkDB:: SendText("{")
sc01A:: SendText("[")
+sc01A:: SendText("{")

; ] }
vkDD:: SendText("]")
+vkDD:: SendText("}")
sc01B:: SendText("]")
+sc01B:: SendText("}")

; \ |   （JISの￥キー位置）
vkDC:: SendText("\")
+vkDC:: SendText("|")
sc02B:: SendText("\")
+sc02B:: SendText("|")

; ' "
vkDE:: SendText("'")
+vkDE:: SendText('"')
sc028:: SendText("'")
+sc028:: SendText('"')

; = +
vkBB:: SendText("=")
+vkBB:: SendText("+")
sc00D:: SendText("=")
+sc00D:: SendText("+")

; , <
vkBC:: SendText(",")
+vkBC:: SendText("<")
sc033:: SendText(",")
+sc033:: SendText("<")

; . >
vkBE:: SendText(".")
+vkBE:: SendText(">")
sc034:: SendText(".")
+sc034:: SendText(">")

; JIS専用キー（vkE2）→ \ と _
; USキーボードの \ キーは一般的に sc056 だが機種依存で違う可能性もある
vkE2:: SendText("\")
+vkE2:: SendText("_")
sc056:: SendText("\")
+sc056:: SendText("_")

; ` / ~（Escの下のUSキー）
vkC0:: SendText("``")    ; ` （バッククォート）
+vkC0:: SendText("~")     ; Shift+` → ~
sc029:: SendText("``")
+sc029:: SendText("~")

#HotIf