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
  (setq w32-rwindow-modifier 'alt)
  (setq w32-apps-modifier 'hyper)
  
  (setq w32-lwindow-modifier 'nil)
  (setq w32-pass-lwindow-to-system nil)
  (define-key key-translation-map (kbd "<lwindow>") (kbd "<f11>")))

;;FIXME: not work
(when (eq window-system 'x)
  (define-key key-translation-map (kbd "<super>") (kbd "<f11>"))
  )


(global-unset-key (kbd "<f3>"))
(global-unset-key (kbd "<f4>"))
(global-set-key (kbd "<f3> f") 'find-function-at-point)
(global-set-key (kbd "<f3> v") 'find-variable-at-point)
(global-set-key (kbd "<f3> l") 'find-library)
(global-set-key (kbd "<f3> F") 'ffap-other-window)

(global-unset-key (kbd "<f12> l"))
(global-set-key (kbd "<f12> l l") 'load-library)
(global-set-key (kbd "<f12> l t") 'load-theme)

(global-set-key (kbd "<f12> e b") 'eval-buffer)
(global-set-key (kbd "<f12> e r") 'eval-region)
(global-set-key (kbd "<f12> e f") 'eval-defun)
(global-set-key (kbd "<f12> e s") 'eval-sexp)

;;(@*)

;;(@* "editing")
;; make M-z behave more as zap-up-to-char
(defadvice zap-to-char (after my-zap-to-char-advice (arg char) activate)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR.
  The CHAR is replaced and the point is put before CHAR."
    (insert char)
    (forward-char -1))

;;---
;; Move line up/down. Stolen from org-mode's M-up/down
;; TODO: support region (move region line up/down)
(defun swap-line-up ()
  "Swap the current line with the line above."
  (interactive)
  (transpose-lines 1)
  (beginning-of-line -1))

(defun swap-line-down ()
  "Swap current line with the line below."
  (interactive)
  (beginning-of-line 2) (transpose-lines 1) (beginning-of-line 0))

(global-set-key (kbd "<M-up>") 'swap-line-up)
(global-set-key (kbd "<M-down>") 'swap-line-down)
;;(@*)


;;(@* "ido")


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

(when (require 'smex nil t)
  (smex-initialize)
  
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "ESC M-x") 'execute-extended-command))
;;(@*)


;;(@* "viper")
(eval-after-load 'viper
  '(require 'vimpulse))

(setq viper-expert-level '3)
(setq viper-inhibit-startup-message 't)
;;(@*)

;;(@* "some important third party libraries")
(when (load "bm" t)
    (global-set-key (kbd "<left-fringe> <C-mouse-1>") 'bm-toggle-mouse)
    (global-set-key (kbd "<left-fringe> <C-mouse-4>") 'bm-previous-mouse)
    (global-set-key (kbd "<left-fringe> <C-mouse-5>") 'bm-next-mouse))

(ignore-errors
  (require 'undo-tree)
  (global-undo-tree-mode))

(when (and (load "anything" t)
	  (load "anything-config" t))
  (global-set-key (kbd "<f5> r") 'anything-recentf)
  (global-set-key (kbd "<f5> b") 'anything-buffers+)
  (global-set-key (kbd "<f5> B") 'anything-bookmarks)
  (global-set-key (kbd "<f5> l") 'anything-locate)
  (global-set-key (kbd "<f5> c") 'anything-browse-code)
  (global-set-key (kbd "<f5> i") 'anything-imenu)
  (global-set-key (kbd "<f5> o") 'anything-occur)
  )
  

(when (and (load "auto-complete" t)
	  (load "auto-complete-config" t))
    
      (ac-config-default)
      (add-hook 'lisp-interaction-mode 'ac-emacs-lisp-mode-setup)

      (when (load "auto-complete-scite-api" t)
        (add-to-list 'ac-sources 'ac-source-scite-api)))

;; use `pos-tip' to fix the popup window position issue
(when (require 'popup-pos-tip)
  (defadvice popup-tip
    (around popup-pos-tip-wrapper (string &rest args) activate)
    (if (eq window-system 'x)
        (apply 'popup-pos-tip string args)
      ad-do-it)))


;; ide-skel would group buffers into two: editing buffer, emacs buffer
(load "ide-skel" t)

;; if you use `ide-ske', don't directly load `tabbar' after `ide-ske'
;; as this would mess up the tab group definition of `ide-skel'
(when (or (featurep 'tabbar)
          (load "tabbar" t))
      (global-set-key (kbd "<C-tab>") 'tabbar-forward)
      (global-set-key (kbd "<C-S-tab>") 'tabbar-backward))

;;
(autoload 'highlight-symbol-at-point "highlight-symbol" "Toggle highlighting of the symbol at point." t)
(global-set-key (kbd "<double-down-mouse-1>") 'highlight-symbol-at-point)

(autoload 'highlight-indentation "highlight-indentation" "Toggle highlight indentation." t)
  
(autoload 'hideshowvis-mode "hideshowvis" "Add markers to the fringe for regions foldable by `hideshow-mode'." t)

(add-hook 'emacs-lisp-mode-hook 'hideshowvis-mode)
(add-hook 'python-mode-hook 'hideshowvis-mode)

;;(@*)

;;(@* "misc")
(require 'help-mode) ;;to prevent error like: "help-setup-xref: Symbol's value as variable is void: help-xref-following"

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
;;(@*)





	 
  
