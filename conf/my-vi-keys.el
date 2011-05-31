;; vi-style keys
;;
;; http://www.emacswiki.org/emacs/ViEmacsTable
;; http://www.emacswiki.org/emacs/ViKeys
;; http://www.emacswiki.org/emacs/RecenterLikeVi
;; http://grok2.tripod.com/   Emacs for vi users

;;---
;; http://www.emacswiki.org/emacs/ParenthesisMatching
(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert %.
vi style of % jumping to matching brace."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))

(defun join-line ()
  "Join the following line with current line"
  (interactive)
  (delete-indentation 1))

;; http://www.emacswiki.org/emacs/OpenNextLine
(defun open-next-line ()
  (interactive)
  (if (eobp)
      (newline-and-indent)
    (progn
      (next-line)
      (open-line 1))))

;;(global-set-key (kbd "<f6> J") 'join-line)

;;---
(defun shift-region-or-line (dir)
  "Shift region or current line to left or right, like in Vi.

If DIR is non-nill, shift right. Otherwise, shift left."
  (let ( (count (if dir tab-width (- tab-width))) )
    (if (and transient-mark-mode mark-active)
        (indent-rigidly (region-beginning) (region-end) count)
      (indent-rigidly (line-beginning-position) (line-end-position) count))))

(defun shift-left ()
  (interactive)
  (shift-region-or-line nil))

(defun shift-right ()
  (interactive)
  (shift-region-or-line t))

;; (global-set-key (kbd "<f6> <<") 'shift-left)
;; (global-set-key (kbd "<f6> >>") 'shift-right)
      

(defun kill-forward-whitespaces ()
  "Kill the whitespaces from the current position until the next
non-whitespace character"
  (interactive)
  (let ((start-point (point))
	(end (skip-chars-forward " \t\n\r")))
    (kill-region start-point (+ end start-point))
  ))

;;http://www.nujk.com/emacs-command-to-delete-up-to-non-whitespace-character
(defun kill-word-vi-style (arg)
  "Delete continuous whitespaces or a word.

If the char under cursor is whitespace or tab, this would delete
the continuous whitespaces.  If current cursor is at the end of
the line, this would delete the NEWLINE char and all leading
whitespaces of the next line. Otherwise it would kill current word."
  (interactive "p")
  (let ( (char (char-after (point))))
    (if (or (char-equal char ?\x020)
            (char-equal char ?\t))
        ;;(delete-horizontal-space)
        (kill-forward-whitespaces)
       (if (eolp)
          (delete-indentation t)
        (kill-word arg)))
      ))


(defun kill-line-vi-style ()
  (interactive)
  (let (select-active-regions)
    (deactivate-mark))
  (kill-whole-line))

;;---
(defun init-vi-style-keys (prefix-key)
  (let ( (map (make-sparse-keymap "Vi-style operation")) )
    (define-prefix-command 'my-win-fns-keymap)
    (global-set-key (read-kbd-macro prefix-key) map)

    (define-key map (kbd "w") 'forward-word)
    (define-key map (kbd "b") 'backward-word)
    (define-key map (kbd "^") 'back-to-indentation)
    (define-key map (kbd "$") 'end-of-line)
    (define-key map (kbd "g 0") 'beginning-of-line)

    (define-key map (kbd "(") 'backward-sentence)
    (define-key map (kbd ")") 'forward-sentence)
    (define-key map (kbd "{") 'backward-paragraph)
    (define-key map (kbd "}") 'forward-paragraph)
    
    (define-key map (kbd "C-f") 'forward-page)
    (define-key map (kbd "C-b") 'backward-page)

    (define-key map (kbd "y") 'kill-ring-save)
    (define-key map (kbd "p") 'cua-paste) ;;compared to `yank', `cua-paste' support register 1-9    

    (define-key map (kbd "*") 'hkb-goto-symbol-next-occur)
    (define-key map (kbd "#") 'hkb-goto-symbol-prev-occur)
    (define-key map (kbd "%") 'goto-match-paren)
    (define-key map (kbd "C-]") 'hkb-find-symbol-at-point)
    
    (define-key map (kbd "d w") 'kill-word-vi-style)
    (define-key map (kbd "d t") 'zap-up-to-char)
    (define-key map (kbd "d f") 'zap-to-char)
    (define-key map (kbd "d d") 'kill-whole-line)

    (define-key map (kbd "/") 'isearch-forward-regexp)
    (define-key map (kbd "?") 'isearch-backward-regexp)
    (define-key map (kbd "n") 'isearch-repeat-forward)
    (define-key map (kbd "N") 'isearch-repeat-backward)

    (define-key map (kbd "J") 'join-line)
    (define-key map (kbd "> >") 'shift-right)
    (define-key map (kbd "< <") 'shift-left)

    (define-key map (kbd "m") 'point-to-register)
    (define-key map (kbd "`") 'register-to-point) ;;` in vi supports register & bookmark
    (define-key map (kbd "\"p") 'insert-register) ;; "xp (not very good)
    (define-key map (kbd "\"y") 'copy-to-register) ;; "xy (not very good)
    (define-key map (kbd "M") 'bookmark-set)

    (define-key map (kbd "g g") 'beginning-of-buffer)
    (define-key map (kbd "G") 'end-of-buffer)
))
    

(init-vi-style-keys "<f6>")
(global-set-key (kbd "<f6> <f6>") 'toggle-viper-mode)

;; translate <scroll> to <f6>
;; (define-key key-translation-map (kbd "<scroll>") (kbd "<f6>"))
