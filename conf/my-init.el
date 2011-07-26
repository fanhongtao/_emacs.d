(fset 'yes-or-no-p 'y-or-n-p)

(unless (fboundp 'idle-require)
  (defun idle-require (feature &optional file noerror)
    (require feature)))

;;;_ gui options

(if (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))

(setq frame-title-format '("%b (%m) - Emacs "
			   (:eval emacs-version)))

(when (eq window-system 'x)
    (setq x-select-enable-clipboard t)
;;  (setq x-select-enable-primary t)
    (set-scroll-bar-mode 'right))


;;;_ windows
(setq winner-dont-bind-my-keys t)
(winner-mode t)
;;(global-set-key (kbd "<f11> C-z") 'winner-undo)
;;(global-set-key (kbd "<f11> C-y") 'winner-redo)

;;;_ tabbar
;; ide-skel would group buffers into two: editing buffer, emacs buffer
(require 'ide-skel nil t)

;; if you use `ide-ske', don't directly load `tabbar' after `ide-ske'
;; as this would mess up the tab group definition of `ide-skel'
(when (or (featurep 'tabbar)
          (load "tabbar" t))
  (tabbar-mode t)
  (global-set-key (kbd "<C-tab>") 'tabbar-forward)
  (global-set-key (kbd "<C-S-tab>") 'tabbar-backward))

;;;_ files & buffers
(global-set-key (kbd "<C-tab>") 'previous-buffer)
(global-set-key (kbd "<C-S-tab>") 'next-buffer)

(define-key goto-map "d" 'dired-jump) ;;C-x C-j

;;;_. recentf
(require 'recentf)
(setq recentf-max-saved-items 100)
(setq recentf-menu-path '("File"))
(recentf-mode t)

;;;_. tempbuf
;;(autoload 'turn-on-tempbuf-mode "tempbuf")
(when (load "tempbuf" t)
  (add-hook 'dired-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'custom-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'w3-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'Man-mode-hook 'turn-on-tempbuf-mode)
  (add-hook 'view-mode-hook 'turn-on-tempbuf-mode))

;;;_ key bindings

;;;_. key modifiers and prefix keys

;; <f2>: 2-columns, diff, bookmarks
;; <f3>: operations on current symbol
;; <f4>: cua-like
;; <f5>: selection and perform
;; <f5> a: anything
;; <f6>: vi style commands
;; <f7>:
;; <f8>:
;; <f9>: M-f9: syntax check, C-f9: compile, f9: run
;; <f10>: toggle minor modes
;; <C-f10>:  some settings
;; <f11>: window-related commands (`super' modifier)
;; <f12>: misc stuff

(when (eq window-system 'w32)
  ;;(setq w32-lwindow-modifier 'super)
  
  (setq w32-lwindow-modifier 'nil)  ;;<lwindow> used as a prefix key
  (setq w32-pass-lwindow-to-system t) ;;if set to nil, a single press <lwindow> would prevent Start Menu
  (define-key key-translation-map (kbd "<lwindow>") (kbd "<f11>"))

  ;; (setq w32-rwindow-modifier 'alt)      
  (setq w32-rwindow-modifier 'hyper)
  (setq w32-pass-rwindow-to-system nil)
  ;;(define-key key-translation-map (kbd "<rwindow>") (kbd "C-c"))
  
  (setq w32-apps-modifier 'hyper)
  
  (setq w32-scroll-lock-modifier nil)

  (defun toggle-w32-alt-is-meta ()
    (interactive)
    (setq w32-alt-is-meta (not w32-alt-is-meta))
    (setq w32-lwindow-modifier (if w32-lwindow-modifier
                                   nil
                                 'hyper))
    (message "Now ALT key %s META. LWin is %s."
             (if w32-alt-is-meta "is" "is not")
             w32-lwindow-modifier)
    )

  (global-set-key (kbd "<scroll>") 'toggle-w32-alt-is-meta)
  )
  
;;FIXME: not work
(when (eq window-system 'x)
  (define-key key-translation-map (kbd "<super>") (kbd "<f11>"))
  )


(global-unset-key (kbd "<f2>"))
(global-unset-key (kbd "<f3>"))
(global-unset-key (kbd "<f4>"))
(global-unset-key (kbd "<f10>"))

(global-set-key (kbd "<f10> <f10>") 'menu-bar-open)

;; toggle minor modes
(global-set-key (kbd "<f10> c") 'highlight-changes-visible-mode)
(global-set-key (kbd "<f10> f") 'auto-fill-mode)
(global-set-key (kbd "<f10> p") 'show-paren-mode)
(global-set-key (kbd "<f10> w") 'whitespace-mode)
(global-set-key (kbd "<f10> h") 'hs-minor-mode)
(global-set-key (kbd "<f10> o") 'outline-minor-mode)
(global-set-key (kbd "<f10> v") 'toggle-viper-mode)
(global-set-key (kbd "<f10> C-w") 'visual-line-mode)
(global-set-key (kbd "<f10> t") 'toggle-truncate-lines)
(global-set-key (kbd "<f10> l") 'linum-mode)

;;;_. common keys
(setq shift-select-mode t)
(delete-selection-mode t)

(setq cua-enable-cua-keys nil)
;;(setq cua-rectangle-modifier-key 'hyper)  ;;leave C-RET
(cua-mode)

(global-set-key (kbd "C-c RET") 'cua-set-rectangle-mark)

;;;_. misc keys

(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-j") 'newline)

;;;_ editing
(global-set-key (kbd "C-=") 'align-regexp)


;;;_. tab key & indent
(if (<= emacs-major-version 23) ;; emacs < 23.2
     (setq tab-always-indent nil)
   (setq tab-always-indent 'complete)) ;; emacs >= 23.2
;;(setq tab-always-indent t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;;;_. parens
(setq show-paren-mode t)

;;;_. wrap
(setq-default truncate-lines t)
(setq-default fill-column 100)
;;(auto-fill-mode t)

(global-set-key (kbd "C-c C-w") 'toggle-truncate-lines)

;;;_. changes
(setq highlight-changes-visibility-initial-state nil)
(global-highlight-changes-mode t)

(global-set-key (kbd "C-c d") 'diff-buffer-with-file)

;;;_. quickly swap lines
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
;;    (setq drag-stuff-modifier 'hyper)
      (add-to-list 'drag-stuff-except-modes 'org-mode)
      (drag-stuff-global-mode t))
  (progn
      (global-set-key (kbd "<M-up>") 'swap-line-up)
      (global-set-key (kbd "<M-down>") 'swap-line-down)
      ))

;;;_. vi-style join-line
(defun join-line ()
  "Join the following line with current line"
  (interactive)
  (delete-indentation 1))

(global-set-key (kbd "C-c J") 'join-line)


;;;_ completion
;; Emacs default:
;;   M-TAB - lisp-complete-symbol(<24)/completion-at-point(v24)
;;   M-/ - dabbrev-expand

(global-set-key (kbd "M-/") 'hippie-expand)

;;;_. ido
(require 'ido)
(unless (fboundp 'ido-common-initialization)   ;;workaround for emacs 23.1's bug(?)
  (defun ido-common-initialization ()
    (ido-init-completion-maps)
    (add-hook 'minibuffer-setup-hook 'ido-minibuffer-setup)
    (add-hook 'choose-completion-string-functions 'ido-choose-completion-string))
  )
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)
(ido-mode t)

(setq ido-use-filename-at-point 'guess)
(setq ido-use-url-at-point 'guess)

(autoload 'idomenu "idomenu" "Switch to a buffer-local tag from Imenu via Ido." t)

;;;_. smex : ido for M-x
(if (require 'smex nil t)
    (progn
      (smex-initialize)
  
      (global-set-key (kbd "M-x") 'smex)
      (global-set-key (kbd "M-X") 'smex-major-mode-commands)
      ;; This is your old M-x.
      (global-set-key (kbd "ESC M-x") 'execute-extended-command))
  (progn
    (message "%s: failed to load `smex'." load-file-name)
    ;;fall back to Emacs' icomplete-mode
    (icomplete-mode t)))


;;;_. anything
(if (and (load "anything" t)
         (load "anything-config" t))
    (progn
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
  (message "%s: failed to load `anything'." load-file-name))


;;-- auto-compelte
(if (and (load "auto-complete" t)
         (load "auto-complete-config" t))
    (progn
      (define-key ac-completing-map (kbd "ESC ESC") 'ac-stop)
      
      (ac-config-default)
      (add-hook 'lisp-interaction-mode 'ac-emacs-lisp-mode-setup)

      (if (load "auto-complete-scite-api" t)
          (add-to-list 'ac-sources 'ac-source-scite-api)
        (message "%s: failed to load `auto-complete-scite-api'." load-file-name)))
  (message "%s: failed to load `auto-complete'." load-file-name))


;;;_ viper
(if (require 'undo-tree nil 'noerror)
    (progn
      (global-undo-tree-mode t)
      (global-set-key (kbd "C-c C-z") 'undo-tree-undo)
      (global-set-key (kbd "C-c C-y") 'undo-tree-redo)

      (define-key undo-tree-map (kbd "C-/") nil) ;; leave it for completion
      )
  (message "%s: failed to load `undo-tree'."  load-file-name))

(eval-after-load "viper"
  '(require 'vimpulse))

(setq viper-expert-level '3)
(setq viper-inhibit-startup-message 't)


;;;_ code folding

;;;_. hideshow
(autoload 'hideshowvis-enable "hideshowvis" "Add markers to the fringe for regions foldable by `hideshow-mode'." t)
(autoload 'hideshowvis-minor-mode "hideshowvis" "Will indicate regions foldable with hideshow in the fringe." 'interactive)

(eval-after-load 'hideshowvis '(load "hideshow-fringe" t))

(add-hook 'emacs-lisp-mode-hook 'hideshowvis-enable)

(eval-after-load 'python
  (add-hook 'python-mode-hook 'hideshowvis-enable))

;(eval-after-load "hideshow"
;  (define-key hs-minor-mode-map (kbd "C-+")  'hs-toggle-hiding))

;;;_. outline

(global-set-key (kbd "<C-M-up>")     'outline-previous-visible-heading)
(global-set-key (kbd "<C-M-down>")   'outline-next-visible-heading)

(global-set-key (kbd "C-c <up>")     'outline-previous-visible-heading)
(global-set-key (kbd "C-c <down>")   'outline-next-visible-heading)

(global-set-key (kbd "<C-wheel-up>") 'outline-previous-visible-heading)
(global-set-key (kbd "<C-wheel-down>") 'outline-next-visible-heading)
(global-set-key (kbd "<C-mouse-1>") 'outline-toggle-children)
(global-set-key (kbd "<C-mouse-2>")   'hide-sublevels)

;;;_. allout
(eval-after-load "allout"
  '(progn
     (define-key allout-mode-map (kbd "<C-M-up>")     'allout-previous-visible-heading)
     (define-key allout-mode-map (kbd "<C-M-down>")   'allout-next-visible-heading)

     (define-key allout-mode-map (kbd "<C-wheel-up>")   'allout-previous-visible-heading)
     (define-key allout-mode-map (kbd "<C-wheel-down>") 'allout-next-visible-heading)
     (define-key allout-mode-map (kbd "<C-mouse-1>")    'allout-hide-current-subtree)
     (define-key allout-mode-map (kbd "<C-mouse-3>")    'allout-show-current-subtree)
     ))


;;;_ some visual effect
;;;_. highlight-symbol
(idle-require 'highlight-symbol)

(global-set-key (kbd "C-c j>")          'highlight-symbol-at-point)
(define-key search-map (kbd "j")        'highlight-symbol-at-point)
(define-key search-map (kbd "<up>")   'highlight-symbol-prev)
(define-key search-map (kbd "<down") 'highlight-symbol-next)

(global-set-key (kbd "<double-mouse-1>")  'highlight-symbol-at-point)
(global-set-key (kbd "<S-wheel-up>")      'highlight-symbol-prev)
(global-set-key (kbd "<S-wheel-down>")    'highlight-symbol-next)

;;;_. bm
(idle-require 'bm)


(global-set-key (kbd "<left-fringe> <C-mouse-1>")     'bm-toggle-mouse)
(global-set-key (kbd "<left-fringe> <C-wheel-up>")    'bm-previous-mouse)
(global-set-key (kbd "<left-fringe> <C-wheel-down>")  'bm-next-mouse)
(global-set-key (kbd "<left-fringe> <C-mouse-2>")     'bm-show)


;;;_. linkd: visualize section header & links (to file/man/info/url)
(if (require 'linkd nil t)
    (progn
      (let ( (dir (concat (file-name-directory (locate-library "linkd")) "icons")) )
        (when (file-exists-p dir)
          (setq linkd-icons-directory dir)
          (setq linkd-use-icons t)))
      (add-hook 'emacs-lisp-mode-hook 'linkd-enable)
      (add-hook 'python-mode-hook 'linkd-enable)
      (add-hook 'espresso-mode-hook 'linkd-enable))
  (message "%s: failed to load `linkd'." load-file-name))


;;;_ programming
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)

(which-func-mode t)

(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)

(define-key goto-map "i" 'idomenu)
(define-key goto-map "I" 'imenu)

(define-key goto-map "e" 'find-tag)

(define-key goto-map "`" 'flymake-goto-next-error)
(define-key goto-map "~" 'flymake-goto-prev-error)


;;;_ navigations
(setq rj-column-threshold 100)
(if (load "recent-jump" t)
    (recent-jump-mode t)
  (message "%s: failed to load `linkd'." load-file-name))

(global-set-key (kbd "C-c <") 'recent-jump-backward)
(global-set-key (kbd "C-c >") 'recent-jump-forward)


;;;_ org-mode
(setq org-CUA-compatible t)

(setq org-completion-use-ido t
      ;; org-hide-leading-stars t
      org-use-sub-superscripts nil ;;don't use `_' for subscript

      org-export-with-section-numbers nil ;; no numbers in export headings
      org-export-with-toc nil ;; no ToC in export
      org-export-with-author-info nil ;; no author info in export
      org-export-with-creator-info nil ;; no creator info
      org-export-htmlize-output-type 'css ;; separate css
      )

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c c") 'org-capture)








	 
  
