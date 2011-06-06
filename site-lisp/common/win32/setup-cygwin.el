;;; setup-cygwin.el --- Set up Emacs for using Cygwin
;;
;; Filename: setup-cygwin.el
;; Description:
;; Author: Markus Hoenika
;; Maintainer: Drew Adams
;; Copyright (C) 2004-2009, Drew Adams, all rights reserved.
;; Created: Thu Jan 15 11:13:38 2004
;; Version: 21.0
;; Last-Updated: Thu Oct 15 13:39:31 2009 (-0700)
;;           By: dradams
;;     Update #: 94
;; URL: http://www.emacswiki.org/cgi-bin/wiki/setup-cygwin.el
;; Keywords: os, unix, cygwin
;; Compatibility: GNU Emacs: 20.x, 21.x, 22.x, 23.x
;;
;; Features that might be required by this library:
;;
;;   `ange-ftp', `backquote', `comint', `cygwin-mount', `ring'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;   Set up Emacs for using Cygwin.  From Markus Hoenika's paper "SGML
;;   for Windows NT" <hoenika_markus@compuserve.com>
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change log:
;;
;; 2009/10-15 dadams
;;     Set ediff-shell to shell-file-name.
;; 2007/12/08 dadams
;;     Use absolute file name for shell-file-name.
;; 2006/11/16 dadams
;;     Replace add-to-list by setq, for Emacs -q prior to Emacs 21.
;; 2006/08/14 dadams
;;     Append, not prepend "c:/cygwin/usr/info/" to Info-default-directory-list.
;; 2004/10/01 dadams
;;     Changed Info-directory-list to Info-default-directory-list
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'cygwin-mount)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Make Cygwin paths accessible
(cygwin-mount-activate)

;;; Follow Cygwin symlinks.
;;; Handles old-style (text file) symlinks and new-style (.lnk file) symlinks.
;;; (Non-Cygwin-symlink .lnk files, such as desktop shortcuts, are still loaded as such.)
(defun follow-cygwin-symlink ()
  "Follow Cygwin symlinks.
Handles old-style (text file) and new-style (.lnk file) symlinks.
\(Non-Cygwin-symlink .lnk files, such as desktop shortcuts, are still
loaded as such.)"
  (save-excursion
    (goto-char 0)
    (if (looking-at
         "L\x000\x000\x000\x001\x014\x002\x000\x000\x000\x000\x000\x0C0\x000\x000\x000\x000\x000\x000\x046\x00C")
        (progn
          (re-search-forward
           "\x000\\([-A-Za-z0-9_\\.\\\\\\$%@(){}~!#^'`][-A-Za-z0-9_\\.\\\\\\$%@(){}~!#^'`]+\\)")
          (find-alternate-file (match-string 1)))
      (if (looking-at "!<symlink>")
          (progn
            (re-search-forward "!<symlink>\\(.*\\)\0")
            (find-alternate-file (match-string 1))))
      )))
(add-hook 'find-file-hooks 'follow-cygwin-symlink)

;;; Use Unix-style line endings.
(setq-default buffer-file-coding-system 'undecided-unix)


;;; Add Cygwin Info pages and Man pages (to woman)
(when (file-exists-p (get-cyg-dir))
  (setq Info-default-directory-list (append Info-default-directory-list (list (concat (get-cyg-dir)"/usr/info/"))))
  (when (boundp 'woman-manpath)
    (setq woman-manpath (append woman-manpath
                                (list (concat (get-cyg-dir) "/usr/man")
                                      (concat (get-cyg-dir) "/usr/share/man")
                                      (concat (get-cyg-dir) "/usr/local/man"))))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;

(provide 'setup-cygwin)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setup-cygwin.el ends here
