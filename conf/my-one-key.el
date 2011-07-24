

(require 'one-key-bind)

(one-key-bind-keymap "ESC <f1>" "<f1>")
(one-key-bind-keymap "ESC <f2>" "<f2>") ;;bookmark, folding
(one-key-bind-keymap "ESC <f3>" "<f3>") ;;operations on current symbol
(one-key-bind-keymap "ESC <f4>" "<f4>") ;;CUA like

(one-key-bind-keymap "<f5> ESC a" "<f5> a") ;;anything
(one-key-bind-keymap "ESC <f5>" "<f5>") ;; anything, ido
(one-key-bind-keymap "ESC <f6>" "<f6>") ;; vi-style keys


(one-key-bind-keymap "ESC <C-f10>" "<C-f10>")
(one-key-bind-keymap "ESC <f10>" "<f10")
(one-key-bind-keymap "ESC <f11>" "<f11>")  ;; winndows-related
(one-key-bind-keymap "ESC <f12>" "<f12>")


