
;;;_ epy
(require 'epy-setup)
(require 'epy-python)
(require 'epy-completion)


;;;_ my enhancement for epy
;;;_. view
(autoload 'highlight-indentation "highlight-indentation")

;;;_. code folding
(require 'hideshowvis)
(require 'hideshow-fringe)


;;;_. syntax check
;;;_ , pep8
;;;_ , pylint
;;;_ , pyflakes
;;;_ , pychecke

;;;_. flymake
(require 'flymake-cursor)
(require 'rfringe)

;;;_. menu
(require 'easymenu)
(defun define-menu-for-epy (keymap)
  (easy-menu-define epy-menu keymap
    "Menu for emacs-for-python package."
  '("epy"
    ["Choose method (imenu)..." imenu t]
    ["Choose method (anything)...)" anything-browse-code :active (fboundp 'anything-browse-code) ]
    ["Imenu tree" imenu-tree t]
    ["Tags tree" tags-tree t]
    "--"
    ("Code folding"
     ["hs-minor-mode" hs-minor-mode :style toggle :selected hs-minor-mode]
     ["  hideshowvis" hideshowvis-minor-mode :style toggle :selected hideshowvis-minor-mode
      :active hs-minor-mode]
     ["outline-minor-mode" outline-minor-mode :style toggle :selected outline-minor-mode]
     ["  hide sublevels" hide-sublevels t]
     ["  show all" show-all t]
     )
    ["Pretty lambda mode" pretty-lambda-mode :style toggle :selected lambda-mode
     :help "Pretty-print lambdas"]
    ["Highlight indentation mode" highlight-indentation :style toggle
     :selected highlight-indent-active :help "Highlight indentation."]
    "--"
    ["Smart operator mode" smart-operator-mode :style toggle :selected smart-operator-mode
     :help "Insert operators with surrounding spaces smartly."]
    ["Autopair mode" autopair-mode :style toggle :selected autopair-mode
     :help "Automagically pair braces and quotes like TextMate."]
    ("Yasnippets"
     ["on/off" yasnippet :style: toggle :selected nil]
     ["Load Django templates" ignore nil]
     )
    ("Auto-Complete"
     ["on/off" auto-complete-mode :style toggle :selected auto-complete-mode]
     ["ropemacs source" epy-enable-ac-ropemacs-source :style toggle :selected (memq 'ac-source-nropemacs ac-sources)]
     ["yasnippets source" ac-python-mode-setup :style radio]
     ["scite-api source" ignore :style toggle :selected nil]
    )
     ["pycomplete source" ignore :active (fboundp 'py-shell) :style toggle]
    "--"
    ("Syntax Check"
     ["Pyflakes" ignore t]
     ["Pylint" pylint t]
     ["Pychecker" ignore t]
     ["PEP8" epy-pep8 t]    
     )
    ("Flymake"
     ["on/off" flymake-mode :style toggle :selected flymake-mode]
     ["Pyflakes" ignore :style radio :selected  flymake-mode]
     ["Pylint" pylint :style radio :active flymake-mode]
     ["Pycheckers" ignore :style radio :active flymake-mode]
     ["PEP8" pep8 :style radio :active flymake-mode]
     )
    ("Debug"
     ["pdb" ignore t]
     ["ipdb" ignore t]
     ["pydb" ignore t]
     )
    ["byte-compile" ignore t]
    "--"
    ["eldoc-mode" eldoc-mode :style toggle :selected eldoc-mode]
    ["pylookup" pylookup-lookup :active nil]
    ["python.chm (windows)" epy-python-chm-keyword :active (eq window-system 'w32)]
    "--"
    ["eproject" eproject t]
    ["refactoring: rename current symbol" iedit-mode
     :help "Use `iedit-mode' to replace all occurren of current symbol in whole buffer."]
    ["refactoring: rename current symbol in function"  epy-iedit-in-defun
     :style toggle :selected iedit-mode :help "Use `narrow-to-defun' and 'iedit-mode' to replace all "]
  )))

(define-menu-for-epy python-mode-map)



;;;_ python-mode
(when (require 'python-mode nil t)
   (define-menu-for-epy py-mode-map)
   
   (setq outline-regexp "[[:space:]]*\\(?:\\(?:class\\|def\\)\\)\\_>")
   
   )

