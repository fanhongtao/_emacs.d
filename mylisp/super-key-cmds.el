;;; super-key-cmds.el -- some commands supposed to bound to <win>+xx keys

(require 'windmove)

(or (load "window-extensions" t)
    (and (load "dedicated" t)
	 (load "sticky-windows" t)))

(load "transpose-frame" t)   

(load "tabbar" t)
(load "imenu-tree" t)
(load "sr-speedbar" t)
(load "ide-skel" t)  ;; not recommended, it has some bugs



;; sizing
(global-set-key (kbd "<s-up>") 'enlarge-window)
(global-set-key (kbd "<s-down>") 'shrink-window)
(global-set-key (kbd "<s-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<s-right>") 'enlarge-window-horizontally)

(global-set-key (kbd "<S-s-up>") '(lambda ()
				   (interactive)
				   (enlarge-window 3)))
(global-set-key (kbd"<S-s-down>") '(lambda ()
				      (interactive)
				      (shrink-window 3)))
(global-set-key (kbd "<S-s-left>") '(lambda ()
				      (interactive)
				      (shrink-window-horizontally 5)))
(global-set-key (kbd "<S-s-right>") '(lambda ()
				       (interactive)
				       (enlarge-window-horizontally 5)))

(global-set-key (kbd "<s-=>") '(lambda ()
				 (interactive)
				 (enlarge-window 1)
				 (enlarge-window-horizontally 1)))
(global-set-key (kbd "<s-->") '(lambda ()
				 (interactive)
				 (shrink-window 1)
				 (shrink-window-horizontally 1)))
(global-set-key (kbd "<s-+>") '(lambda ()
				 (interactive)
				 (enlarge-window 3)
				 (enlarge-window-horizontally 5)))
(global-set-key (kbd "<s-_>") '(lambda ()
				 (interactive)
				 (shrink-window 3)
				 (shrink-window-horizontally 5)))

;; motion between windows
(windmove-default-keybindings 'super)

(global-set-key (kbd "<s-tab>") 'other-window)
(global-set-key (kbd "<S-s-tab>") '(lambda ()
				     (interactive)
				     (other-window -1)))

;; move buffer across windows
;; https://github.com/banister/window-rotate-for-emacs
(defun rotate-windows-helper(x d)
  (if (equal (cdr x) nil) (set-window-buffer (car x) d)
    (set-window-buffer (car x) (window-buffer (cadr x))) (rotate-windows-helper (cdr x) d)))
 
(defun rotate-windows ()
  (interactive)
  (rotate-windows-helper (window-list) (window-buffer (car (window-list))))
  (select-window (car (last (window-list)))))

(global-set-key (kbd "<s-backspace>") 'rotate-windows)
;;TODO: backward-rotate-windows


;; modified from windmove-do-window-select
(defun windmove-do-swap-window (dir &optional arg window)
  "Move the buffer to the window at direction DIR.
DIR, ARG, and WINDOW are handled as by `windmove-other-window-loc'.
If no window is at direction DIR, an error is signaled."
  (let ((other-window (windmove-find-other-window dir arg window)))
    (cond ( (null other-window)
	    (error "No window %s from selected window" dir))
          ( (and (window-minibuffer-p other-window)
                (not (minibuffer-window-active-p other-window)))
	    (error "Minibuffer is inactive"))
	  ( (window-dedicated-p window)
	    (error "Current window is dedicated, can't be moved") )
	  ( (window-dedicated-p other-window)
	    (error "Target window is dedicated, can't be swapped") )
          (t
	   (let ( (this-buffer (window-buffer window))
		  (other-buffer (window-buffer other-window)))
               (if (eq this-buffer other-buffer)
                   (let ( (this-point (window-point window))
                          (other-point (window-point other-window)) )
                     (progn
                       (set-window-point window other-point)
                       (set-window-point other-window this-point)
                       (message "unimplemented: swap same buffer?")))
                 (progn
                   (set-window-buffer window (window-buffer other-window))
                   (set-window-buffer other-window orig-buffer)))
               (select-window other-window))))))

(defun hsb-swap-buffer-up (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'up arg))

(defun hsb-swap-buffer-down (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'down arg))

(defun hsb-swap-buffer-left (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'left arg))

(defun hsb-swap-buffer-right (&optional arg)
  (interactive "P")
  (windmove-do-swap-window 'right arg))

(global-set-key (kbd "<C-s-up>") 'hsb-swap-buffer-up)
(global-set-key (kbd "<C-s-down>") 'hsb-swap-buffer-down)
(global-set-key (kbd "<C-s-left>") 'hsb-swap-buffer-left)
(global-set-key (kbd "<C-s-right>") 'hsb-swap-buffer-right)


;; tabs	     
;; (if (featurep 'tabbar)
;;     (progn
;;       (global-set-key (kbd "<C-tab>")   'tabbar-forward-tab)
;;       (global-set-key (kbd "<C-s-tab>") 'tabbar-backward-tab)))

;;
;; some special windows
(if (featurep 'imenu-tree)
    (global-set-key (kbd "s-I") 'imenu-tree))

(if (featurep 'ide-skel)
    (progn
      (global-set-key (kbd "s-B") 'ide-skel-toggle-bottom-view-window)
      (global-set-key (kbd "s-R") 'ide-skel-toggle-right-view-window)
      (global-set-key (kbd "s-L") 'ide-skel-toggle-left-view-window)))

(global-set-key (kbd "s-s") 'speedbar)
(if (featurep 'sr-speedbar)
    (global-set-key (kbd "s-S") 'sr-speedbar-toggle))
;;}}}