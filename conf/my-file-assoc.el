;;; AutoHotKey (ahk) mode (a keyboard macro for Windows)
(autoload 'xahk-mode "xahk-mode" "AutoHotKey mode" t)
(add-to-list 'auto-mode-alist '("\\.ahk\\'" . xahk-mode))

;;; AutoIt
(autoload 'autoit-mode "autoit-mode" "AutoIt mode" t)
(add-to-list 'auto-mode-alist '("\\.au3\\'" . autoit-mode))

(autoload 'au3-mode "au3-mode" "AutoIt mode" t)
;;(add-to-list 'auto-mode-alist '("\\.au3\\'" . autoit-mode))

;;; C#
(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(setq auto-mode-alist
    (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))

;;; CSS mode
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))
(autoload 'css-mode "css-mode" nil t)

;;; for editing Windows's cmd.exe's script; batch, ¡°.bat¡± file mode.
(autoload 'dos-mode "dos" "A mode for editing Windows cmd.exe batch scripts." t)
(add-to-list 'auto-mode-alist '("\\.bat\\'" . dos-mode))
(add-to-list 'auto-mode-alist '("\\.cmd\\'" . dos-mode))

;;; javascript. (IDE-like by Steve Yegge. Features a js syntax parser)
(autoload 'js2-mode "js2-20090723b" "IDE-like Javascript mode; features a on-the-fly syntax parser." t)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))

(autoload 'espresso-mode "espresso" nil t)
(autoload 'javascript-mode "javascript" nil t)


;;; mode for lua language
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-mode)) ; lua-mode

;;; InnoSetup (*.iss)
(autoload 'iss-mode "iss-mode" "Innosetup Script Mode" t)
(setq auto-mode-alist (append '(("\\.iss$"  . iss-mode)) auto-mode-alist))


;;; Markdown
(autoload 'markdown-mode "markdown-mode."
        "Major mode for editing Markdown files" t)
(setq auto-mode-alist
        (cons '("\\.mkd" . markdown-mode) auto-mode-alist))

;;; NSIS (*.nsi)
(autoload 'nsi-mode "nsi-mode" "Innosetup Script Mode" t)
(setq auto-mode-alist (append '(("\\.nsi$"  . iss-mode)) auto-mode-alist))




;;; powershell-mode. http://en.wikipedia.org/wiki/PowerShell
(autoload 'powershell-mode "powershell-mode" "A editing mode for Microsoft PowerShell." t)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode)) ; PowerShell script


;;; php mode
(autoload 'php-mode "php-mode" "php mode by Aaron S Hawley." t)
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))

;;; powershell interactive shell
(autoload 'powershell "powershell" "Interactive shell for PowerShell." t)

;;; RPM spec
(autoload 'rpm-spec-mode "rpm-spec-mode.el" "RPM spec mode." t)
(setq auto-mode-alist (append '(("\\.spec" . rpm-spec-mode))
                                auto-mode-alist))



;;; visual-basic-mode
(autoload 'visual-basic-mode "visual-basic-mode" "Visual Basic mode." t)
(add-to-list 'auto-mode-alist '("\\.vbs\\'" . visual-basic-mode)) ;VBscript
(add-to-list 'auto-mode-alist '("\\.vb\\'" . visual-basic-mode))  ;visual basic .NET file
(add-to-list 'auto-mode-alist '("\\.bas\\'" . visual-basic-mode)) ;visual basic form
(add-to-list 'auto-mode-alist '("\\.frm\\'" . visual-basic-mode)) ;basic language source
(add-to-list 'auto-mode-alist '("\\.cls\\'" . visual-basic-mode)) ;C++ class definition file




