;; some commands for the symbol/word at point

(require 'highlight-symbol)

(defun hkb-goto-symbol-occurrence (forward)
  (let ( (symbol (highlight-symbol-get-symbol)) )
    (unless symbol (error "No symbol at point"))  
    (unless hi-lock-mode (hi-lock-mode 1))  
    (if (not (member symbol highlight-symbol-list))  
	(highlight-symbol-at-point)))  
  (if forward
      (highlight-symbol-next)
    (highlight-symbol-prev)))

(defun hkb-goto-symbol-next-occur ()
  (interactive)
  (hkb-goto-symbol-occurrence t))

(defun hkb-goto-symbol-prev-occur ()
  (interactive)
  (hkb-goto-symbol-occurrence nil))


(defun hkb--get-symbol-selected-or-current ()
  "Get the selected text or (if nothing selected) current symbol."
  (if (and transient-mark-mode mark-active)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'symbol)))

(defun hkb-find-symbol-at-point()
  (interactive)
  (let ( (keyword (hkb--get-symbol-selected-or-current)) )
    (cond
     ( (memq major-mode '(emacs-lisp-mode lisp-interaction-mode))
       (find-function-at-point) )
     ( (and (fboundp 'semantic-complete-jump)
	     (memq major-mode '(c-mode java-mode python-mode)))
       (semantic-complete-jump) )
     (t
      (find-tag)))))

;; occur
(defun hkb-occur-at-point ()
  (interactive)
  (occur (format "%s" (hkb--get-symbol-selected-or-current))))

(defun hkb-multi-occur-at-point ()
  (interactive)
  ;;FIXME: use multi-occur?
  (multi-occur (format "%s" (hkb--get-symbol-selected-or-current))))

;;TODO: grep
;;...


;;--- overall
(defun my-word-ops-set-keymap-prefix-key (var key)
  (when (boundp 'my-word-ops-keymap-prefix-key)
    (global-unset-key (read-kbd-macro my-word-ops-keymap-prefix-key)))
  (setq my-word-ops-keymap-prefix-key key)
  (global-set-key (read-kbd-macro my-word-ops-keymap-prefix-key)
                  'my-word-ops-keymap))

(defcustom my-word-ops-keymap-prefix-key "<f3>"
  "The prefix key for all `my-word-ops' commands."
  :type 'string
  :set 'my-word-ops-set-keymap-prefix-key)


(defvar my-word-ops-keymap (make-sparse-keymap "Operation on current symbol"))
(define-prefix-command 'my-word-ops-keymap)

(defun init-word-ops-keys ()
  (let ( (map my-word-ops-keymap) )
    (define-key map (kbd "M-.") 'hkb-find-symbol-at-point) ;; Emacs style key
    (define-key map (kbd "C-]") 'hkb-find-symbol-at-point) ;; Vi style key
    
    (define-key map (kbd "C-j") 'highlight-symbol-at-point)
    (define-key map (kbd "*") 'hkb-goto-symbol-next-occur)
    (define-key map (kbd "#") 'hkb-goto-symbol-prev-occur)

    (define-key map (kbd "o") 'hkb-occur-at-point)
    (define-key map (kbd "O") 'hkb-multi-occur-at-point)

    ;; (define-key map (kbd "f") 'find-function-at-point)
    ;; (define-key map (kbd "v") 'find-variable-at-point)
    ;; (define-key map (kbd "l") 'find-library)
    ;; (define-key map (kbd "C-f") 'ffap-other-window)

    (define-key map (kbd "<f3>") 'isearch-repeat-forward)
    (define-key map (kbd "<S-f3>") 'isearch-repeat-backward)

    (autoload 'sdcv-search "sdcv-mode" nil t)
    (define-key map (kbd "d") 'sdcv-search) ;;sdcv-mode.el needed

    ))

(init-word-ops-keys)

