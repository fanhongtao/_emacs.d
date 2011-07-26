 
;;--- options
(global-set-key (kbd "<C-f10> g") 'customize-group)
(global-set-key (kbd "<C-f10> v") 'customize-variable)
(global-set-key (kbd "<C-f10> f") 'customize-face)
(global-set-key (kbd "<C-f10> t") 'customize-themes)

(global-set-key (kbd "<C-f10> d") 'toggle-debug-on-error)

(global-set-key (kbd "<C-10> F") 'menu-set-font)

(global-set-key (kbd "<mode-line> <C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<mode-line> <C-wheel-down>") 'text-scale-decrease)

(defun bmz/toggle-show-paren-style ()
  (interactive)
  (if (eq show-paren-style 'parenthesis)
      (setq show-paren-style 'expression)
    (setq show-parent-style 'parenthesis))
  (message "show-paren-style switched to %s." show-paren-style))

(global-set-key (kbd "<C-f10> p") 'bmz/toggle-show-paren-style)
          

;;--- some 3rd-party minor modes
(global-unset-key (kbd "<f10>"))
(global-set-key (kbd "<f10> <f10>") 'menu-bar-open)

;; (global-set-key (kbd "<f10> c") 'highlight-changes-visible-mode)
;; (global-set-key (kbd "<f10> f") 'auto-fill-mode)
;; (global-set-key (kbd "<f10> p") 'show-paren-mode)
;; (global-set-key (kbd "<f10> w") 'whitespace-mode)
;; (global-set-key (kbd "<f10> h") 'hs-minor-mode)
;; (global-set-key (kbd "<f10> o") 'outline-minor-mode)
;; (global-set-key (kbd "<f10> v") 'toggle-viper-mode)
;; (global-set-key (kbd "<f10> C-w") 'visual-line-mode)
;; (global-set-key (kbd "<f10> t") 'toggle-truncate-lines)
;; (global-set-key (kbd "<f10> l") 'linum-mode)



;; 3rd-party modules
(global-set-key (kbd "<f10> C") 'auto-complete-mode)

(autoload 'highlight-indentation "highlight-indentation" "Toggle highlight indentation." t)
(autoload 'highlight-parentheses-mode "highlight-parentheses" nil t)
(autoload 'idle-highlight "idle-highlight" nil t)
(autoload 'rainbow-delimiters "rainbow-delimiters" nil t)
(autoload 'visible-mark-mode "visible-mark" nil t)
(autoload 'drag-stuff-mode "drag-stuff" nil t)
(autoload 'setnu-mode "setnu" "vi-style line numbers" t)

(global-set-key (kbd "<f10> I") 'highlight-indentation)
(global-set-key (kbd "<f10> P") 'highlight-parentheses-mode)
(global-set-key (kbd "<f10> H") 'idle-highlight)
(global-set-key (kbd "<f10> R") 'rainbow-delimiters)
(global-set-key (kbd "<f10> M") 'visibile-mark-mode)
(global-set-key (kbd "<f10> D") 'drag-stuff-mode)
(global-set-key (kbd "<f10> N") 'setnu-mode)


;;--- some elisp commands
(global-set-key (kbd "<f3> f") 'find-function-at-point)
(global-set-key (kbd "<f3> F") 'find-function)
(global-set-key (kbd "<f3> v") 'find-variable-at-point)
(global-set-key (kbd "<f3> V") 'find-variable)
(global-set-key (kbd "<f3> l") 'find-library)
(global-set-key (kbd "<f3> C-f") 'ffap-other-window)


(global-set-key (kbd "<f12> k")   'find-function-on-key)
(global-set-key (kbd "<f12> l l") 'load-library)
(global-set-key (kbd "<f12> l t") 'load-theme)

(global-set-key (kbd "<f12> e b") 'eval-buffer)
(global-set-key (kbd "<f12> e r") 'eval-region)
(global-set-key (kbd "<f12> e f") 'eval-defun)
(global-set-key (kbd "<f12> e s") 'eval-sexp)

(defun bmz/check-parens ()
  (interactive)
  (check-parens)
  (message "%s: OK" (buffer-file-name)))

(define-key emacs-lisp-mode-map (kbd "<M-f9>") 'bmz/check-parens)

(defun bmz/byte-compile-file ()
   (interactive)
   (let ( (emacs-lisp-mode-hook '()) )
     (byte-compile-file (buffer-file-name))))

(define-key emacs-lisp-mode-map (kbd "<C-f9>") 'bmz/byte-compile-file)

      
(defun load-and-execute (library)
  "load a library 'foobar' and execute the command with same name (foobar or foobar-mode"
  (interactive
   (list (completing-read "Load library: "
                          (apply-partially 'locate-file-completion-table
                                           load-path
                                           (get-load-suffixes)))))
  (when (load library)
    (let ( (command (if (fboundp (intern library))
                        (intern library)
                      (intern (concat library "-mode")))) )
      (message "try to execute `%s'" command)
      (call-interactively command))))


;;;--- misc keys


(global-set-key (kbd "H-a") 'mark-whole-buffer)
;; H-s
;; H-d
;; H-f

(global-set-key (kbd "H-z") 'undo-tree-undo)
(global-set-key (kbd "H-x") 'kill-region)
(global-set-key (kbd "H-c") 'kill-ring-save)
(global-set-key (kbd "H-v") 'cua-paste)

(defun select-parened-expression ()
  (interactive)
  (if (re-search-backward "[({]")
      (set-mark (save-excursion
                 (goto-match-paren 1)
                 (point)
                 ))))

(global-set-key (kbd "H-b") 'select-parened-expression)

;; H-q
(global-set-key (kbd "H-w") 'toggle-truncate-lines)
(global-set-key (kbd "H-y") 'undo-tree-redo)
(global-set-key (kbd "H-e") 'kill-whole-line)
;; H-r
(global-set-key (kbd "H-t") 'transpose-selections)

(global-set-key (kbd "H-g") 'keyboard-quit)

(global-set-key (kbd "<H-up>")     'outline-previous-visible-heading)
(global-set-key (kbd "<H-down>")   'outline-next-visible-heading)

;;;_. misc keys

(define-key minibuffer-local-map (kbd "ESC ESC") 'minibuffer-keyboard-quit)

(define-key minibuffer-local-map (kbd "<f5>") 'anything-minibuffer-history)

(global-set-key (kbd "C-c d") 'diff-buffer-with-file)

(global-set-key (kbd "M-g d") 'dired-jump) ;;C-x C-j


;; make M-z behave more as zap-up-to-char
(defun zap-up-to-char (arg char)
    "Kill up to the ARG'th occurence of CHAR, and leave CHAR.
  The CHAR is replaced and the point is put before CHAR."
    (interactive "p\ncZap to char: ")
    (zap-to-char arg char)
    (insert char)
    (forward-char -1))

(global-set-key (kbd "M-z") 'zap-up-to-char)
(defun zap-back-to-char (arg char)
  (interactive "p\ncBack-zap to char: ")
  (zap-to-char (- arg) char))

(global-set-key (kbd "ESC M-z") 'zap-back-to-char)

(defun go-to-char (arg char)
  (interactive "p\ncGo to char: ")
  (forward-char 1)
  (if (if arg
          (search-forward (char-to-string char) nil nil arg)
        (search-forward (char-to-string char)))
      (backward-char 1))
  )

(defun go-back-to-char (arg char)
  (interactive "p\ncGo back to char: ")
  (forward-char -1)
  (if arg
      (search-backward (char-to-string char) nil nil arg)
    (search-backward (char-to-string char)))
  )

(global-set-key (kbd "C-M-z") 'go-back-to-char)


;;--- buffer-local bookmarks
(ignore-errors
  (or (require 'bm nil t)
      (require 'linkmark nil t))
  )
(if (featurep 'bm)
    (progn
      (global-set-key (kbd "<f2> t") 'bm-toggle)
      (global-set-key (kbd "<f2> n") 'bm-next)
      (global-set-key (kbd "<f2> p") 'bm-previous)
      (global-set-key (kbd "<f2> l") 'bm-show)

      (global-set-key (kbd "<f2> <f2>") 'bm-next)

      (if (fboundp 'anything-bm-list)
          (global-set-key (kbd "<f2> l") 'anything-bm-list))
      )
  (if (featurep 'linemark)              ;; linemark.el from CEDET
      (progn        
        (define-key global-map (kbd "<f2> t") 'viss-bookmark-toggle)
        (define-key global-map (kbd "<f2> n") 'viss-bookmark-prev-buffer)
        (define-key global-map (kbd "<f2> p") 'viss-bookmark-next-buffer)
        (define-key global-map (kbd "<f2> c") 'viss-bookmark-clear-all-buffer)

        (define-key global-map (kbd "<f2> <f2>") 'viss-bookmark-next-buffer)
        ))
      )

;;---
;;TODO: folding

(autoload 'fold-dwim-toggle "fold-dwim" "Toggle folding at point." t)
(autoload 'fold-dwim-show-all "fold-dwim")
(autoload 'fold-dwm-hide-all   "fold-dwim")

(global-set-key (kbd "C-c +") 'fold-dwim-toggle)
(global-set-key (kbd "C-c C-+") 'fold-dwim-show-all)
(global-set-key (kbd "C-c C--") 'fold-dwim-hide-all)

;;(when (locate-library "fold-dwim")
;;      ;; FIXME: fold-dwim-toggle would fold/unfold on cursor, not the mouse point
;;      (global-set-key (kbd "<left-fringe><mouse-1>") 'fold-dwim-toggle)
;;      )

;;--- selective display (quick & dirty code folding)
;; http://www.emacswiki.org/emacs/HideShow#toc5
;; hide lines whose indentation is bigger than x column
(defun toggle-selective-display (column)
  (interactive "P")
  (set-selective-display
   (or column
       (unless selective-display
         (1+ (current-column))))))

(defun toggle-hiding (column)
  (interactive "P")
  (if hs-minor-mode
      (if (condition-case nil
              (hs-toggle-hiding)
            (error t))
          (hs-show-all))
    (toggle-selective-display column)))

(global-set-key (kbd "C-c \\") 'toggle-selective-display)
;;(global-set-key (kbd "C-+") 'toggle-hiding)

;;--- hidesearch
(autoload 'hidesearch "hidesearch" "Incrementally show only lines in file based on what user types." t)
(autoload 'show-all-invisible "hide-lines" "Show all areas hidden by the filter-buffer command" t)
(autoload 'hide-non-matching-lines "hide-lines" "Hide lines that don't match the specified regexp." t)

(global-set-key (kbd "C-c C-s") 'hidesearch)
(global-set-key (kbd "C-c C-a") 'show-all-invisible)

;;FIXME: anything-occur is better?

;;---
(defun goto-scratch-buffer-on-botton-window ()
  (interactive)
  (require 'windmove)
  (let ( (win (selected-window)) )
    (while (windmove-find-other-window 'down nil win)
      (setq win (windmove-find-other-window 'down nil win)))
    (when win
      (select-window win)
      (switch-to-buffer "*scratch*"))))

(global-set-key (kbd "<f11> s") 'goto-scratch-buffer-on-botton-window)


;; http://dev.ariel-networks.com/articles/emacs/part4/
;; anything-show-kill-ring ¤òÊ¹¤¦¤è¤¦¤ËÐÞÕý¤·¤¿
(defadvice yank-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

(defadvice cua-paste-pop (around anything-kill-ring-maybe activate)
  (if (not (eq last-command 'yank))
      (anything-show-kill-ring)
    ad-do-it))

;;--- list & choose method

(defun bmz/select-method()
  (interactive)
  (require 'idomenu "idomenu" t)  
  (require 'eassist "eassist" t)  ;; for `eassist-list-methods'
  (cond
   ( (and (fboundp 'anything-browse-code)
	  (memq major-mode '(emacs-lisp-mode lisp-interaction-mode python-mode)))
     (anything-browse-code))
   ( (fboundp 'anything-imenu)
     (anything-imenu) )
   ( (fboundp 'idomenu)
     (idomenu) )
   ( (and (fboundp 'eassist-list-methods)
	  (memq major-mode '(emacs-lisp-mode c-mode java-mode python-mode))
	  (memq 'semantic-mode minor-mode-alist))
     (eassist-list-methods) )
   (t (imenu))))

(global-set-key (kbd "C-c C-o") 'bmz/select-method)
(global-set-key (kbd "<f5> I") 'bmz/select-method)

;;--- extend selection incrementally (ergoemacs-functions.el)
;; http://xahlee.org/emacs/syntax_tree_walk.html
(autoload 'extend-selection "ergoemacs-functions" nil t)
(global-set-key (kbd "C-.") 'extend-selection)
;; see also: mark-sexp (C-M-SPC), mark-word (M-@)

;;-- block movement
;;stolen from http://xahlee.org/emacs/xah_emacs_cursor_movement.el
;;(modified: now it move to next occurrence of 3rd newline char)
(defun forward-block ()
  "Move cursor forward to next occurrence of double newline char.
In most major modes, this is the same as `forward-paragraph', however,
this function behaves the same in any mode.
forward-paragraph is mode dependent, because it depends on
syntax table that has different meaning for ¡°paragraph¡±."
  (interactive)
  (skip-chars-forward "\n")
  (when (not (search-forward-regexp "\n[[:blank:]]*\n[[:blank:]]*\n" nil t))
    (goto-char (point-max)) ) )

(defun backward-block ()
  "Move cursor backward to previous occurrence of double newline char.
See: `forward-block'"
  (interactive)
  (skip-chars-backward "\n")
  (when (not (search-backward-regexp "\n[[:blank:]]*\n[[:blank:]]*\n" nil t))
    (goto-char (point-min))
    )
  )

(global-set-key (kbd "C-c n") 'forward-block)
(global-set-key (kbd "C-c p") 'backward-block)

;;--- completion

;;;_. auto-completion
(defun ac-expand-filename ()
  (interactive)
  (let ( (ac-sources '(ac-source-filename ac-source-files-in-current-dir)) )
    (call-interactively 'ac-start)))

;;(global-set-key (kbd "C-, /") 'ac-expand-filename)
(global-set-key (kbd "C-/") 'ac-expand-filename)

;;;_. dabbrev 
(autoload 'dabbrev-expand-multiple "dabbrev-expand-multiple" "dynamic abbrev expansion for multiple selection" t)
(setq dabbrev-expand-multiple-select-keys '("a" "s" "d" "f" "g" "q" "w" "e" "r" "t"))
(global-set-key (kbd "C-c /") 'dabbrev-expand-multiple)

;;;_. completion-ui
(idle-require 'completion-ui)
(global-set-key (kbd "C-, d") 'complete-dabbrev)
(global-set-key (kbd "C-, t") 'complete-etags)
(global-set-key (kbd "C-, f") 'complete-files)
  
;;(global-set-key (kbd "C-, s") 'complete-symbol) ;;elisp
;;(global-set-key (kbd "C-, >") 'complete-nxml)
;;(global-set-key (kbd "C-, <") 'complete-nxml)
(global-set-key (kbd "C-, $") 'complete-ispell)

(idle-require 'complete-ui-more-source)
(global-set-key (kbd "C-, $") 'complete-ispell-lookup)


;;;_ misc
;;;_. opening server files always in a new frame
;;http://www.emacswiki.org/emacs/EmacsClient#toc21

(add-hook 'server-switch-hook
          (lambda nil
            (let ((server-buf (current-buffer)))
              (bury-buffer)
              (switch-to-buffer-other-frame server-buf))))

;;;_. count region
;; http://xahlee.org/emacs/elisp_count-region.html
;; see also: M-= (M-x count-lines-region)
(defun count-region (begin end)
  "Print number of words and chars in region."
  (interactive "r")
  (message "Counting ...")
  (save-excursion
    (let (wCnt charCnt)
      (setq wCnt 0)
      (setq charCnt (- end begin))
      (goto-char begin)
      (while (and (< (point) end)
                  (re-search-forward "\\w+\\W*" end t))
        (setq wCnt (1+ wCnt)))

      (message "Words: %d. Chars: %d." wCnt charCnt)
      )))




;;(@* "org-mode")

;;FIXME: '<s' template
(defun org-quote-region (begin end)
  (interactive "r")
  (if (not (and transient-mark-mode mark-active))
      (error "You should make a region")
    (let* ( (choices '("SRC" "EXAMPLE" "QUOTE" "HTML" "VERSE" "COMMENT" "LATEX"
                    "*" "_" "/" "=" "~"
                    ))
            (choice (ido-completing-read "With:" choices)) )
      (if (member choice '("*" "_" "/" "=" "~"))
          (progn
            (goto-char end)
            (insert-string choice)
            (goto-char begin)
            (insert-string choice))
        (progn
          (goto-char end)
          (insert-string (concat "\n#+END_" choice "\n"))
          (goto-char begin)
          (insert-string (concat "#+BEGIN_" choice "\n")))))))


;;---
;; use `pos-tip' to fix the popup window position issue
(when (require 'popup-pos-tip)
  (defadvice popup-tip
    (around popup-pos-tip-wrapper (string &rest args) activate)
    (if (eq window-system 'x)
        (apply 'popup-pos-tip string args)
      ad-do-it)))


;;TODO: (@* "cygwin")

;;_ misc
(idle-require 'menu-bar+)

(idle-require 'mouse3)

(idle-require 'second-sel)
