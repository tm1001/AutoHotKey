; ===========================================================
; 【補足】
; ・SendText()はIMEをバイパスして直接文字を入力するため、IME ONでも半角で入力される。
;   IMEの通常動作（全角/ひらがな/カタカナ等）を活かしたい場合はSendを使う。
; ・AutoHotKeyで特殊記号（^ + { } ' " \ など）を送信する場合は、Send "{記号}" のように波括弧で囲む必要がある。
;   例：Send "{^}"、Send "{+}"、Send "{{}"、Send "{}}" など。
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

;vkE2:: return    ; Copilotキー（MS IME/ATOK等で使われる場合あり）

#HotIf !usMode
; USモードがオフの時 カタカナ、変換、無変換キーを無効化
vkF1:: return    ; カタカナキー
vk0C:: return    ; 変換キー
vk0D:: return    ; 無変換キー
#HotIf

; --- US配列エミュ（ON時だけ有効）---
#HotIf usMode

; --- 数字 Shift 記号 を変換(VK + SC )
; shift 2 ⇒ @
+vk32:: Send "@"
+sc003:: Send "@"

+vk36:: Send "{^}"
+sc007:: Send "{^}"  ; 6

+vk37:: Send "&"
+sc008:: Send "&"  ; 7
+vk38:: Send "*"
+sc009:: Send "*"  ; 8

+vk39:: Send "("
+sc00A:: Send "("  ; 9

+vk30:: Send ")"
+sc00B:: Send ")"  ; 0

; --- 記号キー群（必要分のみ抜粋。こちらも SendText 推奨）---
; ; :
vkBA:: Send ";"
+vkBA:: Send ":"
sc027:: Send ";"
+sc027:: Send ":"

; / ?
vkBF:: Send "/"
+vkBF:: Send "?"
sc035:: Send "/"
+sc035:: Send "?"

; - _
vkBD:: Send "-"
+vkBD:: Send "_"
sc00C:: Send "-"
+sc00C:: Send "_"

; [ {
vkDB:: Send "["
+vkDB:: Send "{{}"
sc01A:: Send "["
+sc01A:: Send "{{}"

; ] }
vkDD:: Send "]"
+vkDD:: Send "{}}"
sc01B:: Send "]"
+sc01B:: Send "{}}"

; \ |   （JISの￥キー位置）
vkDC:: Send "\"
+vkDC:: Send "|"
sc02B:: Send "\"
+sc02B:: Send "|"

; ' "
vkDE:: Send "'"
+vkDE:: Send '"'
sc028:: Send "'"
+sc028:: Send '"'

; = +
vkBB:: Send "="
+vkBB:: Send "{+}"
sc00D:: Send "="
+sc00D:: Send "{+}"

; , <
vkBC:: Send ","
+vkBC:: Send "<"
sc033:: Send ","
+sc033:: Send "<"

; . >
vkBE:: Send "."
+vkBE:: Send ">"
sc034:: Send "."
+sc034:: Send ">"

; JIS専用キー（vkE2）→ \ と _
; USキーボードの \ キーは一般的に sc056 だが機種依存で違う可能性もある
vkE2:: Send "\"
+vkE2:: Send "_"
sc056:: Send "\"
+sc056:: Send "_"

; ` / ~（Escの下のUSキー）
vkC0:: Send "``"    ; ` （バッククォート）
+vkC0:: Send "~"     ; Shift+` → ~
sc029:: Send "``"
+sc029:: Send "~"

#HotIf