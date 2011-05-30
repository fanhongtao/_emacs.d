;; CUA-like editing

;; functions.el from ergoemacs 
(autoload 'new-empty-buffer "ergoemacs-functions" "Opens a new empty buffer." t)
(autoload 'close-current-buffer "ergoemacs-functions" "Close the current buffer." t)


(defvar my-cua-like-keymap (make-sparse-keymap "CUA-like operations"))
(define-prefix-command 'my-cua-like-keymap)

(defun init-cua-keys (prefix-key)
  (global-set-key (read-kbd-macro prefix-key) 'my-cua-like-keymap)
  
  (let ( (map my-cua-like-keymap) )
    ;; files
    (define-key map (kbd "C-n") 'new-empty-buffer) ;;from ergoemacs
    (define-key map (kbd "<C-f4>") 'close-current-buffer) ;;from ergoemacs
    (define-key map (kbd "C-o") 'menu-find-file-existing)
    (define-key map (kbd "C-s") 'save-buffer)
;;    (define-key map (kbd "C-w") 'write-file)  ;; save as

    ;; edit
    (define-key map (kbd "C-c") 'kill-ring-save) ;; copy
    (define-key map (kbd "C-x") 'kill-region) ;; cut
    (define-key map (kbd "C-v") 'yank)	;; paste
    
    (define-key map (kbd "C-a") 'mark-whole-buffer)  ;; select all

    (if (featurep 'undo-tree)
	(progn
	  (define-key map (kbd "C-z") 'undo-tree-undo)
	  (define-key map (kbd "C-Z") 'undo-tree-redo)
	  (define-key map (kbd "C-y") 'undo-tree-redo))
      (progn
	(define-key map (kbd "C-z") 'undo)
	(if (featurep 'redo)
	    (progn
	      (define-key map (kbd "C-Z") 'redo)
	      (define-key map (kbd "C-y") 'redo)))))

    (define-key map (kbd "C-w") 'toggle-truncate-lines) ;; or visual-line-mode?

    ;; search
    (define-key map (kbd "C-f") 'isearch-forward)
    (define-key map (kbd "C-r") 'query-replace) ;; it's better to keep C-h reserved for listing keybindings
    (define-key map (kbd "<f3>") 'nonincremental-repeat-search-forward)
    (define-key map (kbd "<S-f3>") 'nonincremental-repeat-search-backward)

    (define-key map (kbd "C-y") 'kill-whole-line)
    (define-key map (kbd "C-g") 'goto-line)

    ;;(when (featurep 'bm)
    (define-key map (kbd "<f2>") 'bm-next)
    (define-key map (kbd "<C-f2>") 'bm-toggle)
    (define-key map (kbd "<S-f2>") 'bm-previous)
    ))

(init-cua-keys "<f4>")
    
      
    
