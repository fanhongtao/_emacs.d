(require 'one-key)

;; 前面说了，我开始大量采用功能键做前缀，但短时间内有点记不过来。在
;; emacswiki上找了一个one-key.el，但自己一个个配菜单太麻烦了，
;; one-key-default.el 也试了一下，有些行为是我不期望的。于是自己做了一
;; 个封装:

(defun one-key-bind-keymap (key keymap-prefix &optional menu-name)
  "Generate an one-key menu for keys starting with `keymap-prefix', and bind it to `key'.

It also bind `keymap-prefix'-? to the same one-key menu, if not in use.

For example, when called with ('ESC <f1>', '<f1>'), it would
generate one-key menu 'one-key-menu-<f1>', and bind 'ESC <f1>'
and '<f1> ?' to one-key-menu-<f1>."
  (if (keymapp (key-binding (read-kbd-macro keymap-prefix)))
      (let ( (one-key-menu-sym (intern
                                (if menu-name
                                    (concat "one-key-menu-" menu-name)
                                  (format "one-key-menu-%s"
                                          (replace-regexp-in-string " " "-" keymap-prefix))))) )
        (let ( (prefixed-?-key (read-kbd-macro (concat keymap-prefix " ?"))) )
          (unless (key-binding prefixed-?-key)
            (global-set-key prefixed-?-key one-key-menu-sym)))
        (with-temp-buffer
          (one-key-insert-template keymap-prefix (or menu-name keymap-prefix))
          (eval-buffer))
        (global-set-key (read-kbd-macro key) one-key-menu-sym))
    (message "'%s' is not a keymap-prefix" keymap-prefix)))


;;; example usage:
;;(one-key-bind-keymap "ESC <f1>" "<f1>")
;;(one-key-bind-keymap "ESC C-," "C-," "completion")


(defun one-key-refresh-fkey (fkey)
  (interactive "sfkey: ")
  (one-key-bind-keymap (concat "ESC " fkey) fkey))


;; 与one-key-default的不同在于，这种配置方式下，"ESC <f5>"和"<f5> ?"被
;; 绑定到one-key-menu-<f5>，而原有<f5>功能不会被取代，这样你可以添加新
;; 的绑定(比如"<f5> k")，可以用"<f5> C-h"获取<f5>开头的bindings list。
;; 当然，one-key-menu-<f1>不会自动更新（即后添加的<f5> k"不会自动进入
;; one-key-menu-<f5>，但可以再执行一遍(one-key-bind-keymap "ESC <f5>"
;; "<f5>")来更新)

(provide 'one-key-bind)

