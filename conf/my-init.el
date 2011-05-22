;;(@* "key bindings")
;; <f2>: 2-columns, diff, bookmarks
;; <f3>: operations on current symbol
;; <f4>: cua-like
;; <f5>: selection and perform
;; <f5> a: anything
;; <f6>: vi style commands
;; <C-f10>:  some settings
;; <f11>: window-related commands (`super' modifier)
;; <f12>: misc stuff

(when (eq window-system 'w32)
  ;;(setq w32-lwindow-modifier 'super)
  
  (setq w32-lwindow-modifier 'nil)
  (setq w32-pass-lwindow-to-system nil)
  (define-key key-translation-map (kbd "<lwindow>") (kbd "<f11>"))

  ;; (setq w32-rwindow-modifier 'alt)      
  (setq w32-rwindow-modifier 'nil)
  (setq w32-pass-rwindow-to-system nil)
  (define-key key-translation-map (kbd "<rwindow>") (kbd "C-c"))
  
  (setq w32-apps-modifier 'alt)
  )
  

;;FIXME: not work
(when (eq window-system 'x)
  (define-key key-translation-map (kbd "<super>") (kbd "<f11>"))
  )

(global-unset-key (kbd "<f2>"))
(global-unset-key (kbd "<f3>"))
(global-unset-key (kbd "<f4>"))
(global-set-key (kbd "<f3> f") 'find-function-at-point)
(global-set-key (kbd "<f3> F") 'find-function)
(global-set-key (kbd "<f3> v") 'find-variable-at-point)
(global-set-key (kbd "<f3> V") 'find-variable)
(global-set-key (kbd "<f3> l") 'find-library)
(global-set-key (kbd "<f3> C-f") 'ffap-other-window)





;;(@* "editing")
;; make M-z behave more as zap-up-to-char
(defun zap-uo-to-char (arg char)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR.
  The CHAR is replaced and the point is put before CHAR."
    (interactive "p\ncZap to char: ")
    (zap-to-char arg char)
    (insert char)
    (forward-char -1))

(global-set-key (kbd "M-z") 'zap-up-to-char)


;;---
;; Move line up/down. Stolen from org-mode's M-up/down
;; TODO: support region (move region line up/down)
;; see also:  (@file :file-name "drag-stuff.el" :to "define-minor-mode drag-stuff-mode")
(defun swap-line-up ()
  "Swap the current line with the line above."
  (interactive)
  (transpose-lines 1)
  (beginning-of-line -1))

(defun swap-line-down ()
  "Swap current line with the line below."
  (interactive)
  (beginning-of-line 2) (transpose-lines 1) (beginning-of-line 0))

(if (load "drag-stuff" t)
    (progn
      (global-set-key (kbd "<M-up>") 'swap-line-up)
      (global-set-key (kbd "<M-down>") 'swap-line-down)
      )
  (progn
;;    (setq drag-stuff-modifier 'hyper)
    (add-to-list 'drag-stuff-except-modes 'org-mode)
    (drag-stuff-global-mode t)))


;; vi-style join-line
(defun join-line ()
  "Join the following line with current line"
  (interactive)
  (delete-indentation 1))

(global-set-key (kbd "C-c j") 'join-line)

;;(@* "completion")

;;-- ido
(require 'ido)
(unless (fboundp 'ido-common-initialization)   ;;workaround for emacs 23.1's bug(?)
  (defun ido-common-initialization ()
    (ido-init-completion-maps)
    (add-hook 'minibuffer-setup-hook 'ido-minibuffer-setup)
    (add-hook 'choose-completion-string-functions 'ido-choose-completion-string))
  )
(setq ido-everywhere t)
(ido-mode t)

(autoload 'idomenu "idomenu" "Switch to a buffer-local tag from Imenu via Ido." t)

;;-- smex : ido for M-x
(when (require 'smex nil t)
  (smex-initialize)
  
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "ESC M-x") 'execute-extended-command))


;;-- anything
(when (and (load "anything" t)
	  (load "anything-config" t))
  ;;enable multiple keyword/regexp match
  ;;(load "anything-match-plugin" t) ;;FIXME: would cause crash?
  ;;(global-set-key (kbd "M-x") 'anything-M-x)
  
  (global-set-key (kbd "<f5> r") 'anything-recentf)
  (global-set-key (kbd "<f5> b") 'anything-buffers+)
  (global-set-key (kbd "<f5> B") 'anything-bookmarks)
  (global-set-key (kbd "<f5> l") 'anything-locate)
  (global-set-key (kbd "<f5> c") 'anything-browse-code)
  (global-set-key (kbd "<f5> i") 'anything-imenu)
  (global-set-key (kbd "<f5> o") 'anything-occur)
  )

;;--- dabbrev 
(autoload 'dabbrev-expand-multiple "dabbrev-expand-multiple" "dynamic abbrev expansion for multiple selection" t)
(setq dabbrev-expand-multiple-select-keys '("a" "s" "d" "f" "g" "q" "w" "e" "r" "t"))
(global-set-key (kbd "C-c /") 'dabbrev-expand-multiple)

;;-- auto-compelte
(when (and (load "auto-complete" t)
	  (load "auto-complete-config" t))
    
      (ac-config-default)
      (add-hook 'lisp-interaction-mode 'ac-emacs-lisp-mode-setup)

      (when (load "auto-complete-scite-api" t)
        (add-to-list 'ac-sources 'ac-source-scite-api))
      )

;; use `pos-tip' to fix the popup window position issue
(when (require 'popup-pos-tip)
  (defadvice popup-tip
    (around popup-pos-tip-wrapper (string &rest args) activate)
    (if (eq window-system 'x)
        (apply 'popup-pos-tip string args)
      ad-do-it)))


;;(@* "viper")
(ignore-errors
  (require 'undo-tree)
  (global-undo-tree-mode))

(eval-after-load 'viper
  '(require 'vimpulse))

(setq viper-expert-level '3)
(setq viper-inhibit-startup-message 't)

;;(@* "some important third party libraries")
;;-- buffer-local bookmarks
(when (load "bm" t)
    (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'bm-toggle-mouse)
    (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'bm-previous-mouse)
    (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'bm-next-mouse))
;;see also: (@file :file-name "linemark.el" :to "enable-visual-studio-bookmarks")

;;-- tabbar
;; ide-skel would group buffers into two: editing buffer, emacs buffer
(load "ide-skel" t)

;; if you use `ide-ske', don't directly load `tabbar' after `ide-ske'
;; as this would mess up the tab group definition of `ide-skel'
(when (or (featurep 'tabbar)
          (load "tabbar" t))
      (global-set-key (kbd "<C-tab>") 'tabbar-forward)
      (global-set-key (kbd "<C-S-tab>") 'tabbar-backward))


;;(@* "code folding")
(autoload 'hideshowvis-enable "hideshowvis" "Add markers to the fringe for regions foldable by `hideshow-mode'." t)
(autoload 'hideshowvis-minor-mode "hideshowvis" "Will indicate regions foldable with hideshow in the fringe." 'interactive)

(eval-after-load 'hideshowvis '(load "hideshow-fringe" t))

(add-hook 'emacs-lisp-mode-hook 'hideshowvis-enable)
(add-hook 'python-mode-hook 'hideshowvis-enable)

(define-key hs-minor-mode-map (kbd "C-+")  'hs-toggle-hiding)


;;(@* "some visual effect")
(autoload 'highlight-symbol-at-point "highlight-symbol" "Toggle highlighting of the symbol at point." t)
(global-set-key (kbd "<double-down-mouse-1>") 'highlight-symbol-at-point)

(autoload 'highlight-indentation "highlight-indentation" "Toggle highlight indentation." t)


;;-- linkd: visualize section header & links (to file/man/info/url)
(when (require 'linkd nil t)
  (let ( (dir (concat (file-name-directory (locate-library "linkd")) "icons")) )
    (when (file-exists-p dir)
        (setq linkd-icons-directory dir)
      (setq linkd-use-icons t)))
  (add-hook 'emacs-lisp-mode-hook 'linkd-enable)
  (add-hook 'python-mode-hook 'linkd-enable)
  (add-hook 'espresso-mode-hook 'linkd-enable))

;;(@* "misc")

(setq rj-column-threshold 100)
(load "recent-jump" t)
(global-set-key (kbd "C-c <") 'recent-jump-backward)
(global-set-key (kbd "C-c >") 'recent-jump-forward)

 ;;FIXME
(autoload 'idle-require-mode "idle-require" "Load unloaded autoload functions when Emacs becomes idle." t)
;; (setq idle-require-symbols '(cedet nxml-mode)) ;; <- Specify packages here.
;;(idle-require 'my-cua-keys)
;;(idle-require 'my-win-fns)
;;(idle-require 'my-misc)
;;(idle-require 'my-one-key)   ;; <- Or like this.
;;  (idle-require-mode 1)

;;

(load "~/.emacs.d/conf/my-word-ops" t)
(load "~/.emacs.d/conf/my-cua-keys" t)
(load "~/.emacs.d/conf/my-vi-keys" t)
(load "~/.emacs.d/conf/my-win-fns" t)
;;(load "my-options-cmds" t) ;;TODO
(load "~/.emacs.d/conf/my-misc" t)
(load "~/.emacs.d/conf/my-one-key" t)
;;(load "hyper-key-bindings" t)






	 
  
