
(require 'highlight-symbol)
(require 'anything-config)

(defun hsb--symbol-selected-or-current ()
  "Get the selected text or (if nothing selected) current symbol."
  (if (and transient-mark-mode mark-active)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'symbol)))


(defun hkb-goto-symbol-occurrence (forward)
  (let ( (symbol (hkb--symbol-selected-or-current)) )
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

(defun hkb-goto-symbol()
  (interactive)
  (let ( (keyword (hkb--symbol-selected-or-current)) )
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
  (occur (format "%s" (hkb--symbol-selected-or-current))))

(defun hkb-multi-occur-at-point ()
  (interactive)
  ;;FIXME: use multi-occur?
  (moccur (format "%s" (hkb--symbol-selected-or-current))))

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


(defvar my-word-ops-keymap)
(define-prefix-command 'my-word-ops-keymap)

(defun init-word-ops-keys ()
  (let ( (map my-word-ops-keymap) )
    (define-key map (kbd "M-.") 'hkb-goto-symbol)
    
    (define-key map (kbd "C-j") 'highlight-symbol-at-point)
    (define-key map (kbd "*") 'hkb-goto-symbol-next-occur)
    (define-key map (kbd "#") 'hkb-goto-symbol-prev-occur)

    (define-key map (kbd "o") 'hkb-occur-at-point)
    (define-key map (kbd "O") 'hkb-multi-occur-at-point)

    (define-key map (kbd "f") 'find-function-at-point)
    (define-key map (kbd "v") 'find-variable-at-point)
    (define-key map (kbd "F") 'ffap-other-window)

   ;; (define-key map (kbd "d") 'sdcv-
    ))

(init-word-ops-keys)

