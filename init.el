;; .emacs by Leif Karlsson (leif.karlsson@mbox332.swipnet.se)
; (C) 2000 Leif Karlsson, you are allowed to do whatever you like with it,
; absolutely no warranty or any restrictions what so ever.

;;; *** Init ***
; ------------------------------------------------------------------------
;;; Global variables
(defvar CC "cc")                        ; std C commpiler
(defvar CPP "c++")                      ; std C++ commpiler
(defvar AS "nasm -felf")                ; std assembler

; ------------------------------------------------------------------------
(global-font-lock-mode t)
(setq visible-bell t)
(column-number-mode 1)
(show-paren-mode 1)
(pc-selection-mode)
(setq-default indent-tabs-mode nil)
(setq-default truncate-lines t)
;; C-RET ile kelime tamamlamayÃ½ aktif hale getiriyoruz.
;;(global-set-key (kbd "C-RET") 'dabbrev-expand)
(global-set-key (kbd "<C-return>") 'dabbrev-expand)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "Turkish")
 '(default-input-method "turkish-postfix")
 '(display-time-mode t)
 '(global-font-lock-mode t nil (font-lock))
 '(show-paren-mode t)
 '(transient-mark-mode t)
 '(max-mini-window-height 1)
)

(autoload 'ruby-mode "ruby-mode" "Ruby editing mode." t)
(setq auto-mode-alist  (cons '("\\.rb$" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist  (cons '("\\.rhtml$" . html-mode) auto-mode-alist))
;;(setq auto-mode-alist  (cons '("\\.mako$" . html-mode) auto-mode-alist))
(modify-coding-system-alist 'file "\\.rb$" 'utf-8)
(modify-coding-system-alist 'file "\\.rhtml$" 'utf-8)
;;(modify-coding-system-alist 'file "\\.mako$" 'utf-8)

(setq make-backup-files nil)

(if (eq window-system 'x)               ; X11
    (progn
      (add-to-list 'load-path "/fat-c/site-lisp")
      (set-cursor-color "Orchid")
      (set-foreground-color "Wheat")
      (set-background-color "DarkSlateGray")
      (set-face-foreground 'modeline "black") 
      (set-face-background 'modeline "gray")
      (set-face-background 'region "#224422")
      (set-default-font "terminus-13")
;;      (set-default-font "monaco-10")
      (add-to-list 'default-frame-alist '(height . 600))
      (add-to-list 'default-frame-alist '(width . 120))
      (setq indent-tabs-mode nil)
      ))
; ------------------------------------------------------------------------
(if (or (eq window-system 'mac) (eq window-system 'ns))               ; MAC
    (progn
      (set-cursor-color "Orchid")
      (set-foreground-color "Wheat")
      (set-background-color "DarkSlateGray")
      (set-face-foreground 'modeline "black") 
      (set-face-background 'modeline "gray")
      (set-face-background 'region "#224422")
      (set-default-font "-apple-monaco-medium-r-normal--14-140-72-72-m-140-mac-roman")
      (set-screen-width 120)
      (set-screen-height 60)
      (setq indent-tabs-mode nil)
      (setq ns-command-modifier 'meta)
      (setq ns-alternate-modifier 'none)
    ))
; ------------------------------------------------------------------------
(if (eq window-system 'w32)             ; win 9x / nt / 2k
    (progn
      (set-cursor-color "Orchid")
      (set-foreground-color "Wheat")
      (set-background-color "DarkSlateGray")
      (set-face-foreground 'modeline "black") 
      (set-face-background 'modeline "gray")
      (set-face-background 'region "#224422")
      (set-default-font "monaco-10")
      (set-screen-width 120)
      (set-screen-height 60)
      (setq indent-tabs-mode nil)
    ))

; ------------------------------------------------------------------------
(if (eq window-system 'pc)              ; msdos
    (progn
      (msdos-set-keyboard 45)           ; No suport for 46, use 45 instead.
      ;(add-to-list 'load-path "c:/site-lisp")
      (menu-bar-mode nil)               ; No menu bar
      (set-foreground-color "yellow")
      (set-background-color "blue")
      (set-face-foreground 'modeline "black") 
      (set-face-background 'modeline "lightgray")
      ))

; ------------------------------------------------------------------------
(if (eq window-system nil)              ; Unknown terminal (linux assumed)
    (progn
      (add-to-list 'load-path "/fat-c/site-lisp")
      (menu-bar-mode nil)               ; No menu bar
      (add-hook 'term-setup-hook
                (function
                 (lambda ()
                   ;; set a "normal" cursor (two lines)
                   ;; blue backgrond
                   ;; yellow forground
                   (send-string-to-terminal "[?2c[33;44;1m"))))
       
      (add-hook 'kill-emacs-hook        ; Restore colors on exit
                (function 
                 (lambda ()
                   (send-string-to-terminal "[0m")
                   )))))

; ------------------------------------------------------------------------    
; bs.el --- menu for selecting and displaying buffers, 
; cycle buffers previous/next etc.
; Author: Olaf Sylvester <Olaf.Sylvester@netsurf.de>
; Web site: http://home.netsurf.de/olaf.sylvester/emacs
(load "bs")

; calculator.el --- A simple pocket calculator.
(load "calculator")

; ------------------------------------------------------------------------
;;; Make some variables buffer local
(make-variable-buffer-local 'blink-matching-paren-on-screen)
(make-variable-buffer-local 'blink-matching-paren)

; ------------------------------------------------------------------------
;;; *** Bcc55 ***
;; For use with the "free" borland C/C++ compiler & MS "free" assembler.
(if (member "-bcc55" command-line-args)
    (progn 
      (setq command-line-args (delete "-bcc55" command-line-args))
      (setq CC "bcc32")
      (setq CPP "bcc32")
      (setq AS "ml")))

; ------------------------------------------------------------------------
(defun lk-elisp-recompile-dir ()
  (interactive)
  (byte-recompile-directory (read-from-minibuffer 
                             "Byte Recompile: " default-directory)
                            1))

; ------------------------------------------------------------------------
;; Jump to matching {}[]() if on another.
(defun lk-match-paren ()
  "Go to the matching parenthesis if on parenthesis"
  (interactive)
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        ))

; ------------------------------------------------------------------------
(defun lk-tab-indent ()
  (interactive)
  (if (save-excursion
        (skip-chars-backward " \t")
        (not (bolp)))
      (insert-tab)
    (indent-for-tab-command)))

; ------------------------------------------------------------------------
(defun lk-c-electric-pound ()
  (interactive)
  (if (save-excursion
        (skip-chars-backward " \t")
        (not (bolp)))
      (insert "#")
    (progn (insert "#") (indent-for-tab-command))))

; ------------------------------------------------------------------------
(defun lk-c-electric-back-slash ()
  (interactive)
  (end-of-line)
  (if (< (current-column) (current-fill-column))
      (insert (make-string (- (current-fill-column) 
                              (current-column) 1)
                           ?\ )))
  (insert ?\\))

; ------------------------------------------------------------------------
(defun lk-section-comment ()
  (interactive)
  (save-excursion
    (insert comment-start)
    (insert (make-string (- (current-fill-column)
                            (string-width comment-end)
                            (current-column)) ?-))
    (insert comment-end)))

; ------------------------------------------------------------------------
(defun lk-comment-indent-function ()
  (interactive)
  "Computes indention for comments aligned on the fill-column (right border)"
  (if (= (current-column)
         (save-excursion
           (end-of-line)
           (current-column)))
      comment-column       
    (+ (current-column)
       (- (current-fill-column)
          (save-excursion 
            (end-of-line)
            (current-column))))
    ))

; ------------------------------------------------------------------------
(c-add-style "lk" '("bsd"
                    (tab-width . 8)
                    (indent-tabs-mode . nil)
                    (c-block-comment-prefix . "")
                    (c-basic-offset . 4)
                    (c-tab-always-indent . nil)
                    (c-echo-syntactic-information-p . t)
                    (c-label-minimum-indentation . 0)
                    (c-offsets-alist . ((cpp-macro . -3)
                                        (cpp-macro-cont . +)
                                        (substatement . +)
                                        (statement-cont . c-lineup-math)
                                        (comment-intro . 0)
                                        (statement-case-open . +)
                                        (statement-case-intro . +)
                                        ))
                    ))

;;; *** Hook's ***
; ------------------------------------------------------------------------
(add-hook 'dired-mode-hook 
          (function 
           (lambda ()
             ;; Redefine "RET" to open file / dir in current buffer.
             (local-set-key (kbd "RET") 
                            (lambda ()
                              (interactive)
                              (find-alternate-file (dired-get-filename))))
             )))

; ------------------------------------------------------------------------
(add-hook 'emacs-lisp-mode-hook
          (function
           (lambda ()
             (setq comment-start "; ")
             (setq tab-width 4)
             (setq indent-tabs-mode nil)
             (local-set-key (kbd "TAB") 'lk-tab-indent)
             (local-set-key (kbd "<f8>") 'emacs-lisp-byte-compile)
             (local-set-key (kbd "<f9>") 'lk-elisp-recompile-dir)
             )))

; ------------------------------------------------------------------------
(add-hook 'c-mode-common-hook
          (function 
           (lambda ()
             (setq blink-matching-paren-on-screen nil)
             (local-set-key (kbd "#")   'lk-c-electric-pound)
             (local-set-key (kbd "M-\\") 'lk-c-electric-back-slash)
             (set-fill-column 78)
             (setq comment-column 32)
;             (setq comment-indent-function 'lk-comment-indent-function)
             )))

; ------------------------------------------------------------------------
(add-hook 'c-mode-hook
          (function 
           (lambda ()
             (c-set-style "lk")
             ;; Run cc directly, useful for quick test code.
             (local-set-key (kbd "<f8>") 
                            (lambda () 
                              (interactive)
                              (require 'compile)
                              (compile-internal (read-from-minibuffer 
                                                 "Compile: "
                                                 (format "%s %s "
                                                         CC
                                                         buffer-file-name))
                                                "No more errors")))
             )))

; ------------------------------------------------------------------------
(add-hook 'c++-mode-hook
          (function 
           (lambda ()
             (c-set-style "lk")
             ;; Run c++ directly, useful for quick test code.
             (local-set-key (kbd "<f8>") 
                            (lambda () 
                              (interactive)
                              (require 'compile)
                              (compile-internal (read-from-minibuffer 
                                                 "Compile: "
                                                 (format "%s %s "
                                                         CPP
                                                         buffer-file-name))
                                                "No more errors")))
             )))

; ------------------------------------------------------------------------
(add-hook 'asm-mode-hook
          (function
           (lambda ()
             (setq tab-width 4)
             (setq indent-tabs-mode nil)
             (setq blink-matching-paren nil)
             (setq asm-style "nasm")    ; for use with my hacked asm-mode.el
             ;; Run the assembler directly, useful for quick test code.
             (local-set-key (kbd "<f8>") 
                            (lambda () 
                              (interactive)
                              (require 'compile)
                              (compile-internal (read-from-minibuffer 
                                                 "Assamble: "
                                                 (format "%s %s " 
                                                         AS
                                                         buffer-file-name))
                                                "No more errors")))
             )))             

;;; *** Advice / fset ***
; ------------------------------------------------------------------------
(fset 'yes-or-no-p 'y-or-n-p)           ; Allways y ws n instead of yes ws no

; ------------------------------------------------------------------------
;;; *** Key bindings *** 
(global-set-key (kbd "M-S")     'ispell-region)
(global-set-key (kbd "M-P")     'lk-match-paren)
(global-set-key (kbd "M-R")     'lk-section-comment)
(global-set-key (kbd "M-F")     'find-file-at-point)
(global-set-key (kbd "M-C")     'calculator)
(global-set-key (kbd "C-x C-b") 'bs-show)
(global-set-key (kbd "<f12>")   'bs-cycle-next)
(global-set-key (kbd "<f11>")   'bs-cycle-previous)
(global-set-key (kbd "<home>")  'beginning-of-line)
(global-set-key (kbd "<end>")   'end-of-line)
(global-set-key (kbd "C-<home>") 'beginning-of-buffer)
(global-set-key (kbd "C-<end>") 'end-of-buffer)
(global-set-key (kbd "C-x C-k") 'kill-buffer-and-window)
(global-set-key (kbd "<f9>")    'compile)
(global-set-key (kbd "C-2")     'set-mark-command)

;;; *** Misc ***
; ------------------------------------------------------------------------
; The mode-line, the way I like it...
(setq line-number-mode t)
(setq column-number-mode t)
(setq display-time-24hr-format t)
(display-time)
(setq mode-line-inverse-video t)
(setq default-mode-line-format 
      (list
       "  [%H%M]  ("
       'mode-name
       'minor-mode-alist
       ")  [%12b (%l:%c %p)]"
       ))

(setq mode-line-format default-mode-line-format)

; ------------------------------------------------------------------------
;(setq ring-bell-function (lambda ()))   ; Very silent...
(setq ring-bell-function (lambda () (message "pip...")))

; Rage against BEEP's:
; Then something goes wrong, and I'm angry and upset, the last thing I 
; need to hear is a fucking "BEEP". I know (one way or the other) that 
; something got fucked up anyway. Error messages should be informative,
; using a friendly language, written in lower case in a warm and soft color 
; (gray is good). "BEEP" is non of this.  [written in rage //Leif]

; scroll one line at the time
(setq scroll-step 1)
(setq scroll-conservatively 10000)

(setq inhibit-startup-message t)       
(setq next-line-add-newlines nil)       ; Don't add newlines automaticly
(setq hscroll-margin 1)                 ; Don't hscroll unless needed
;(hscroll-global-mode t)     			; Don't warp long lines
(setq default-fill-column 74)
(setq scroll-preserve-screen-position t); Make pgup/dn remember current line
(bs-set-configuration "all")			; Show all buffers
(set-scroll-bar-mode nil) 				; Don't like scroll bar's 
(set-default 'case-fold-search t)		; Make searches case insensitive
(setq compile-command "pycompile")

;;; I just can't have a calculator without shiftL/R, nor do I like the std
;;; use of '<>'...
(setq calculator-user-operators
      '(("sl" shl   (* TX (expt 2 TY)) 2 4)
        ("sr" shr   (/ TX (expt 2 TY)) 2 4)
        ("<"  shl1  (* TX 2) 1 8)
        (">"  shr1  (/ TX 2) 1 8)
        ))

; ------------------------------------------------------------------------
;;; *** Desktop (use M-x desktop-save the first time) ***
;(if (member "-nd" command-line-args)
;    (setq command-line-args (delete "-nd" command-line-args))
;  (progn 
;    (load "desktop")
;    (desktop-load-default)
;    (desktop-read)))
; ------------------------------------------------------------------------
(set-language-environment "turkish")
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(desktop-save-mode 1)

(fset 'get_str
   [?\C-x ?h ?\C-u ?\M-x ?s ?h ?e tab ?- tab ?c ?o tab ?- tab return ?~ ?/ ?q ?t ?4 ?( backspace ?/ ?t ?o ?o ?l ?s ?/ ?s ?t ?r ?i ?n ?g ?F ?i ?n ?d ?e ?r ?. ?p ?y return])
(fset 'blk_sort
   [?\C-u ?\M-x ?s ?h ?e ?l ?l ?- tab ?c ?o ?m tab ?- ?o ?n tab return ?s ?o ?r ?t return])
(fset 'blk_uniq
   [?\C-u ?\M-x ?s ?h ?e ?l ?l ?- tab ?c tab ?- tab return ?u ?n ?i ?q return])
(fset 'trans
   [left ?\C-s ?' ?\C-m left ?\C-2 ?\C-s ?' ?\C-m ?\C-s ?\C-s S-delete ?_ ?( ?\C-y ?)])

(fset 'translate-string
   [?\C-s ?\' ?\C-b ?_ ?\( ?\C-f ?\C-s ?\C-s ?\C-m ?\) ?\C-x ?\C-x ?\C-  ?\C-s ?\C-s ?\C-b])

(fset 'add-translation
   [tab ?\C-f ?\C-f ?\C-y ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-y ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f ?\C-f])

(fset 'insert-translation
   [?\C-a ?\C-o tab ?u ?\' ?\C-y ?\' ?: ?  ?\{ ?\' ?t ?r ?\' ?: ?  ?\' ?\C-y ?\' ?, ?  ?\' ?e ?n ?\' ?: ?\S-  ?\' ?\' ?\} ?, ?\C-b ?\C-b ?\C-b])

(load-library "hideshow")
(add-hook 'python-mode-hook       'hs-minor-mode)

(global-set-key (kbd "C-x t r")     'translate-string)
(global-set-key (kbd "C-x t a")     'add-translation)
(global-set-key (kbd "C-x t i")     'insert-translation)

(put 'downcase-region 'disabled nil)

;; start emacs server
;; (require 'edit-server)
;; (edit-server-start) 

;; turkish mode load
;; (add-hook 'edit-server-text-mode-hook 'turkish-mode)

;; Ne hikmetse bunu eklemeden calismiyordu
(add-to-list 'load-path "~/.emacs.d/")

(add-to-list 'load-path
             "~/.emacs.d/plugins/yasnippet-0.6.1c")
(require 'yasnippet) ;; not yasnippet-bundle
(yas/initialize)
(yas/load-directory "~/.emacs.d/plugins/yasnippet-0.6.1c/snippets")

(require 'ido)
(ido-mode t)

;; Repository uzerinde recursive search imkani
(require 'repository-root)
(require 'grep-o-matic)

;; Custom grep komutu
(require 'ack-emacs)
;(setq grep-command "grep -rnH <C> . --include=\"*.py\"")
(setq grep-command "ack -H --nogroup")

;; Otomatik parantez ve kume parantezi acma olaylari

(require 'autopair)
(autopair-global-mode)
(add-hook 'python-mode-hook
          #'(lambda ()
              (setq autopair-handle-action-fns
                    (list #'autopair-default-handle-action
                          #'autopair-python-triple-quote-action))))

;; Rope ve ropemacs
;;(require 'pymacs)
;;(pymacs-load "ropemacs" "rope-")

;; Mako template dili ile ilgili islemler
(load "mmm-mako.el")
(add-to-list 'auto-mode-alist '("\\.mako\\'" . html-mode))
(mmm-add-mode-ext-class 'html-mode "\\.mako\\'" 'mako)
                          
;; turn on highlighting current line
;;(global-hl-line-mode 1)
;; Delete tuþu alýþýldýðý gibi çalýþsýn
(normal-erase-is-backspace-mode 1)

;; Kisisel tus ayarlarim
;; ---------------------
;; Enter'a basinca otomatik olarak indent yapsin
(global-set-key (kbd "RET") 'newline-and-indent)

;; ctrl+backspae kill yapiyor, yapmasin
(defun delete-prev-word()
  (interactive)
  (delete-region (point)
                 (save-excursion
                   (backward-word 1)
                   (point)
                   )
                 )
)
(global-set-key (kbd "C-<backspace>") 'delete-prev-word)
;; ctrl+. ve ctrl+7 undo islemi yapsin
(global-set-key (kbd "C-.") 'undo)
(global-set-key (kbd "C-7") 'undo)
(global-set-key (kbd "C-3")  'comment-region)
(global-set-key (kbd "C-4")  'uncomment-region)
;; yapistirma islemine alternatif
(global-set-key [(control insert)] 'clipboard-yank)

;
;; os un clipbordunu kullanabilme
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;;duplicate line
(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
)
(global-set-key (kbd "M-.") 'duplicate-line)

;; move line up
(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (previous-line 2))

(global-set-key (kbd "M-<up>") 'move-line-up)

;; move line down
(defun move-line-down ()
  (interactive)
  (next-line 1)
  (transpose-lines 1)
  (previous-line 1))

(global-set-key (kbd "M-<down>") 'move-line-down)

;;goto line
(global-set-key (kbd "C-x g") 'goto-line)

; Define a trivial function to bind the sgml-tags-menu to psgml's local key
; (A Lambda might do as well.)
; Note the down-mouse-3 action here, it must be used instead just mouse-3 to
; avoid conflicts with Emacs' default binding of down-mouse-3. If you want to
; use mouse-3 instead, you'll need to unset down-mouse-3 first.
(defun go-bind-markup-menu-to-mouse3 ()
        (define-key sgml-mode-map [(down-mouse-3)] 'sgml-tags-menu))
    ;
    ; change key binding whenever psgml mode is invoked
(add-hook 'sgml-mode-hook 'go-bind-markup-menu-to-mouse3)


;; (load "mmm-mako.el")
;; (add-to-list 'auto-mode-alist '("\\.mako\\'" . html-mode))
;; (mmm-add-mode-ext-class 'html-mode "\\.mako\\'" 'mako)

(add-to-list 'load-path "~/.emacs.d/plugins/yasnippet-0.6.1c/arduino-mode")
(add-to-list 'auto-mode-alist '("\\.ino\\'" . arduino-mode))
(add-to-list 'auto-mode-alist '("\\.pde\\'" . arduino-mode))
(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)

;; tr uyumlulugu icin gerekli
(prefer-coding-system 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)

(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; optional keyboard short-cut
(global-set-key "\C-x m" 'browse-url-at-point)

;; html5 ve web gelistirmeleri icin
;; web-mode kullanÄ±yoruz.
;; http://web-mode.org/
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))


 

