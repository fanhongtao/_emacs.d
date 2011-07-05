;;; zenburn-theme.el --- Custom face theme for Emacs

;; Copyright (C) 2010 .

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(deftheme zenburn
  "")

(custom-theme-set-faces
 'zenburn
 '(default ((t (:background "#3f3f3f" :foreground "#dcdccc"))))
 '(cursor ((t (:background "#aaaaaa"))))
 '(region ((t (:background "#5f5f5f"))))
 '(mode-line ((t (:background "#1e2320" :foreground "#acbc90"))))
 '(mode-line-inactive ((t (:background "#88b090" :foreground "#2e3330"))))
 '(fringe ((t (:background "#464646"))))
 '(font-lock-builtin-face ((t (:foreground "#8cd0d3"))))
 '(font-lock-comment-face ((t (:foreground "#7f9f7f"))))
 '(font-lock-constant-face ((t (:foreground "#dca3a3" :weight bold))))
 '(font-lock-function-name-face ((t (:foreground "#8cd0d3"))))
 '(font-lock-keyword-face ((t (:foreground "#f0dfaf" :weight bold))))
 '(font-lock-string-face ((t (:foreground "#cc9393"))))
 '(font-lock-type-face ((t (:foreground "#dfdfbf" :weight bold))))
 '(font-lock-variable-name-face ((t (:foreground "#a0522d"))))
 '(font-lock-warning-face ((t (:background "#332323" :foreground "#e37170"))))
 '(isearch ((t (:background "#506070" :foreground "#dcdccc"))))
 '(lazy-highlight ((t (:background "#1e2320" :foreground "#dcdccc"))))
 '(link ((t (:foreground "#f0dfaf" :underline t))))
 '(link-visited ((t (:foreground "#94bff3" :underline t))))
 '(button ((t (:background "#506070" :foreground "#f0dfaf" :underline t :weight bold))))
 '(hl-line ((t (:background "#2b2b2b"))))
 '(ido-first-match ((t (:foreground "#f0dfaf" :weight bold))))
 '(ido-only-match ((t (:foreground "#dfaf8f" :weight bold))))
 '(ido-subdir ((t (:foreground "#f0dfaf"))))
 '(minibuffer-prompt ((t (:foreground "#f0dfaf"))))
 '(header-line ((t (:background "#2e3330" :foreground "#88b090")))))

(provide-theme 'zenburn)

;; Local Variables:
;; no-byte-compile: t
;; End:

;;; zenburn-theme.el  ends here

